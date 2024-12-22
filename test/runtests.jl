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
    n = getActiveWindowName()
    if !isnothing(n)
        win = windows |> first
        r = getWindowGeometry(n)
        !isnothing(r)
            x,y,w,h = r
            @test x ≥ 0
            @test y ≥ 0
            @test w ≥ 0
            @test h ≥ 0
        end
    end
end