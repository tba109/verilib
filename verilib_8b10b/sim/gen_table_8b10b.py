# Tyler Anderson Thu Apr 28 13:57:25 EDT 2022
# This is a python checker script to go with the simulation
# Must install encdec8b10b Python module as per below:
# 
# conda install git
# conda install pip
# python -m pip install encdec8b10b
import sys 
from encdec8b10b import EncDec8B10B

def reverse_data(x):
    y = 0
    for j in range(10):
        y = y | (((x >> j) & 0x001) << (9-j))
    return y
    

def main():
    print("i,rd,is_k,data_out,rd_out")
    
    rd = 0 # running disparity
    is_k = 0 # Is a control word
    for i in range(256): 
        rd_out, data_out = EncDec8B10B.enc_8b10b(i,rd,is_k)
        # Bits are reversed relative to their definition
        rev_data_out = reverse_data(data_out)
        print(f"{i:>3}",rd,is_k,'{:#05x}'.format(rev_data_out),rd) # rd_out)
                
    rd = 1 # running disparity
    is_k = 0
    for i in range(256): 
        rd_out, data_out = EncDec8B10B.enc_8b10b(i,rd,is_k)
        # Bits are reversed relative to their definition
        rev_data_out = reverse_data(data_out)
        print(f"{i:>3}",rd,is_k,'{:#05x}'.format(rev_data_out),rd) # rd_out)
        
    rd = 0 # running disparity
    is_k = 1 # Is a control word
    for i in [0x1c,0x3c,0x5c,0x7c,0x9c,0xbc,0xdc,0xf7,0xfb,0xfc,0xfd,0xfe]: 
        rd_out, data_out = EncDec8B10B.enc_8b10b(i,rd,is_k)
        # Bits are reversed relative to their definition
        rev_data_out = reverse_data(data_out)
        print(f"{i:>3}",rd,is_k,'{:#05x}'.format(rev_data_out),rd) # rd_out)
                
    rd = 1 # running disparity
    is_k = 1 # Is a control word
    for i in [0x1c,0x3c,0x5c,0x7c,0x9c,0xbc,0xdc,0xf7,0xfb,0xfc,0xfd,0xfe]: 
        rd_out, data_out = EncDec8B10B.enc_8b10b(i,rd,is_k)
        # Bits are reversed relative to their definition
        rev_data_out = reverse_data(data_out)
        print(f"{i:>3}",rd,is_k,'{:#05x}'.format(rev_data_out),rd) # rd_out)
                
if __name__ == "__main__":
    main()
