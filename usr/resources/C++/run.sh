#!/bin/bash

umask 002

cd /attempt
mkdir -p reports

# make -C /resources SRC_DIR=/attempt

/usr/local/cxxtest/bin/cxxtestgen --runner=XmlPrinter \
  -o runner.cpp --template /resources/runner.tpl *Test.cpp
g++ -I/usr/local/cxxtest/codeworkout -I. -o runner *.cpp \
  >> reports/compile.log  2>> reports/compile.log
timeout 5s ./runner > results.csv 2>> results.csv \
  || (ret=$?; rm -f results.csv && exit $ret)

# clean up unneeded files
rm -f *.o runner*
if [[ ! -s reports/compile.log ]]
then
  rm -f reports/compile.log
fi
