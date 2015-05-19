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
    public void test1()
    {
        assertEquals(
          "",
          1,
          subject.factorial(0));
    }
    @Test
    public void test2()
    {
        assertEquals(
          "",
          1,
          subject.factorial(1));
    }
    @Test
    public void test3()
    {
        assertEquals(
          "",
          2,
          subject.factorial(2));
    }
    @Test
    public void test4()
    {
        assertEquals(
          "",
          6,
          subject.factorial(3));
    }
    @Test
    public void test5()
    {
        assertEquals(
          "",
          24,
          subject.factorial(4));
    }
    @Test
    public void test6()
    {
        assertEquals(
          "",
          120,
          subject.factorial(5));
    }

}
