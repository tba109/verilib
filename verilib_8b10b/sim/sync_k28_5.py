# Tyler Anderson Thu Apr 28 13:57:25 EDT 2022
# This generates a K28.5 sync signal
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

def hex_to_bitstream(x):
    s = ""
    for i in range(10):
        s=s+str((x>>(9-i))&0x1)
    return s
        
def main():
    print("rd,is_k,data_out,rd_out")

    rd = 0
    is_k = 1 # Is a control word
    data_in = 0xbc
    
    rd, data_out = EncDec8B10B.enc_8b10b(data_in,rd,is_k)
    # Bits are reversed relative to their definition
    rev_data_out = reverse_data(data_out)
    print(rd,is_k,'{:#05x}'.format(rev_data_out),rd,hex_to_bitstream(rev_data_out)) # rd_out)

    
    rd, data_out = EncDec8B10B.enc_8b10b(data_in,rd,is_k)
    # Bits are reversed relative to their definition
    rev_data_out = reverse_data(data_out)
    print(rd,is_k,'{:#05x}'.format(rev_data_out),rd,hex_to_bitstream(rev_data_out)) # rd_out)

    
if __name__ == "__main__":
    main()
