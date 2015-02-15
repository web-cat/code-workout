import java.util.Arrays;
import java.util.Collection;
import java.io.*;
import org.junit.*;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import org.junit.runner.RunWith;
import static org.junit.Assert.assertEquals;

@RunWith(Parameterized.class)
public class FibonacciTest{
  int num;
  static int cnt;
  boolean expectedResult;
  Fibonacci f;
  static PrintWriter fout= null;

  @BeforeClass
  public static void fileInit() throws FileNotFoundException{
    fout = new PrintWriter("Fibonacci_Java_results.csv");
  }
  

  @Before
  public void init() {
    f= new Fibonacci();
  } // init

  @Parameterized.Parameters
  public static Collection fibSet() {
    return Arrays.asList(new Object[][] {
      {1,true},
      {3,true},
      {6,false},
      {9,false},
      {13,true},
      {15,false},
      {21,true}
    });
  } // fibSet()

   public FibonacciTest(int number, boolean comparison) {
     this.num = number;
     this.expectedResult = comparison;
   }// FibonacciTest

   @Test
   public void testFibonacciChecker() {
     cnt++;
     System.out.println("The number under scrutiny is: "+num);
     if (expectedResult==f.fibonacciChecker(num))
       fout.println("1,,"+cnt);
     else
       fout.println("0,Fibonacci test unsuccessful,"+cnt);
     assertEquals(expectedResult,f.fibonacciChecker(num));
   }// testFibonacciChecker()
  
   @AfterClass
   public static void fileClean(){
     if (fout!=null)
       fout.close();
   }

}// class
