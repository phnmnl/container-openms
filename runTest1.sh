#!/bin/bash

# install required packages
apt-get update -y && apt-get install -y --no-install-recommends wget ca-certificates unzip

# retrieve test case files
mkdir /tmp/testfiles
wget -O /tmp/testfiles/test_files.zip https://github.com/phnmnl/container-openms/raw/develop/testfiles/test_files.zip
unzip /tmp/testfiles/test_files.zip -d /tmp/testfiles/

# run command
FileFilter -in /tmp/testfiles/test_file_1.mzML -out /tmp/testfiles/test_file_result_1.mzML -rt 100:200

if [ ! -e /tmp/testfiles/IDResult.mzML ]
then 
	echo "Could not create output file."
	exit 1
fi

rm -rf /tmp/testfiles/
