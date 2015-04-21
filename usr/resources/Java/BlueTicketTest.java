import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class BlueTicketTest{

        BlueTicket f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("BlueTicket_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new BlueTicket();
		cnt++;
	} // init


	@Test
	public void testblueTicket1() {
		if ( f.blueTicket(9,1,0) == 10 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize a jackpot,"+cnt);
		assertEquals( f.blueTicket(9,1,0),10);
}

	@Test
	public void testblueTicket2() {
		if ( f.blueTicket(9,2,0) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery test failed,"+cnt);
		assertEquals( f.blueTicket(9,2,0),0);
}

	@Test
	public void testblueTicket3() {
		if ( f.blueTicket(6,1,4) == 10 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize a jackpot,"+cnt);
		assertEquals( f.blueTicket(6,1,4),10);
}

	@Test
	public void testblueTicket4() {
		if ( f.blueTicket(6,1,5) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery test failed,"+cnt);
		assertEquals( f.blueTicket(6,1,5),0);
}

	@Test
	public void testblueTicket5() {
		if ( f.blueTicket(10,0,0) == 10 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize a jackpot,"+cnt);
		assertEquals( f.blueTicket(10,0,0),10);
}

	@Test
	public void testblueTicket6() {
		if ( f.blueTicket(15,0,5) == 5 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize winnings,"+cnt);
		assertEquals( f.blueTicket(15,0,5),5);
}

	@Test
	public void testblueTicket7() {
		if ( f.blueTicket(5,15,5) == 10 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize a jackpot,"+cnt);
		assertEquals( f.blueTicket(5,15,5),10);
}

	@Test
	public void testblueTicket8() {
		if ( f.blueTicket(4,11,1) == 5 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize winnings,"+cnt);
		assertEquals( f.blueTicket(4,11,1),5);
}

	@Test
	public void testblueTicket9() {
		if ( f.blueTicket(13,2,3) == 5 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize winnings,"+cnt);
		assertEquals( f.blueTicket(13,2,3),5);
}

	@Test
	public void testblueTicket10() {
		if ( f.blueTicket(8,4,3) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery test failed,"+cnt);
		assertEquals( f.blueTicket(8,4,3),0);
}

	@Test
	public void testblueTicket11() {
		if ( f.blueTicket(8,4,2) == 10 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize a jackpot,"+cnt);
		assertEquals( f.blueTicket(8,4,2),10);
}

	@Test
	public void testblueTicket12() {
		if ( f.blueTicket(8,4,1) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery test failed,"+cnt);
		assertEquals( f.blueTicket(8,4,1),0);
}

/*@Test
  public void testblueTicket() {
   if (expectedResult==f.blueTicket(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(BlueTicket.blueTicket(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

