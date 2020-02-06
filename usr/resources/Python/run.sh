#!/bin/bash

cd /attempt
mkdir -p reports

# Perform syntax check of source files first
for fname in *.py; do
  case $fname in
    *Test.py) ;;
    *)
       python -c "import ast; ast.parse(open('$fname').read())" \
         >> reports/compile.log 2>&1
      ;;
  esac
done

# pytest -c /resources/pytest.ini *Test.py > pytest.log 2>> reports/compile.log
python /resources/_runner.py >> reports/compile.log 2>&1

# clean up unneeded files
rm -rf __pycache__
if [[ ! -s reports/compile.log ]]
then
  rm reports/compile.log
fi
