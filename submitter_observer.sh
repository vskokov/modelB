
setenv JULIA_DEPOT_PATH /usr/local/usrapps/gluonsaturation/julia

path=`pwd`
 
for L in 24 32; do 
for ser in `seq 1 2 3`; do 
for id in `seq 1 16`; do 


TMPFILE=`mktemp tmp.XXXXXXXXXXXX`
cp run_long.sh $TMPFILE
 echo "julia -t 16 modelB_observer.jl  $id $L  $ser >  /rsstu/users/v/vskokov/gluon/criticaldynamic/tmp/dump.tmp"  >> $TMPFILE 
 echo "rm $path/$TMPFILE "  >> $TMPFILE 
 chmod u+x $TMPFILE
 bsub < $TMPFILE
 
 
 
done
done
done
