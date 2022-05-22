
setenv JULIA_DEPOT_PATH /usr/local/usrapps/gluonsaturation/julia

path=`pwd`
 
for id in `seq 1 16`; do 


TMPFILE=`mktemp tmp.XXXXXXXXXXXX`
cp run_therm.sh $TMPFILE
 echo "julia -t 16 modelB_thermalizer.jl  $id 8  >  /rsstu/users/v/vskokov/gluon/criticaldynamic/tmp/mBth8.$id"  >> $TMPFILE 
 echo "rm $path/$TMPFILE "  >> $TMPFILE 
 chmod u+x $TMPFILE
 bsub < $TMPFILE
 
 
 
done
