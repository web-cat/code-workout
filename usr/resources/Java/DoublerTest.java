import java.util.Arrays;
import java.util.Collection;
import java.io.*;
import org.junit.*;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import org.junit.runner.RunWith;
import static org.junit.Assert.assertEquals;

@RunWith(Parameterized.class)
public class DoublerTest{
  int num;
  int expectedResult;
  Doubler f;
  static PrintWriter fout= null;
  static int cnt=0;
  
  @BeforeClass
  public static void fileInit() throws FileNotFoundException{
    fout = new PrintWriter("Doubler_Java_results.csv");
  }
  

  @Before
  public  void init() {
    cnt++;
    f= new Doubler();
  } // init

  @Parameterized.Parameters
  public static Collection fibSet() {
    return Arrays.asList(new Object[][] {
{2,4},{3,6}
    });
  } // Set()

   public DoublerTest(int number, int comparison) {
     this.num = number;
     this.expectedResult = comparison;
   }// Test

   @Test
   public void testdoubler() {
     System.out.println("The input under scrutiny is: "+num);
     if (expectedResult==f.doubler(num))
       fout.println("1,,"+cnt);
     else
       fout.println("0,Test case failed,"+cnt);
     assertEquals(expectedResult,f.doubler(num));
   }// testdoubler()
  
   @AfterClass
   public static void fileClean(){
     if (fout!=null)
       fout.close();
   }

}// class
