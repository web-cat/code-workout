import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class %{class_name}Test extends codeworkout.CodeWorkoutTest
{
    %{class_name} subject;
  
    @Before
    public void setUp()
    {
        subject = new %{class_name}();
    }

    %{tests}

}
