import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class SquirrelPlayTest{

        SquirrelPlay f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("SquirrelPlay_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new SquirrelPlay();
		cnt++;
	} // init


	@Test
	public void testsquirrelPlay1() {
		if ( f.squirrelPlay(70,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should always in this range,"+cnt);
		assertEquals( f.squirrelPlay(70,false),true);
}

	@Test
	public void testsquirrelPlay2() {
		if ( f.squirrelPlay(95,false) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Possible only in the summer,"+cnt);
		assertEquals( f.squirrelPlay(95,false),false);
}

	@Test
	public void testsquirrelPlay3() {
		if ( f.squirrelPlay(95,true) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Possible in the summer,"+cnt);
		assertEquals( f.squirrelPlay(95,true),true);
}

	@Test
	public void testsquirrelPlay4() {
		if ( f.squirrelPlay(90,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Play should be possible at terminals,"+cnt);
		assertEquals( f.squirrelPlay(90,false),true);
}

	@Test
	public void testsquirrelPlay5() {
		if ( f.squirrelPlay(90,true) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Play should be possible at terminals,"+cnt);
		assertEquals( f.squirrelPlay(90,true),true);
}

	@Test
	public void testsquirrelPlay6() {
		if ( f.squirrelPlay(50,false) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Not at all possible in this temperature,"+cnt);
		assertEquals( f.squirrelPlay(50,false),false);
}

	@Test
	public void testsquirrelPlay7() {
		if ( f.squirrelPlay(50,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Not at all possible in this temperature,"+cnt);
		assertEquals( f.squirrelPlay(50,true),false);
}

	@Test
	public void testsquirrelPlay8() {
		if ( f.squirrelPlay(100,false) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Possible only in the summer,"+cnt);
		assertEquals( f.squirrelPlay(100,false),false);
}

	@Test
	public void testsquirrelPlay9() {
		if ( f.squirrelPlay(100,true) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Possible in the summer,"+cnt);
		assertEquals( f.squirrelPlay(100,true),true);
}

	@Test
	public void testsquirrelPlay10() {
		if ( f.squirrelPlay(105,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Not at all possible in this temperature,"+cnt);
		assertEquals( f.squirrelPlay(105,true),false);
}

	@Test
	public void testsquirrelPlay11() {
		if ( f.squirrelPlay(59,false) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Not at all possible in this temperature,"+cnt);
		assertEquals( f.squirrelPlay(59,false),false);
}

	@Test
	public void testsquirrelPlay12() {
		if ( f.squirrelPlay(59,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Not at all possible in this temperature,"+cnt);
		assertEquals( f.squirrelPlay(59,true),false);
}

	@Test
	public void testsquirrelPlay13() {
		if ( f.squirrelPlay(60,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Play should be possible at terminals,"+cnt);
		assertEquals( f.squirrelPlay(60,false),true);
}

/*@Test
  public void testsquirrelPlay() {
   if (expectedResult==f.squirrelPlay(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(SquirrelPlay.squirrelPlay(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

