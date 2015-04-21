import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class TwoAsOneTest{

        TwoAsOne f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("TwoAsOne_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new TwoAsOne();
		cnt++;
	} // init


	@Test
	public void testtwoAsOne1() {
		if ( f.twoAsOne(1,2,3) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(1,2,3),true);
}

	@Test
	public void testtwoAsOne2() {
		if ( f.twoAsOne(3,1,2) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(3,1,2),true);
}

	@Test
	public void testtwoAsOne3() {
		if ( f.twoAsOne(3,2,2) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(3,2,2),false);
}

	@Test
	public void testtwoAsOne4() {
		if ( f.twoAsOne(2,3,1) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(2,3,1),true);
}

	@Test
	public void testtwoAsOne5() {
		if ( f.twoAsOne(5,3,-2) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Are you handling negative numbers right?,"+cnt);
		assertEquals( f.twoAsOne(5,3,-2),true);
}

	@Test
	public void testtwoAsOne6() {
		if ( f.twoAsOne(5,3,-3) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Are you handling negative numbers right?,"+cnt);
		assertEquals( f.twoAsOne(5,3,-3),false);
}

	@Test
	public void testtwoAsOne7() {
		if ( f.twoAsOne(2,5,3) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(2,5,3),true);
}

	@Test
	public void testtwoAsOne8() {
		if ( f.twoAsOne(9,5,5) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(9,5,5),false);
}

	@Test
	public void testtwoAsOne9() {
		if ( f.twoAsOne(9,4,5) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(9,4,5),true);
}

	@Test
	public void testtwoAsOne10() {
		if ( f.twoAsOne(5,4,9) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(5,4,9),true);
}

	@Test
	public void testtwoAsOne11() {
		if ( f.twoAsOne(3,3,0) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(3,3,0),true);
}

	@Test
	public void testtwoAsOne12() {
		if ( f.twoAsOne(3,3,2) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple summation determination test failed,"+cnt);
		assertEquals( f.twoAsOne(3,3,2),false);
}

/*@Test
  public void testtwoAsOne() {
   if (expectedResult==f.twoAsOne(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(TwoAsOne.twoAsOne(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

