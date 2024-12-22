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
