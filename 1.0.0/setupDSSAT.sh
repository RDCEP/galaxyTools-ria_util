input=$1

# default version setting
version=4.5

# check selected version of DSSAT
case $input in
  4.5) version=$input ;;
  4.6) version=$input ;;
  *) echo "Invalid DSSAT version, will use default version $version" ;;
esac

# Setup DSSAT model
INSTALL_DIR=/mnt/galaxyTools/dssat_ria/model/$version
cp $INSTALL_DIR/dssat_aux.tgz dssat_aux.tgz
tar xvzf dssat_aux.tgz