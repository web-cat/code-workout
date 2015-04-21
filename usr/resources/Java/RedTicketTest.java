import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class RedTicketTest{

        RedTicket f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("RedTicket_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new RedTicket();
		cnt++;
	} // init


	@Test
	public void testredTicket1() {
		if ( f.redTicket(2,2,2) == 10 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Learn to recognize a jackpot,"+cnt);
		assertEquals( f.redTicket(2,2,2),10);
}

	@Test
	public void testredTicket2() {
		if ( f.redTicket(2,2,1) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(2,2,1),0);
}

	@Test
	public void testredTicket3() {
		if ( f.redTicket(0,0,0) == 5 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Winnings check failed,"+cnt);
		assertEquals( f.redTicket(0,0,0),5);
}

	@Test
	public void testredTicket4() {
		if ( f.redTicket(2,0,0) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(2,0,0),1);
}

	@Test
	public void testredTicket5() {
		if ( f.redTicket(1,1,1) == 5 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Winnings check failed,"+cnt);
		assertEquals( f.redTicket(1,1,1),5);
}

	@Test
	public void testredTicket6() {
		if ( f.redTicket(1,2,1) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(1,2,1),0);
}

	@Test
	public void testredTicket7() {
		if ( f.redTicket(1,2,0) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(1,2,0),1);
}

	@Test
	public void testredTicket8() {
		if ( f.redTicket(0,2,2) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(0,2,2),1);
}

	@Test
	public void testredTicket9() {
		if ( f.redTicket(1,2,2) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(1,2,2),1);
}

	@Test
	public void testredTicket10() {
		if ( f.redTicket(0,2,0) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(0,2,0),0);
}

	@Test
	public void testredTicket11() {
		if ( f.redTicket(1,1,2) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Simple lottery check failed,"+cnt);
		assertEquals( f.redTicket(1,1,2),0);
}

/*@Test
  public void testredTicket() {
   if (expectedResult==f.redTicket(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(RedTicket.redTicket(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

