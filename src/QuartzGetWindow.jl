module QuartzGetWindow

using Libdl
using ObjectiveC.CoreFoundation: CFDictionaryRef, CFString

# Types
const CFArrayRef = Ptr{Cvoid}

# Libs
const CoreGraphics =
    Libdl.find_library(["/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics"])

# ---

# Taken from CG_const.jl in QuartzImageIO.jl
const kCGNullWindowID = 0
const kCGWindowListExcludeDesktopElements = 16
const kCGWindowListOptionOnScreenOnly = 1

# Taken from QuartzImageIO.jl
#const kCFNumberSInt8Type = 1
#const kCFNumberSInt16Type = 2
const kCFNumberSInt32Type = 3
#const kCFNumberSInt64Type = 4
#const kCFNumberFloat32Type = 5
#const kCFNumberFloat64Type = 6
#const kCFNumberCharType = 7
#const kCFNumberShortType = 8
#const kCFNumberIntType = 9
#const kCFNumberLongType = 10
#const kCFNumberLongLongType = 11
#const kCFNumberFloatType = 12
#const kCFNumberDoubleType = 13
#const kCFNumberCFIndexType = 14
#const kCFNumberNSIntegerType = 15
#const kCFNumberCGFloatType = 16
#const kCFNumberMaxType = 16

# CFNumber
function CFNumberGetValue(CFNum::Ptr{Cvoid}, numtype)
    CFNum == C_NULL && return nothing
    out = Cint[0]
    ccall(:CFNumberGetValue, Bool, (Ptr{Cvoid}, Cint, Ptr{Cint}), CFNum, numtype, out)
    out[1]
end

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{Cint})
    CFNumberGetValue(CFNum, kCFNumberSInt32Type)
end

function CFDictionaryGetValue(d::T, key) where T<:Union{CFDictionaryRef, Ptr{Cvoid}}
    d == C_NULL && return C_NULL
    ccall(:CFDictionaryGetValue, Ptr{Cvoid}, (CFDictionaryRef, CFString), d, key)
end

function CFDictionaryGetValue(d::T, key::String) where T<:Union{CFDictionaryRef, Ptr{Cvoid}}
    CFDictionaryGetValue(d, CFString(key))
end

# ---

export getActiveWindowName
export getWindowGeometry
export getActiveWindowGeometry
export getScreensize
export getAllActiveWindowNames

function getAllActiveWindowNames()
    windows = @ccall CoreGraphics.CGWindowListCopyWindowInfo(
                (kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenOnly)::Cint,
                kCGNullWindowID::Cint,
    )::CFArrayRef
    nwindows = @ccall CFArrayGetCount(windows::CFArrayRef)::Cint
    names = Any[]
    for i in (nwindows-1):-1:0
        win = @ccall CFArrayGetValueAtIndex(
            windows::CFArrayRef, i::Cint
        )::CFDictionaryRef
        #if CFNumberGetValue(CFDictionaryGetValue(win, "kCGWindowLayer"), Cint) == 0
        a = String(CFString(CFDictionaryGetValue(win, "kCGWindowOwnerName")))
        b = String(CFString(CFDictionaryGetValue(win, "kCGWindowName")))
        push!(names, "$a $b")
    end
    return names
end

function getActiveWindowName()::Union{String, Nothing}
	windows = @ccall CoreGraphics.CGWindowListCopyWindowInfo(
	            (kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenOnly)::Cint,
	            kCGNullWindowID::Cint,
	)::CFArrayRef
    nwindows = @ccall CFArrayGetCount(windows::CFArrayRef)::Cint
	for i in (nwindows-1):-1:0
		win = @ccall CFArrayGetValueAtIndex(
			windows::CFArrayRef, i::Cint
		)::CFDictionaryRef
		if CFNumberGetValue(CFDictionaryGetValue(win, "kCGWindowLayer"), Cint) == 0
            a = String(CFString(CFDictionaryGetValue(win, "kCGWindowOwnerName")))
            b = String(CFString(CFDictionaryGetValue(win, "kCGWindowName")))
            return "$a $b"
        end
	end
	return nothing
end

function getWindowGeometry(title::AbstractString)::Union{NTuple{4, Cint}, Nothing}
	windows = @ccall CoreGraphics.CGWindowListCopyWindowInfo(
	            (kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenOnly)::Cint,
	            kCGNullWindowID::Cint,
	)::CFArrayRef
    nwindows = @ccall CFArrayGetCount(windows::CFArrayRef)::Cint
	for i in (nwindows-1):-1:0
		win = @ccall CFArrayGetValueAtIndex(
			windows::CFArrayRef, i::Cint
		)::CFDictionaryRef
		if CFNumberGetValue(CFDictionaryGetValue(win, "kCGWindowLayer"), Cint) == 0
            a = String(CFString(CFDictionaryGetValue(win, "kCGWindowOwnerName")))
            b = String(CFString(CFDictionaryGetValue(win, "kCGWindowName")))
            if occursin(title, "$a $b")
                windowbounds = CFDictionaryGetValue(win, "kCGWindowBounds")
                x_ = CFDictionaryGetValue(windowbounds, "X")
                y_ = CFDictionaryGetValue(windowbounds, "Y")
                w_ = CFDictionaryGetValue(windowbounds, "Width")
                h_ = CFDictionaryGetValue(windowbounds, "Height")
                x = CFNumberGetValue(x_, Cint)
                y = CFNumberGetValue(y_, Cint)
                w = CFNumberGetValue(w_, Cint)
                h = CFNumberGetValue(h_, Cint)
                return (x, y, w, h)
            end
        end
	end
	return nothing
end

getActiveWindowGeometry() = getWindowGeometry(getActiveWindowName())

"""
Returns the width and height of the screen as a two-integer tuple.
    Returns:
      (width, height) tuple of the screen size.
"""
function getScreensize()
    displayid = @ccall CoreGraphics.CGMainDisplayID()::Cuint
    w = @ccall CoreGraphics.CGDisplayPixelsWide(displayid::Cuint)::Cint
    h = @ccall CoreGraphics.CGDisplayPixelsHigh(displayid::Cuint)::Cint
    return (w, h)
end

end # module QuartzGetWindow
