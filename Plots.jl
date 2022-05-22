using Plots
using DelimitedFiles
using LaTeXStrings


include("../../../output_c2_8.jl")

include("../../../output_c2_16.jl")

include("../../../output_c2_24.jl")


scatter(
	ylabel=L"G(t,|k|=2\pi/L)/\chi", xlabel=L"t/L^4",
    grid = :off,
    box = :on,
    foreground_color_legend = nothing,
    fontfamily = "serif-roman",
    xtickfontsize = 10,
    ytickfontsize = 10,
    xguidefontsize = 10,
    yguidefontsize = 10,
    thickness_scaling=1.5,
    legendfontsize=4,
    #legend_font_pointsize=14,
    #legendtitlefontsize=14,
    markersize=1,
    legend=:topright
)


plot!(t_8/8^4,C_8/C_8[1],ribbon=Cerr_8/C_8[1],label=L"L=8",fillalpha=0.2)
plot!(t_16/16^4,C_16/C_16[1],ribbon=Cerr_16/C_16[1],label=L"L=16",fillalpha=0.2)
plot!(t_24/24^4,C_24/C_24[1],ribbon=Cerr_24/C_24[1],label=L"L=24",fillalpha=0.2)

savefig("Ck1.pdf")
