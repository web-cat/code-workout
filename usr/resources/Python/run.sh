#!/bin/bash

cd /attempt
mkdir -p reports

for fname in *.py; do
  case $fname in
    *Test.py) ;;
    *)
       python -c "import ast; ast.parse(open('$fname').read())" \
         >> reports/compile.log 2>&1
      ;;
  esac
done

pytest -c /resources/pytest.ini *Test.py > results.csv 2>> reports/compile.log
