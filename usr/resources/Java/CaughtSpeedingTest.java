import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class CaughtSpeedingTest{

        CaughtSpeeding f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("CaughtSpeeding_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new CaughtSpeeding();
		cnt++;
	} // init


	@Test
	public void testcaughtSpeeding1() {
		if ( f.caughtSpeeding(60,false) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,No ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(60,false),0);
}

	@Test
	public void testcaughtSpeeding2() {
		if ( f.caughtSpeeding(65,false) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should get normal ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(65,false),1);
}

	@Test
	public void testcaughtSpeeding3() {
		if ( f.caughtSpeeding(65,true) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,No ticket for this speed on Birthday,"+cnt);
		assertEquals( f.caughtSpeeding(65,true),0);
}

	@Test
	public void testcaughtSpeeding4() {
		if ( f.caughtSpeeding(80,false) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should get ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(80,false),1);
}

	@Test
	public void testcaughtSpeeding5() {
		if ( f.caughtSpeeding(85,false) == 2 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should get higher ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(85,false),2);
}

	@Test
	public void testcaughtSpeeding6() {
		if ( f.caughtSpeeding(85,true) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should get normal ticket for this speed on birthday,"+cnt);
		assertEquals( f.caughtSpeeding(85,true),1);
}

	@Test
	public void testcaughtSpeeding7() {
		if ( f.caughtSpeeding(70,false) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should get normal ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(70,false),1);
}

	@Test
	public void testcaughtSpeeding8() {
		if ( f.caughtSpeeding(75,false) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should get normal ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(75,false),1);
}

	@Test
	public void testcaughtSpeeding9() {
		if ( f.caughtSpeeding(75,true) == 1 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should get normal ticket for this speed on birthday,"+cnt);
		assertEquals( f.caughtSpeeding(75,true),1);
}

	@Test
	public void testcaughtSpeeding10() {
		if ( f.caughtSpeeding(40,false) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,No ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(40,false),0);
}

	@Test
	public void testcaughtSpeeding11() {
		if ( f.caughtSpeeding(40,true) == 0 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,No ticket for this speed,"+cnt);
		assertEquals( f.caughtSpeeding(40,true),0);
}

	@Test
	public void testcaughtSpeeding12() {
		if ( f.caughtSpeeding(90,false) == 2 )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Dead at this speed,"+cnt);
		assertEquals( f.caughtSpeeding(90,false),2);
}

/*@Test
  public void testcaughtSpeeding() {
   if (expectedResult==f.caughtSpeeding(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(CaughtSpeeding.caughtSpeeding(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

