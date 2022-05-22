#!/bin/tcsh
#BSUB -W 120
#BSUB -n 16
#BSUB -R span[hosts=1] 
#BSUB -o /rsstu/users/v/vskokov/gluon/tmp/out.%J
#BSUB -e /rsstu/users/v/vskokov/gluon/tmp/err.%J
setenv JULIA_DEPOT_PATH /usr/local/usrapps/gluonsaturation/julia
module load julia
