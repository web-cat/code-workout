using namespace std;

#include <cxxtest/TestSuite.h>
#include "%{class_name}.cpp"

class %{class_name}Test : public CxxTest::TestSuite
{
    %{class_name} subject;
public:
    %{tests}

};


