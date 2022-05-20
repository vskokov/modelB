cd(@__DIR__)

using Plots
using Distributions
using Printf
using BenchmarkTools
using FFTW
using Random 
using JLD2

const λ = 4.0e0
const Γ = 1.0e0
const T = 1.0e0



Random.seed!(parse(Int,ARGS[1]))

const Δt = 0.04e0/Γ
const Rate = Float64(sqrt(2.0*Δt*Γ))
ξ = Normal(0.0e0, 1.0e0)


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
        sweep(m², ϕ)
    end
end

m² = -2.28587

ϕ = hotstart(L)
ϕ .= ϕ .- shuffle(ϕ)

maxt = L^2

for i in 1:maxt
	thermalize(m², ϕ, 100*L^2)
	@show i
	jldsave("/rsstu/users/v/vskokov/gluon/criticaldynamic/modelB/FC_L_"*string(L)*"_id_"*ARGS[1]*".jld2", true; ϕ=ϕ, m2=m² )
end 

## Intermidiates saving is to preserve the data if the programs times out on HPC 
