model=$1
folder="N/A"

# check selected model name
case $model in
  DSSAT) folder="dssat_specific" ;;
  APSIM) folder="apsim_specific" ;;
  *) echo "Invalid model name [$model], will skip the cultivar files preparation step" ;;
esac

# Prepare Cultivar files
if [ "$CultivarInput" != "N/A" ] && [ "$folder" != "N/A" ]
then
  cp -f $CultivarInput $PWD/cul.zip
  unzip -o -q cul.zip -d cul/
  if [ -d "$PWD/cul/$folder" ]
  then
    echo "Found $model cultivar files correctly"
    cd cul/$folder
    case $model in
      DSSAT) rename -v -f 'y/a-z/A-Z/' *.[Cc][Uu][Ll] ;;
      APSIM) rename -v -f 'y/A-Z/a-z/' *.[Xx][Mm][Ll] ;;
    esac
    
    
    cd ..
    cd ..
  else
    echo "[Warn] Could not find $folder diretory in the cultivar package, will using default cultivar loaded in the system"
  fi
fi