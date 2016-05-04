batchId=$1

# Run QuadUI
java -jar ../../$quadui -cli -clean -n -D 1.json $PWD

# Setup Cultivar files
if [ -d "../../cul/dssat_specific" ]
then
  cp -f ../../cul/dssat_specific/* $PWD/DSSAT/.
fi

# Generate output zip package for DSSAT input files
cd DSSAT
zip -r -q ../../retIn_$batchId.zip *
cd ..

# Setup DSSAT model
cp -f ../../dssat_aux/* .
cp -f $PWD/DSSAT/* .
if [ -d "../../cul/dssat_specific" ]
then
  cp -f ../../cul/dssat_specific/* $PWD/DSSAT/.
fi

# Run DSSAT model
./DSCSM045.EXE b DSSBatch.v45 DSCSM045.CTR 

# Generate the output zip package for DSSAT output files
mkdir output
mv -f *.OUT output
mv -f ACMO_meta.dat output
cd output
zip -r -q ../../retOut_$batchId.zip *
cd ..

# Run ACMOUI
java -Xms256m -Xmx512m -jar ../../$acmoui -cli -dssat "output" "$PWD/output"
cp -f output/*.csv ../$batchId.csv