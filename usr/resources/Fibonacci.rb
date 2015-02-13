def fibonacciChecker(myvar)
     prev=0;
     curr=1
     old_curr=0
     
     for i in 1...20
       if(myvar==prev)
         return true    
       else
         old_curr=curr
         curr=curr+prev
         prev=old_curr
       end
     end
     return false
end #XYZ