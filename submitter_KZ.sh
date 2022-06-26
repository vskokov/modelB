
setenv JULIA_DEPOT_PATH /usr/local/usrapps/gluonsaturation/julia

path=`pwd`
 
for L in 32; do 
for id in `seq 1 16`; do 
for ser in `seq 1 16`; do 
for subser in `seq 1 32`; do 


TMPFILE=`mktemp tmp.XXXXXXXXXXXX`
cp run_vshort.sh $TMPFILE
 
 echo "julia -t 16 modelB_KZ.jl  $id $L  $ser $subser > tmp/$id.dat"  >> $TMPFILE 
 echo "rm $path/$TMPFILE "  >> $TMPFILE 
 chmod u+x $TMPFILE
 bsub < $TMPFILE

done 
done
done
done
