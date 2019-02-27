#######################################################
# Tyler Anderson 
# Wed Feb 27 11:55:38 EST 2019
#
# Gated integrator test
# 
#######################################################

import numpy as np
import matplotlib.pyplot as plt

s = 0
n = 16
mean = 2**13
sigma = 10
samples = np.zeros(n)
j = 0
fout = open("test.txt","w")
for i in range(1000):
    x = int(np.random.normal(mean,sigma)+0.5) 
    samples[j] = x
    j = (j+1)%n
    s = 0
    for jj in range(n): 
        s = s+samples[jj]
    line = "%d %d\n" % (x,s)
    fout.write(line)
fout.close()
