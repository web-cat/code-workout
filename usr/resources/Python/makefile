#---------------------------------------------------------------------------------------
#Makefile for compiling and testing students' code
#
#Use:
#   1. Change to the directory where the source code is located
#   2. make -C[location of makefile] [target = all|clean] SRC_DIR=$PWD
#
#Targets:
#    all: compile and test the code.
#    clean: remove the generated files
#
#Current makefile location: /vagrant/usr/resources/Python
#---------------------------------------------------------------------------------------

#Variables
TEST_FILES := $(wildcard $(SRC_DIR)/*Test.py)
PYTEST := pytest

all: run_tests

# A rule that runs the unit tests
run_tests: $(SRC_DIR)/reports
	if $(PYTEST) $(CURDIR) $(TEST_FILES) > $(SRC_DIR)/results.csv 2>> $(SRC_DIR)/results.csv;\
	then \
		echo "All tests were collected and passed successfully"; \
	else \
		code=$$?; \
		err=0; \
		case "$$code" in \
		"1") \
			echo "Tests were collected and run but some of the tests failed"; \
			;; \
		"2") \
			echo "Test execution was interrupted by the user"; \
			err=1; \
			;; \
		"3") \
			echo "Internal error happened while executing tests"; \
			err=1; \
			;; \
		"4") \
			echo "pytest command line usage error"; \
			err=1; \
			;; \
		"5") \
			echo "No tests were collected"; \
			;; \
		esac; \
		if [ $$err -eq 1 ]; \
		then \
			cat $(SRC_DIR)/results.csv > $^/compile.log; \
			rm -f $(SRC_DIR)/results.csv; \
		fi; \
	fi;

#Create folder for reports
$(SRC_DIR)/reports:
	mkdir $@
	touch $@/compile.log

clean:
	rm  -f \
			$(SRC_DIR)/results.csv \
			$(SRC_DIR)/err.log
	rm  -fr $(SRC_DIR)/reports
