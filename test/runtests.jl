using Test
using QuartzGetWindow
using Aqua
using JET

@testset "Aqua" begin
    Aqua.test_all(QuartzGetWindow)
end

@testset "JET" begin
    JET.report_package(QuartzGetWindow, target_defined_modules=true)
end

@testset "getAllActiveWindowNames" begin
    @test getAllActiveWindowNames() |> length |> ≥(0)
end

@testset "getActiveWindowGeometry" begin
    windows = getAllActiveWindowNames()
    if windows ≥ 1
        win = windows |> first
        x,y,w,h = getActiveWindowGeometry(win)
        x ≥ 0
        y ≥ 0
        w ≥ 0
        h ≥ 0
    end
end