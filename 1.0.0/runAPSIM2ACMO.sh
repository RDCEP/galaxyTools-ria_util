batchId=$1

# To be sure...
cd $THISDIR/result/$batchId

# Run QuadUI
java -jar $THISDIR/$quadui -cli -clean -n -A 1.json $THISDIR/result/$batchId 2>&1 1>$THISDIR/quadui.output

# Setup Cultivar files
if [ -d "$THISDIR/cul/apsim_specific" ]
then
  cp -f $THISDIR/cul/apsim_specific/* $THISDIR/result/$batchId/APSIM/.
fi

# Generate output zip package for APSIM input files
cd $THISDIR/result/$batchId/APSIM
zip -r -q $THISDIR/retIn_$batchId.zip *
cd $THISDIR/result/$batchId

# Setup APSIM model
cp -f $THISDIR/result/$batchId/APSIM/* .

# Run APSIM model
mono $THISDIR/Model/ApsimToSim.exe AgMip.apsim 2>&1 1>$THISDIR/ApsimToSim.output #2>/dev/null
if [ -s $THISDIR/ApsimToSim.output ]
then 
  echo "AgMip.apsim ERROR"
  cat $THISDIR/ApsimToSim.output
  echo "-----------------------"
  exit 1
else
  echo "AgMip.apsim OK"
fi

tmp_fifofile="./control.fifo"
mkfifo $tmp_fifofile
exec 6<>$tmp_fifofile
rm $tmp_fifofile

thread=`cat /proc/cpuinfo | grep processor | wc -l`
echo "detect $thread cores, will use $thread threads to run APSIM"
for ((i=0;i<$thread;i++));do 
  echo
done >&6 

declare -i count
count=1
for file in *.sim; do
{
  read -u6
  filename="${file%.*}"
  $THISDIR/Model/ApsimModel.exe $file >> ${filename}.sum 2>/dev/null
  echo >&6
  count=$count+1
} &
done
wait
exec 6>&-

# Generate the output zip package for APSIM output files
mkdir $THISDIR/result/$batchId/output
mv -f *.out $THISDIR/result/$batchId/output
mv -f *.sum $THISDIR/result/$batchId/output
mv -f ACMO_meta.dat $THISDIR/result/$batchId/output
cd $THISDIR/result/$batchId/output
zip -r -q $THISDIR/retOut_$batchId.zip *
cd $THISDIR/result/$batchId

# Run ACMOUI
java -Xms256m -Xmx512m -jar $THISDIR/$acmoui -cli -apsim "output" "$THISDIR/result/$batchId/output"  2>&1 1>$THISDIR/acmoui.output
cp -f $THISDIR/output/*.csv $THISDIR/$batchId.csv
