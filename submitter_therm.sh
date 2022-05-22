
setenv JULIA_DEPOT_PATH /usr/local/usrapps/gluonsaturation/julia

path=`pwd`
 
for id in `seq 1 16`; do 

TMPFILE=`mktemp tmp.XXXXXXXXXXXX`
 cp run_long.sh $TMPFILE
 echo "julia -t 16 modelB_thermalizer.jl  $id 16  >  /rsstu/users/v/vskokov/gluon/criticaldynamic/tmp/mBth16.$id"  >> $TMPFILE 
 echo "rm $path/$TMPFILE "  >> $TMPFILE 
 chmod u+x $TMPFILE
 bsub < $TMPFILE

TMPFILE=`mktemp tmp.XXXXXXXXXXXX`
cp run_long.sh $TMPFILE
 echo "julia -t 16 modelB_thermalizer.jl  $id 24  >  /rsstu/users/v/vskokov/gluon/criticaldynamic/tmp/mBth24.$id"  >> $TMPFILE 
 echo "rm $path/$TMPFILE "  >> $TMPFILE 
 chmod u+x $TMPFILE
 bsub < $TMPFILE


TMPFILE=`mktemp tmp.XXXXXXXXXXXX`
cp run_long.sh $TMPFILE
 echo "julia -t 16 modelB_thermalizer.jl  $id 32  >  /rsstu/users/v/vskokov/gluon/criticaldynamic/tmp/mBth32.$id"  >> $TMPFILE 
 echo "rm $path/$TMPFILE "  >> $TMPFILE 
 chmod u+x $TMPFILE
 bsub < $TMPFILE
 
 
 
done
