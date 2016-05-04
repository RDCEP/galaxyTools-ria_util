# Setup QuadUI
#INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_DIR=/mnt/galaxyTools/quadui/1.3.6
quadui=quadui-1.3.7-faceit.jar
ln -sf $INSTALL_DIR/$quadui

# Setup ACMOUI
INSTALL_DIR=/mnt/galaxyTools/acmoui/1.2
acmoui=acmoui-1.2-SNAPSHOT-beta7.jar
ln -sf $INSTALL_DIR/$acmoui .
