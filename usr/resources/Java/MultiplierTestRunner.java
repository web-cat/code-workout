import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

public class MultiplierTestRunner{
  public static void main(String[] args){
    Result res = JUnitCore.runClasses(MultiplierTest.class);
    for(Failure fail: res.getFailures())
      System.out.println(fail.toString());
    System.out.println(res.wasSuccessful());
  }
}
