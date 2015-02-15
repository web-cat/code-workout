import org.junit.*;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import org.junit.runner.RunWith;
import java.util.Arrays;
import java.util.Collection;
import java.io.*;
import static org.junit.Assert.assertEquals;

@RunWith(Parameterized.class)
public class FactorialTest{
  static PrintWriter fout = null;
  int num;
  static int cnt;
  int result;
  Factorial f;

  @BeforeClass
  public static void  fileInit() throws FileNotFoundException{
    fout =new PrintWriter("Factorial_Java_results.csv");
  }

  @Before
  public void init(){
    f = new Factorial();
  } 
  
  @Parameterized.Parameters
  public static Collection factorialSet() {
    return Arrays.asList(new Object[][]{
      {1,1},
      {2,2},
      {3,8},
      {4,24},
      {0,-1},
      {7,5040},
    });
  }//factorialSet() 

  public FactorialTest(int number, int res){
    this.num=number;
    this.result=res;
  }//constructor

  @Test
  public void testFactorialChecker(){
   cnt++;
   System.out.println("The number under scrutiny is: "+num);
   if (result==f.factorial(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Factorial unsuccessfully generated,"+cnt);
   assertEquals(result,f.factorial(num));
  }//testFactorialChecker

  @AfterClass
  public static void  fileClean(){
    if (fout!=null)
      fout.close();
  }
} 
