#!/bin/bash

# Install required packages
apt-get install -y --no-install-recommends wget ca-certificates unzip

# Retrieve test case files
mkdir -p /tmp/testfiles
wget -O /tmp/testfiles/test_files.zip https://github.com/phnmnl/container-openms/raw/develop/testfiles/test_files.zip
unzip /tmp/testfiles/test_files.zip -d /tmp/testfiles/

# Run command
FileFilter -in /tmp/testfiles/test_file_1.mzML -out /tmp/testfiles/test_file_result_1.mzML -rt 100:200

if [ ! -e /tmp/testfiles/test_file_result_1.mzML ]; then 
	echo "Could not create output file."
	exit 1
fi

