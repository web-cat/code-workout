#!/bin/bash

umask 002

cd /attempt
mkdir -p reports

# Perform syntax check of source files first
for fname in *.rb; do
  case $fname in
    *Test.rb) ;;
    *)
       ruby -c $fname 2>&1 | grep -v "Syntax OK" >> reports/compile.log 
      ;;
  esac
done

ruby *Test.rb --verbose=s

# clean up unneeded files
if [[ ! -s reports/compile.log ]]
then
  rm -f reports/compile.log
fi
