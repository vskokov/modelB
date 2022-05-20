cd("/rsstu/users/v/vskokov/gluon/criticaldynamic/modelB/")

using Statistics
using Distributions
using Random
using DelimitedFiles
using StatsBase
using Glob
using Bootstrap


function average_n(n, df)
	l =  length(df[1,:])
	res = zeros( ComplexF64, l)
	err = zeros( ComplexF64, l)

        n_boot = 30
	for i in 1:l
		bs = Bootstrap.bootstrap( x -> sum( (x.*conj.(x)).^(n-1) )/length(x) , df[:,i], BasicSampling(n_boot))
		err[i] = stderror(bs)[1]
		res[i] = bs.t0[1]
	end
	(res,err)
end

function load_df(pattern, momentum_mode)
	list = glob(pattern)
	df = readdlm(list[1],',')
	l = length(df[:,1])

	df_all = zeros(ComplexF64, (length(list),l))

        for (i,fname) in enumerate(list)
		df = readdlm(fname,' ')
		df_all[i,:] .= df[:,momentum_mode+4] .+ df[:,momentum_mode+5]*1.0im 
	end
	df_all
end


function autocor_loc_2(x, beg, max, n=2)
	C = zeros(ComplexF64,max+1)
	N = zeros(Int64,max+1)
	Threads.@threads for tau in 0:max
		for i in beg:length(x)-max
			j = i + tau
			@inbounds @fastmath  C[tau+1] = C[tau+1] +  (x[i]*conj(x[j]))^n
			@inbounds @fastmath  N[tau+1] = N[tau+1] + 1
		end
	end
	(collect(1:max+1).-1,  real(C) ./ N)
end

function correlation_2(name,max,n=2)
	df = readdlm(name,' ')
	out = autocor_loc_2(df[:,5].+1.0im.*df[:,6],1,max,n)
	out
end


function average(x)
  sum(x)/length(x)
end

function variance(x)
  S=zeros(length(x[1]))
  mean = average(x)
  println(length(x))
  for i in 1:length(x)
    S .= S .+ (x[i] .- mean) .^2
  end
  S./length(x)
end


function bootstrap_arr(db, M)
  bs=[]
  for i in 1:M
    dbBS = []
    for j in 1:length(db)
      idx=rand(1:length(db))
      push!(dbBS, db[idx])
    end
    push!(bs,average(dbBS))
  end

  mean = average(bs)
  var = variance(bs)
  (mean,sqrt.(var))
end



function Bootstrap_corr(n,pattern,fun,p=2)
	list = glob(pattern)
	DB = []
	for i in list
		try
			f = open(i,"r")
			close(f)
		catch err
			continue
		end

		(tau_,dyn_) = fun(i,n,p)
		push!(DB,dyn_)
	end
	(bs,err)=bootstrap_arr(DB,100)
	(bs,err)
end



n8=floor(Int, 8^4/4/10)
(C_8,Cerr_8)=Bootstrap_corr(n8,"Dynamics_8_*",correlation_2,1)

x=(collect(1:length(C_8)) .-1 ).*10

output_file = open("output_c2_8.jl","w") # this will create a file named output_file.jl, where we will write the data.

write(output_file, "t_8 = ") 
show(output_file, x) 
write(output_file, "; \n \n")

write(output_file, "C_8 = ") 
show(output_file, C_8) 
write(output_file, "; \n \n")

write(output_file, "Cerr_8 = ") 
show(output_file, real(Cerr_8)) 
write(output_file, "; \n \n")

write(output_file, "plot(t_8/8^4,C_8./C_8[1],ribbon=Cerr_8./C_8[1]); \n \n")





close(output_file)



