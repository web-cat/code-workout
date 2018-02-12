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
#Current makefile location: /vagrant/usr/resources/Cpp
#
#Examples:
#   make -C/vagrant/usr/resources/Cpp SRC_DIR=$PWD
#   make -C/vagrant/usr/resources/Cpp all SRC_DIR=$PWD
#   make -C/vagrant/usr/resources/Cpp clean SRC_DIR=$PWD
#   docker run -ti -v $(pwd):$(pwd) -v /vagrant/usr/resources/Cpp:/vagrant/usr/resources/Cpp:ro  -w $(pwd) codeworkout/cpp  bash
#
#   docker run -ti -v $(pwd):$(pwd) -v $(pwd)/../../../resources/Cpp/:/usr/resources/Cpp/:ro -w $(pwd) codeworkout/cpp  bash
#
#   docker run --rm -v $(pwd):$(pwd) -v $(pwd)/../../../resources/Cpp/:/usr/resources/Cpp/:ro  -w $(pwd) codeworkout/cpp make -C/usr/resources/Cpp SRC_DIR=$PWD
#---------------------------------------------------------------------------------------

#Variables
SRC_FILES := $(wildcard $(SRC_DIR)/*.cpp)
TEST_FILES := $(wildcard $(SRC_DIR)/*Test.cpp)
SRC_FILES := $(filter-out $(TEST_FILES),$(SRC_FILES))
OBJ_DIR := $(SRC_DIR)
OBJ_FILES := $(patsubst $(SRC_DIR)/%.cpp,$(SRC_DIR)/%.o,$(SRC_FILES))
TESTGEN := /usr/local/cxxtest/bin/cxxtestgen
CXXTEST := /usr/local/cxxtest/codeworkout
TIMEOUT := timeout 10s

all: compile_code run_tests

compile_code: $(SRC_DIR)/reports $(OBJ_FILES)

#Create folder for reports
$(SRC_DIR)/reports:
	mkdir $(SRC_DIR)/reports

#Compile student's code
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) -c -o $@ $< >> $(SRC_DIR)/reports/compile.log 2>> $(SRC_DIR)/reports/compile.log

# A rule that runs the unit tests
run_tests: $(SRC_DIR)/runner
	$(TIMEOUT) $(SRC_DIR)/runner > $(SRC_DIR)/results.csv 2>> $(SRC_DIR)/results.csv \
	|| (ret=$$?; rm -f $(SRC_DIR)/results.csv && exit $$ret)

#Build the test runner
$(SRC_DIR)/runner: $(SRC_DIR)/runner.cpp
	$(CXX) -I$(CXXTEST) -I. -o $@ $< \
	        >> $(SRC_DIR)/reports/compile.log \
	        2>> $(SRC_DIR)/reports/compile.log

#generate the test runner
$(SRC_DIR)/runner.cpp: $(TEST_FILES)
	$(TESTGEN) --runner=XmlPrinter -o $@ --template runner.tpl $^

clean:
	rm  -f \
			$(SRC_DIR)/*.o\
			$(SRC_DIR)/runner \
			$(SRC_DIR)/runner.cpp \
			$(SRC_DIR)/results.csv \
			$(SRC_DIR)/err.log
	rm  -fr $(SRC_DIR)/reports
