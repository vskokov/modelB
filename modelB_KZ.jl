cd(@__DIR__)

using Plots
using Distributions
using Printf
using BenchmarkTools
using StaticArrays
using FFTW
using Random 
using JLD2

const λ = 4.0e0
const Γ = 1.0e0
const T = 1.0e0

const Δt = 0.04e0/Γ
const Rate = Float64(sqrt(2.0*Δt*Γ))
ξ = Normal(0.0e0, 1.0e0)



Random.seed!(parse(Int,ARGS[1])^2 * parse(Int,ARGS[3])^3 )

### Lattice Size
const L = parse(Int,ARGS[2])
### end  


function hotstart(n)
    rand(ξ, n, n, n)
end

function ΔH(x, ϕ,  Δϕ, m²)
    @inbounds ϕold = ϕ[x[1], x[2], x[3]]
    ϕt = ϕold +  Δϕ 
    Δϕ² = ϕt^2 - ϕold^2

    @inbounds ∑nn = ϕ[x[1]%L+1, x[2], x[3]] + ϕ[x[1], x[2]%L+1, x[3]] + ϕ[x[1], x[2], x[3]%L+1]
    @inbounds ∑nn += ϕ[(x[1]+L-2)%L+1, x[2], x[3]] + ϕ[x[1], (x[2]+L-2)%L+1, x[3]] + ϕ[x[1], x[2], (x[3]+L-2)%L+1]

    3Δϕ² - Δϕ * ∑nn + 0.5m² * Δϕ² + 0.25λ * (ϕt^4 - ϕold^4)
end


function step(m², ϕ, x1, x2)
    q = Rate*rand(ξ)

    @inbounds ϕ1 = ϕ[x1[1], x1[2], x1[3]]
    @inbounds ϕ2 = ϕ[x2[1], x2[2], x2[3]]

    δH = ΔH(x1, ϕ, q, m²) + ΔH(x2, ϕ, -q, m²) + q^2
    P = min(1.0f0, exp(-δH))
    r = rand(Float64)
	
	if (r < P)
        @inbounds ϕ[x1[1], x1[2], x1[3]] += q
        @inbounds ϕ[x2[1], x2[2], x2[3]] -= q
    end
end

function sweep(m², ϕ)
    for n in 0:2, m in 1:4
    
        Threads.@threads for k in 1:L   
            for i in 1:L÷4, j in 1:L
 				
				transition = [4(i-1)+2(j-1), j+k-2, k-1]

                x1 = transition[[(3-n)%3+1, (4-n)%3+1, (5-n)%3+1]]
                x1[n+1] += m%2
                x1[(n+1)%3+1] += m<3
				x2 = copy(x1)
                x2[n+1] += 1
                
				step(m², ϕ, x1.%L.+1, x2.%L.+1)
            end
        end
    end
end

function thermalize(m², ϕ, N=10000)
    for i in 1:N
	if ( mod(i,10)==0)
		println(i)
        	@time sweep(m², ϕ)
	end

        @time sweep(m², ϕ)
    end
end

M(ϕ) = sum(ϕ)/L^3

conf_file = "/share/gluonsaturation/transfer/modelB/KZ/IC_sym_L_32"*"_id_"*ARGS[1]*"_series_"*ARGS[3]*".jld2"

df = load(conf_file)

ϕ = df["ϕ"]
m²_init = df["m2"]

# decorrelate 
thermalize(m²_init, ϕ, floor(Int,2.0*0.001*L^3.9))

const maxt = L^4
const skip=10 

const tc=46.4
const m2c=-2.2859

function m2func(t)
	return m2c+(m2c-m²_init)*(t/tc-1.0) 
end

open("/rsstu/users/v/vskokov/gluon/criticaldynamic/modelB/KZ_$L"*"_id_"*ARGS[1]*"_series_"*ARGS[3]*"_subseries_"*ARGS[4]*".dat","w") do io 
	for i in 0:maxt
		real_time = i * Δt
		m2 = m2func(real_time) 
        	
		sweep(m2, ϕ)
				

		if ( mod(i,skip)==0)
	
			ϕk = fft(ϕ)
		
			Printf.@printf(io, "%f %f", real_time, m2)
			for kx in 1:L
				Printf.@printf(io, " %f %f", real(ϕk[kx,1,1]), imag(ϕk[kx,1,1]))
			end 

			Printf.@printf(io,  "\n")
			flush(io)
		end
		
		if (m2<-4.0)
			break
		end
	end
end
