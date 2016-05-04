batchId=$1

# Run QuadUI
java -jar ../../$quadui -cli -clean -n -A 1.json $PWD

# Setup Cultivar files
if [ -d "../../cul/apsim_specific" ]
then
  cp -f ../../cul/apsim_specific/* $PWD/APSIM/.
fi

# Generate output zip package for APSIM input files
cd APSIM
zip -r -q ../../retIn_$batchId.zip *
cd ..

# Setup APSIM model
cp -f $PWD/APSIM/* .

# Run APSIM model
mono ../../Model/ApsimToSim.exe AgMip.apsim 2>/dev/null

tmp_fifofile="./control.fifo"
mkfifo $tmp_fifofile
exec 6<>$tmp_fifofile
rm $tmp_fifofile

thread=`cat /proc/cpuinfo | grep processor | wc -l`
echo "detect $thread cores, will use $thread threads to run APSIM"
for ((i=0;i<$thread;i++));do 
  echo
done >&6 

for file in *.sim; do
{
  read -u6
  filename="${file%.*}"
  ../../Model/ApsimModel.exe $file >> $filename.sum 2>/dev/null
  echo >&6
} &
done
wait
exec 6>&-

# Generate the output zip package for APSIM output files
mkdir output
mv -f *.out output
mv -f *.sum output
mv -f ACMO_meta.dat output
cd output
zip -r -q ../../retOut_$batchId.zip *
cd ..

# Run ACMOUI
java -Xms256m -Xmx512m -jar ../../$acmoui -cli -apsim "output" "$PWD/output"
cp -f output/*.csv ../$batchId.csv