#!/bin/bash
# nexusdeb builds a debian package of the Nexus repository manager. nexusdeb
# downloads nexus by itself. You run it by
#   nexusdeb.sh <version> <maintainer>
# Example:
#   nexusdeb.sh 2.0.5 "Denny Colt <d.colt@eisner.qcg>"
#
# The script has been tested with version 2.0.5.

if [ -z $1 ]
then
	echo "Usage: nexusdeb.sh <Version> <Maintainer>"
	echo -e "Example: nexusdeb.sh 2.0.5 \"Denny Colt <d.colt@eisner.qcg>\""
	exit 1
fi

if [ -z $2 ]
then
	echo "The maintainer is missing. Please provide it as second argument."
	exit 1
fi

export DEBEMAIL=$2

set -e

wget http://www.sonatype.org/downloads/nexus-${1}.war
mkdir nexus-${1}
unzip nexus-${1}.war -d nexus-${1}
rm nexus-${1}.war
echo '<Context path="/nexus" docBase="/usr/share/nexus/nexus-${1}"/>' > nexus-${1}/nexus.xml
tar -czf nexus_${1}.orig.tar.gz nexus-${1}
cd nexus-${1}

mkdir debian

#create changelog
dch --create -v ${1} --package nexus "Created from nexus-${1}.war via nexusdeb.sh"

echo 8 > debian/compat

echo "Source: nexus" > debian/control
echo "Maintainer: $2" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.3" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "Homepage: http://www.sonatype.org/" >> debian/control
echo "" >> debian/control
echo "Package: nexus" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: tomcat7, oracle-java7-installer, \${misc:Depends}" >> debian/control
echo "Description: Repository manager for development teams." >> debian/control
echo " Nexus sets the standard for repository management providing" >> debian/control
echo " development teams with the ability to proxy remote" >> debian/control
echo " repositories and share software artifacts." >> debian/control

echo "Sonatype Nexus™ Open Source Version" >> debian/copyright
echo "" >> debian/copyright
echo "Copyright © 2008-2012 Sonatype, Inc." >> debian/copyright
echo "" >> debian/copyright
echo "All rights reserved. Includes the third-party code listed at http://links.sonatype.com/products/nexus/oss/attributions." >> debian/copyright
echo "This program and the accompanying materials are made available under the terms of the Eclipse Public License Version 1.0, which accompanies this distribution and is available at http://www.eclipse.org/legal/epl-v10.html." >> debian/copyright
echo "" >> debian/copyright
echo 'Sonatype Nexus™ Professional Version is available from Sonatype, Inc. "Sonatype" and "Sonatype Nexus" are trademarks of Sonatype, Inc. Apache Maven is a trademark of the Apache Software Foundation. M2eclipse is a trademark of the Eclipse Foundation. All other trademarks are the property of their respective owners.' >> debian/copyright

echo "ext-2.3 usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "images usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "js usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "META-INF usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "nexus usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "style usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "WEB-INF usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "digestapplet.jar usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "favicon.ico usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "LICENSE.txt usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "robots.txt usr/share/nexus/nexus-${1}" >> debian/nexus.install
echo "nexus.xml /etc/tomcat7/Catalina/localhost/" >> debian/nexus.install

echo "#!/usr/bin/make -f" >> debian/rules
echo "%:" >> debian/rules
echo -e "\tdh \$@" >> debian/rules

mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format

debuild -us -uc

#clean up
cd ..
rm -rf nexus-${1}
rm *.build
rm *.changes
rm *.tar.gz
rm *.dsc