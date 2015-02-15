public class Fibonacci {
  public boolean fibonacciChecker(final int num) {
    int prev=0;
    int curr=1;
    int old_curr;
    for(int i=1;i<10;i++) {
      if(num==curr) {
        return true;
      }
      else {
        old_curr=curr;
        curr=curr+prev;
        prev=old_curr;
      }
    } // for
    return false;
  }// KV-1
}