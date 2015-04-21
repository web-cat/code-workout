import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class NearTenTest{

        NearTen f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("NearTen_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new NearTen();
		cnt++;
	} // init


	@Test
	public void testnearTen1() {
		if ( f.nearTen(12) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(12),true);
}

	@Test
	public void testnearTen2() {
		if ( f.nearTen(17) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is not near 10,"+cnt);
		assertEquals( f.nearTen(17),false);
}

	@Test
	public void testnearTen3() {
		if ( f.nearTen(19) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(19),true);
}

	@Test
	public void testnearTen4() {
		if ( f.nearTen(31) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(31),true);
}

	@Test
	public void testnearTen5() {
		if ( f.nearTen(6) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is not near 10,"+cnt);
		assertEquals( f.nearTen(6),false);
}

	@Test
	public void testnearTen6() {
		if ( f.nearTen(10) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(10),true);
}

	@Test
	public void testnearTen7() {
		if ( f.nearTen(11) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(11),true);
}

	@Test
	public void testnearTen8() {
		if ( f.nearTen(21) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(21),true);
}

	@Test
	public void testnearTen9() {
		if ( f.nearTen(22) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(22),true);
}

	@Test
	public void testnearTen10() {
		if ( f.nearTen(23) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is not near 10,"+cnt);
		assertEquals( f.nearTen(23),false);
}

	@Test
	public void testnearTen11() {
		if ( f.nearTen(54) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is not near 10,"+cnt);
		assertEquals( f.nearTen(54),false);
}

	@Test
	public void testnearTen12() {
		if ( f.nearTen(155) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is not near 10,"+cnt);
		assertEquals( f.nearTen(155),false);
}

	@Test
	public void testnearTen13() {
		if ( f.nearTen(158) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 10,"+cnt);
		assertEquals( f.nearTen(158),true);
}

	@Test
	public void testnearTen14() {
		if ( f.nearTen(3) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is not near 10,"+cnt);
		assertEquals( f.nearTen(3),false);
}

	@Test
	public void testnearTen15() {
		if ( f.nearTen(1) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Modulus is actually near 0,"+cnt);
		assertEquals( f.nearTen(1),true);
}

/*@Test
  public void testnearTen() {
   if (expectedResult==f.nearTen(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(NearTen.nearTen(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

