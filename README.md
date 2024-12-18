# QuartzGetWindow.jl

## Description

- This repository [QuartzGetWindow.jl](https://github.com/atelierarith/QuartzGetWindow.jl) gives a julia package for obtaining GUI information for macOS users.
	- For example we can use `getActiveWindowName()` function to get the name of currently active window. The result should be same as [pygetwindow.getActiveWindow](https://github.com/asweigart/PyGetWindow/blob/c5f3070324609e682d082ed53122a36002a3e293/src/pygetwindow/_pygetwindow_macos.py#L14-L22)
	- We also provide `getWindowGeometry(title)` function to get a window position and size with a given `title`. The result should be same as [pygetwindow.getWindowGeometry](https://github.com/asweigart/PyGetWindow/blob/c5f3070324609e682d082ed53122a36002a3e293/src/pygetwindow/_pygetwindow_macos.py#L44-L50)

- Note that our pacakge [QuartzGetWindow.jl](https://github.com/atelierarith/QuartzGetWindow.jl) uses [CoreGraphics](https://developer.apple.com/documentation/coregraphics) library on macOS. This approach is similar to [QuartzImageIO.jl](https://github.com/JuliaIO/QuartzImageIO.jl).

## Application

You can record an active window during the calculation.

```julia
using Dates
using QuartzGetWindow

struct ScreenRecorder
    procref::Ref{Base.Process}
end

function ScreenRecorder(proc::Base.Process)
    ScreenRecorder(Ref(proc))
end

function start(::Type{ScreenRecorder})
    n = getActiveWindowName()
    @debug n
    x, y, w, h = getWindowGeometry(n)
    file = "$(Dates.now()).mov"

    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
    # Run `screencapture` command
    cmd = `screencapture -R$(x),$(y),$(w),$(h) -v $(file)`
    proc = Base.run(cmd, inp, out, err, wait = false)
    recorder = ScreenRecorder(proc)
    return recorder
end

function quit(recorder::ScreenRecorder)
    # press q key
    write(recorder.procref[], "q")
end

function main()
    @debug "Start recording..."
    sleep(1.0)
    recorder = start(ScreenRecorder)
    # Do something
    sleep(1.0)
    println("Count down")
    for i = 5:-1:1
        println("i=$(i)")
        sleep(0.5)
    end
    println("🚀")
    # Stop `screencapture` process
    quit(recorder)
    @debug "Quit"
    exit()
end

main()
```

You will get the following result:

https://github.com/user-attachments/assets/d65a982e-ca71-4e1d-bf1a-da9a8a55a90b



