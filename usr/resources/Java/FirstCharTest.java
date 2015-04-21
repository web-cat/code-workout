import java.util.Arrays;
import java.util.Collection;
import java.io.*;
import org.junit.*;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import org.junit.runner.RunWith;
import static org.junit.Assert.assertEquals;

@RunWith(Parameterized.class)
public class FirstCharTest{
  String num;
  char expectedResult;
  FirstChar f;
  static PrintWriter fout= null;
  static int cnt=0;
  
  @BeforeClass
  public static void fileInit() throws FileNotFoundException{
    fout = new PrintWriter("FirstChar_Java_results.csv");
  }
  

  @Before
  public void init() {
    cnt++;
    f= new FirstChar();
  } // init

  @Parameterized.Parameters
  public static Collection fibSet() {
    return Arrays.asList(new Object[][] {
{"Winter of the world",'W'},{"Summer storm",'S'}
    });
  } // Set()

   public FirstCharTest(String number, char comparison) {
     this.num = number;
     this.expectedResult = comparison;
   }// Test

   @Test
   public void testfirstchar() {
     System.out.println("The input under scrutiny is: "+num);
     if (expectedResult==f.firstchar(num))
       fout.println("1,,"+cnt);
     else
       fout.println("0,Test case failed,"+cnt);
     assertEquals(expectedResult,f.firstchar(num));
   }// testfirstchar()
  
   @AfterClass
   public static void fileClean(){
     if (fout!=null)
       fout.close();
   }

}// class
