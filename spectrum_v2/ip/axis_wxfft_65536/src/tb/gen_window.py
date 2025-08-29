#!/usr/bin/python3.6
import numpy as np

def gen_window(N=32, B=8, wt="hanning"):
	if wt == "hanning":
		w = (2**(B-1)-1)*np.hanning(N)
	elif wt == "rect":
		w = (2**(B-1)-1)*np.ones(N)

	w = w.astype(np.int32)
	nch = int(np.ceil(B/4))
	for wi in w:
		print('{:0{}x}'.format(wi,nch))

gen_window(N=65536, B=16, wt="hanning")

