cd(@__DIR__)

using Plots
using DelimitedFiles
using LaTeXStrings


function autocor_loc_2(x, beg, max, n=2)
	C = zeros(Complex{Float64},max+1)
	N = zeros(Int64,max+1)
	Threads.@threads for tau in 0:max
		for i in beg:length(x)-max
			j = i + tau
			@inbounds @fastmath  C[tau+1] = C[tau+1] +  (x[i]*conj(x[j]))^n
			@inbounds @fastmath  N[tau+1] = N[tau+1] + 1
		end
	end
	(collect(1:max+1),  C ./ N)
end


df_16=readdlm("output_16.dat",' ')
df_8=readdlm("output_8.dat",' ')
df_4=readdlm("output_4.dat",' ')

(t_8,c_8) = autocor_loc_2(df_8[:,5].+df_8[:,6].*1.0im, 1, Int(8^4/4), 1)

(t_4,c_4) = autocor_loc_2(df_4[:,5].+df_4[:,6].*1.0im, 1, Int(4^4/4), 1)

(t_16,c_16) = autocor_loc_2(df_16[:,5].+df_16[:,6].*1.0im, 1, 16^2, 1)

sum(df_8[:,7])/length(df_8[:,5])


plot(layout=[1 1])

plot!((t_4.-1.0),real(c_4)/real(c_4[1]),label=L"L=4",xlabel = L"t/L^4")

plot!((t_8.-1.0),real(c_8)/real(c_8[1]),label=L"L=8",xlabel = L"t",xlim=(0,60))

plot!((t_4.-1.0)/4^(4-0),real(c_4)/real(c_4[1]),label=L"L=4",xlabel = L"t/L^4",sp=2)

plot!((t_8.-1.0)/8^(4-0),real(c_8)/real(c_8[1]),label=L"L=8",xlabel = L"t/L^4",sp=2,xlim=(0,0.25))



savefig("ModelB.pdf")
