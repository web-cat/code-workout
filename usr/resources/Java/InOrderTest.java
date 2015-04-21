import junit.framework.TestCase;
import static org.junit.Assert.*;
import java.io.*;
import org.junit.*;

public class InOrderTest{

        InOrder f=null;
	static PrintWriter fout= null;
  	static int cnt=0;
  
	@BeforeClass
	public static void fileInit() throws FileNotFoundException{
		fout = new PrintWriter("InOrder_Java_results.csv");
        }

  	@Before
	public void init() {
                f = new InOrder();
		cnt++;
	} // init


	@Test
	public void testinOrder1() {
		if ( f.inOrder(1,2,4,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Normal inorder testing failed,"+cnt);
		assertEquals( f.inOrder(1,2,4,false),true);
}

	@Test
	public void testinOrder2() {
		if ( f.inOrder(1,2,1,false) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Normal inorder testing failed,"+cnt);
		assertEquals( f.inOrder(1,2,1,false),false);
}

	@Test
	public void testinOrder3() {
		if ( f.inOrder(1,1,2,true) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,bOk salvation testing failed,"+cnt);
		assertEquals( f.inOrder(1,1,2,true),true);
}

	@Test
	public void testinOrder4() {
		if ( f.inOrder(3,2,4,false) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Normal inorder testing failed,"+cnt);
		assertEquals( f.inOrder(3,2,4,false),false);
}

	@Test
	public void testinOrder5() {
		if ( f.inOrder(2,3,4,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Normal inorder testing failed,"+cnt);
		assertEquals( f.inOrder(2,3,4,false),true);
}

	@Test
	public void testinOrder6() {
		if ( f.inOrder(3,2,4,true) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,bOk salvation testing failed,"+cnt);
		assertEquals( f.inOrder(3,2,4,true),true);
}

	@Test
	public void testinOrder7() {
		if ( f.inOrder(4,2,2,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Unsalvagable testing failed,"+cnt);
		assertEquals( f.inOrder(4,2,2,true),false);
}

	@Test
	public void testinOrder8() {
		if ( f.inOrder(4,5,2,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Unsalvagable testing failed,"+cnt);
		assertEquals( f.inOrder(4,5,2,true),false);
}

	@Test
	public void testinOrder9() {
		if ( f.inOrder(2,4,6,true) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Normal inorder testing failed,"+cnt);
		assertEquals( f.inOrder(2,4,6,true),true);
}

	@Test
	public void testinOrder10() {
		if ( f.inOrder(7,9,10,false) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Normal inorder testing failed,"+cnt);
		assertEquals( f.inOrder(7,9,10,false),true);
}

	@Test
	public void testinOrder11() {
		if ( f.inOrder(7,5,6,true) == true )
			fout.println("1,,"+cnt);
		else
			fout.println("0,bOk salvation testing failed,"+cnt);
		assertEquals( f.inOrder(7,5,6,true),true);
}

	@Test
	public void testinOrder12() {
		if ( f.inOrder(7,5,4,true) == false )
			fout.println("1,,"+cnt);
		else
			fout.println("0,Unsalvagable testing failed,"+cnt);
		assertEquals( f.inOrder(7,5,4,true),false);
}

/*@Test
  public void testinOrder() {
   if (expectedResult==f.inOrder(num))
     fout.println("1,,"+cnt);
   else
     fout.println("0,Test case failed,"+cnt);
    assertEquals(InOrder.inOrder(INPUTS));
  }// */

	@AfterClass
	public static void fileClean(){
		if (fout!=null)
		  fout.close();
	}
}

