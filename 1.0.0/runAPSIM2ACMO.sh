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
zip -r -q $THISDIR/result/retIn_$batchId.zip *
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

threads=`nproc`
echo "detect $threads cores, will use $threads threads to run APSIM"

cat > $PWD/ApsimModel.sh << EOF
#!/bin/bash
if [ "\$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit
fi
file=\$1
while true; do
  filename="\${file%.*}"
  echo "Executing \$filename"
  $THISDIR/Model/ApsimModel.exe \$file >> \${filename}.sum 2>\${filename}.error
  errors=\`ls -al \${filename}.error | awk '{ if (\$5>95) { print \$9 }}'\`
  if [ "\$errors" == "" ];
  then
    break
  fi
done
EOF
chmod +x $PWD/ApsimModel.sh

for file in *.sim; do
{
  filename="${file%.*}"
  echo "Submitting $filename"
  sem -j $threads "$PWD/ApsimModel.sh $file"
} 
done
sem --wait

# Generate the output zip package for APSIM output files
mkdir $THISDIR/result/$batchId/output
mv -f *.out $THISDIR/result/$batchId/output
mv -f *.sum $THISDIR/result/$batchId/output
mv -f ACMO_meta.dat $THISDIR/result/$batchId/output
cd $THISDIR/result/$batchId/output
zip -r -q $THISDIR/result/retOut_$batchId.zip *
cd $THISDIR/result/$batchId

# Run ACMOUI
java -Xms256m -Xmx512m -jar $THISDIR/$acmoui -cli -apsim "output" "$THISDIR/result/$batchId/output"  2>&1 1>$THISDIR/result/$batchId/acmoui.output
cp -f $THISDIR/result/$batchId/output/*.csv $THISDIR/result/$batchId.csv
