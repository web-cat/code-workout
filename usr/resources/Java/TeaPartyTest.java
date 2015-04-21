import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class TeaPartyTest{

        TeaParty f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("TeaParty_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new TeaParty();
		cnt++;
	} // init


	@Test
	public void testteaParty1() {
		if ( f.teaParty(6,8) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt bad but isnt great either,"+cnt);
		assertEquals( f.teaParty(6,8),1);
}

	@Test
	public void testteaParty2() {
		if ( f.teaParty(3,8) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that good,"+cnt);
		assertEquals( f.teaParty(3,8),0);
}

	@Test
	public void testteaParty3() {
		if ( f.teaParty(20,6) == 2 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that bad,"+cnt);
		assertEquals( f.teaParty(20,6),2);
}

	@Test
	public void testteaParty4() {
		if ( f.teaParty(12,6) == 2 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that good,"+cnt);
		assertEquals( f.teaParty(12,6),2);
}

	@Test
	public void testteaParty5() {
		if ( f.teaParty(11,6) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt bad but isnt great either,"+cnt);
		assertEquals( f.teaParty(11,6),1);
}

	@Test
	public void testteaParty6() {
		if ( f.teaParty(11,4) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that good,"+cnt);
		assertEquals( f.teaParty(11,4),0);
}

	@Test
	public void testteaParty7() {
		if ( f.teaParty(4,5) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that good,"+cnt);
		assertEquals( f.teaParty(4,5),0);
}

	@Test
	public void testteaParty8() {
		if ( f.teaParty(5,5) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt bad but isnt great either,"+cnt);
		assertEquals( f.teaParty(5,5),1);
}

	@Test
	public void testteaParty9() {
		if ( f.teaParty(6,6) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt bad but isnt great either,"+cnt);
		assertEquals( f.teaParty(6,6),1);
}

	@Test
	public void testteaParty10() {
		if ( f.teaParty(5,10) == 2 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that good,"+cnt);
		assertEquals( f.teaParty(5,10),2);
}

	@Test
	public void testteaParty11() {
		if ( f.teaParty(5,9) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt bad but isnt great either,"+cnt);
		assertEquals( f.teaParty(5,9),1);
}

	@Test
	public void testteaParty12() {
		if ( f.teaParty(10,4) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that good,"+cnt);
		assertEquals( f.teaParty(10,4),0);
}

	@Test
	public void testteaParty13() {
		if ( f.teaParty(10,20) == 2 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Party isnt really that good,"+cnt);
		assertEquals( f.teaParty(10,20),2);
}

/*@Test
  public void testteaParty() {
   if (expectedResult==f.teaParty(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(TeaParty.teaParty(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

