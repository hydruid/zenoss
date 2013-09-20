#!/bin/bash
#######################################################
#   Notes: Trying to compile with different libs      #
#######################################################

. /home/zenoss/zenoss424-srpm_install/variables.sh

# Install Zenoss Core
tar zxvf $INSTALLDIR/zenoss_core-4.2.4/externallibs/rrdtool-1.4.7.tar.gz -C $INSTALLDIR/ && cd $INSTALLDIR/rrdtool-1.4.7
./configure --prefix=$ZENHOME
make && make install
wget -N http://dev.zenoss.org/svn/tags/zenoss-4.2.4/inst/rrdclean.sh -P $INSTALLDIR/zenoss_core-4.2.4/ && cd $INSTALLDIR/zenoss_core-4.2.4/
./configure LDFLAGS=-L/var/chroot/precise/lib/x86_64-linux-gnu 2>&1 | tee log-configure.log
exit 0
make 2>&1 | tee log-make.log
make clean 2>&1 | tee log-make_clean.log
cp mkzenossinstance.sh mkzenossinstance.sh.orig
su - root -c "sed -i 's:# configure to generate the uplevel mkzenossinstance.sh script.:# configure to generate the uplevel mkzenossinstance.sh script.\n#\n#Custom Ubuntu Variables\n. /home/zenoss/zenoss424-srpm_install/variables.sh:g' $INSTALLDIR/zenoss_core-4.2.4/mkzenossinstance.sh"
./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_a.log
./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_b.log
chown -R zenoss:zenoss $ZENHOME
