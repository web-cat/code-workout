import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class AnswerCellTest{

        AnswerCell f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("AnswerCell_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new AnswerCell();
		cnt++;
	} // init


	@Test
	public void testanswerCell1() {
		if ( f.answerCell(false,false,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should answer if not sleeping and not morning,"+cnt);
		assertEquals( f.answerCell(false,false,false),true);
}

	@Test
	public void testanswerCell2() {
		if ( f.answerCell(false,false,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should not answer while sleeping,"+cnt);
		assertEquals( f.answerCell(false,false,true),false);
}

	@Test
	public void testanswerCell3() {
		if ( f.answerCell(true,false,false) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Shouldn't answer in the morning if it is not mom,"+cnt);
		assertEquals( f.answerCell(true,false,false),false);
}

	@Test
	public void testanswerCell4() {
		if ( f.answerCell(true,true,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should answer mom if not sleeping in morning,"+cnt);
		assertEquals( f.answerCell(true,true,false),true);
}

	@Test
	public void testanswerCell5() {
		if ( f.answerCell(false,true,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Should answer mom if not sleeping,"+cnt);
		assertEquals( f.answerCell(false,true,false),true);
}

	@Test
	public void testanswerCell6() {
		if ( f.answerCell(true,true,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Shouldnt answer while sleeping,"+cnt);
		assertEquals( f.answerCell(true,true,true),false);
}

/*@Test
  public void testanswerCell() {
   if (expectedResult==f.answerCell(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(AnswerCell.answerCell(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

