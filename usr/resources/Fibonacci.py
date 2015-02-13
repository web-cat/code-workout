def fibonacciChecker(myvar):
     prev=0
     curr=1
     old_curr=0
     
     for i in range(20):
       if(myvar==prev):
         return True    
       else:
         old_curr=curr
         curr=curr+prev
         prev=old_curr
       
     return False