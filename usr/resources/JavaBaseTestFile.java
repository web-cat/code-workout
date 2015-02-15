import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class baseclassclassTest{

        baseclassclass f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("baseclassclass_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new baseclassclass();
		cnt++;
	} // init

TTTTT
/*@Test
  public void testmethodnameemandohtem() {
   if (expectedResult==f.methodnameemandohtem(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(baseclassclass.methodnameemandohtem(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

