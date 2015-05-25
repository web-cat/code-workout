import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class FactorialTest
{
    Factorial subject;
  
  	@Before
	public void setUp()
  	{
        subject = new Factorial();
	}

  	    @Test
    public void test7()
    {
        assertEquals(
          "",
          1,
          subject.factorial(0));
    }
    @Test
    public void test8()
    {
        assertEquals(
          "",
          1,
          subject.factorial(1));
    }
    @Test
    public void test9()
    {
        assertEquals(
          "",
          2,
          subject.factorial(2));
    }
    @Test
    public void test10()
    {
        assertEquals(
          "",
          6,
          subject.factorial(3));
    }
    @Test
    public void test11()
    {
        assertEquals(
          "",
          24,
          subject.factorial(4));
    }
    @Test
    public void test12()
    {
        assertEquals(
          "",
          120,
          subject.factorial(5));
    }

}
