input=$1

# default version setting
version=7.7

# check selected version of APSIM
case $input in
  7.5) version=$input ;;
  7.7) version=$input ;;
  *) echo "Invalid APSIM version, will use default version $version" ;;
esac

# Setup APSIM model
tar xfz /mnt/galaxyTools/apsim_ria/model/$version/apsim.tar.gz
APSIMDIR=$PWD
export LD_LIBRARY_PATH=$APSIMDIR:$APSIMDIR/Model:$APSIMDIR/Files:$LD_LIBRARY_PATH
export PATH=$APSIMDIR:$APSIMDIR/Model:$APSIMDIR/Files:$PATH