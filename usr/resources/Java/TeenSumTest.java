import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class TeenSumTest{

        TeenSum f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("TeenSum_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new TeenSum();
		cnt++;
	} // init


	@Test
	public void testteenSum1() {
		if ( f.teenSum(3,4) == 7 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple addition failed,"+cnt);
		assertEquals( f.teenSum(3,4),7);
}

	@Test
	public void testteenSum2() {
		if ( f.teenSum(10,13) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(10,13),19);
}

	@Test
	public void testteenSum3() {
		if ( f.teenSum(13,2) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(13,2),19);
}

	@Test
	public void testteenSum4() {
		if ( f.teenSum(3,19) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(3,19),19);
}

	@Test
	public void testteenSum5() {
		if ( f.teenSum(13,13) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(13,13),19);
}

	@Test
	public void testteenSum6() {
		if ( f.teenSum(10,10) == 20 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple addition failed,"+cnt);
		assertEquals( f.teenSum(10,10),20);
}

	@Test
	public void testteenSum7() {
		if ( f.teenSum(6,14) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(6,14),19);
}

	@Test
	public void testteenSum8() {
		if ( f.teenSum(15,2) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(15,2),19);
}

	@Test
	public void testteenSum9() {
		if ( f.teenSum(19,19) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(19,19),19);
}

	@Test
	public void testteenSum10() {
		if ( f.teenSum(19,20) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(19,20),19);
}

	@Test
	public void testteenSum11() {
		if ( f.teenSum(2,18) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(2,18),19);
}

	@Test
	public void testteenSum12() {
		if ( f.teenSum(12,4) == 16 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple addition failed,"+cnt);
		assertEquals( f.teenSum(12,4),16);
}

	@Test
	public void testteenSum13() {
		if ( f.teenSum(2,20) == 22 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple addition failed,"+cnt);
		assertEquals( f.teenSum(2,20),22);
}

	@Test
	public void testteenSum14() {
		if ( f.teenSum(2,17) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(2,17),19);
}

	@Test
	public void testteenSum15() {
		if ( f.teenSum(2,16) == 19 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Teenage return failed,"+cnt);
		assertEquals( f.teenSum(2,16),19);
}

	@Test
	public void testteenSum16() {
		if ( f.teenSum(6,7) == 13 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple addition failed,"+cnt);
		assertEquals( f.teenSum(6,7),13);
}

/*@Test
  public void testteenSum() {
   if (expectedResult==f.teenSum(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(TeenSum.teenSum(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

