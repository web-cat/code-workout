import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class MultiplierTest{

        Multiplier f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("Multiplier_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new Multiplier();
		cnt++;
	} // init


	@Test
	public void testmultiply1() {
		if ( f.multiply(3,5) == 15 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Basic multiplication failed,"+cnt);
		assertEquals( f.multiply(3,5),15);
}

	@Test
	public void testmultiply2() {
		if ( f.multiply(3,4) == 12 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Basic multiplication failed,"+cnt);
		assertEquals( f.multiply(3,4),12);
}

	@Test
	public void testmultiply3() {
		if ( f.multiply(3,0) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Basic multiplication failed﻿,"+cnt);
		assertEquals( f.multiply(3,0),1);
}

/*@Test
  public void testmultiply() {
   if (expectedResult==f.multiply(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(Multiplier.multiply(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

