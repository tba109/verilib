// ceiling(log2()), used to figure out counter size.   
function integer clogb2;
   input integer value;
   for(clogb2=0;value>0;clogb2=clogb2+1)
     value = value >> 1;
endfunction // for
