import numpy as np
import time
from collections import OrderedDict
class Packets():
    
    def __init__(self, packets, input_config):
        self.packets = packets
        self.input_config = input_config
        
    def unpackV1(self, verbose=False):
        
        # Copied from get_all_data, which returns self.data_iq
        self.data_iq = self.packets[:,:,:16].reshape((-1,16))
        # add this to keep track of packet sources
        self.i16s = self.packets[:,:,16].reshape((-1))
        
        # Copied from get_data_multi, which returns self.x_buf
        streams = self.input_config['streams']
        idx_arr = (np.outer(2*streams, [1,1])+np.array([0,1])).flatten()
        self.x_buf_1 = np.moveaxis(self.data_iq[:,idx_arr].reshape(-1,len(streams),2),1,0)
        
        # Copied from read, which reshapes xbuf
        num_tran = self.input_config['num_tran']
        self.x_buf_2 = self.x_buf_1.reshape(len(streams), -1, num_tran, 2)
        stream_idx = self.input_config['stream_idx']
        tran_idx = self.input_config['tran_idx']
        self.x_buf = self.x_buf_2[stream_idx, :, tran_idx, :]
        offset = self.input_config['offset']
        self.xs = (self.x_buf + offset[:,np.newaxis, np.newaxis]).dot([1,1j])

        if verbose:

            nt = self.packets.shape[0]
            num_tran = self.input_config["num_tran"]
            nsamp = self.packets.shape[1]//num_tran
            nTones = len(self.input_config['tran_idx'])
            nStreams = len(self.input_config["streams"])
            print("nt =",nt)
            print("nsamp =",nsamp)
            print("num_tran =",num_tran)
            print("nTones =",nTones)
            print("nStreams =",nStreams)
            #print(packetss[iRead].shape)
            print("          packets (nt,num_tran*nsamp, 17):",self.packets.shape)
            print("          data_iq (nt*num_tran*nsamp, 16):",self.data_iq.shape)
            print("                 i16s (nt*num_tran*nsamp):",self.i16s.shape)
            print("   x_buf_2 (nStreams, nsamp, num_tran, 2):",self.x_buf_2.shape)
            print("    x_buf_1 (nStreams, nsamp*num_tran, 2):",self.x_buf_1.shape)
            print("              x_buf (nTones, nsamp*nt, 2):",self.x_buf.shape)
            print("                    xs (nTones, nsamp*nt):",self.xs.shape)
            print("     tran_idx =",self.input_config["tran_idx"])
            print("   stream_idx =",self.input_config["stream_idx"])
            print(" begin*2 i16s =",self.i16s[:2*num_tran,])
    def unpack(self, verbose=False):
        
        self.data_iq_all = self.packets[:,:,:16].reshape((-1,16))
        # keep track of packet sources
        self.i16s = self.packets[:,:,16].reshape((-1))

        self.inds = np.full(len(self.i16s), False, dtype=bool)
        num_tran = self.input_config['num_tran']
        i = 0
        self.i16Pattern = self.input_config['i16Pattern']
        self.nGoodSamp = 0
        self.iFirstGoodSamp = -1
        while i <= len(self.i16s)-num_tran:
            if np.array_equal(self.i16Pattern, self.i16s[i:i+num_tran]):
                self.inds[i:i+num_tran] =  True
                self.nGoodSamp += 1
                if self.iFirstGoodSamp == -1:
                    self.iFirstGoodSamp = i
                i += num_tran
            else:
                i += 1
        self.data_iq = self.data_iq_all[self.inds,:]
        # Copied from get_data_multi, which returns self.x_buf
        streams = self.input_config['streams']
        idx_arr = (np.outer(2*streams, [1,1])+np.array([0,1])).flatten()
        self.x_buf_1 = np.moveaxis(self.data_iq[:,idx_arr].reshape(-1,len(streams),2),1,0)
        
        # Copied from read, which reshapes xbuf
        self.x_buf_2 = self.x_buf_1.reshape(len(streams), -1, num_tran, 2)
        stream_idx = self.input_config['stream_idx']
        tran_idx = self.input_config['tran_idx']
        self.x_buf = self.x_buf_2[stream_idx, :, tran_idx, :]
        offset = self.input_config['offset']
        self.xs = (self.x_buf + offset[:,np.newaxis, np.newaxis]).dot([1,1j])

        if verbose:

            nt = self.packets.shape[0]
            num_tran = self.input_config["num_tran"]
            nsamp = self.packets.shape[1]//num_tran
            nTones = len(self.input_config['tran_idx'])
            nStreams = len(self.input_config["streams"])
            nGoodSamp = self.nGoodSamp
            iFirstGoodSamp = self.iFirstGoodSamp
            i16Pattern = self.i16Pattern
            print("            nt =",nt)
            print("         nsamp =",nsamp)
            print("      num_tran =",num_tran)
            print("        nTones =",nTones)
            print("      nStreams =",nStreams)
            print("     nGoodSamp =",nGoodSamp)
            print("iFirstGoodSamp =",iFirstGoodSamp)
            print("i16Pattern",i16Pattern)
            #print(packetss[iRead].shape)
            print("                     i16s (nt*num_tran*nsamp):",self.i16s.shape)
            print("              packets (nt,num_tran*nsamp, 17):",self.packets.shape)
            print("          data_iq_all (nt*num_tran*nsamp, 16):",self.data_iq_all.shape)
            print("             data_iq (nGoodSamp*num_tran, 16):",self.data_iq.shape)
            print("   x_buf_2 (nStreams, nGoodsamp, num_tran, 2):",self.x_buf_2.shape)
            print("    x_buf_1 (nStreams, nGoodsamp*num_tran, 2):",self.x_buf_1.shape)
            print("              x_buf (nTones, nGoodsamp*nt, 2):",self.x_buf.shape)
            print("                    xs (nTones, nGoodsamp*nt):",self.xs.shape)
            print("     tran_idx =",self.input_config["tran_idx"])
            print("   stream_idx =",self.input_config["stream_idx"])
            print(" begin*2 i16s =",self.i16s[:2*num_tran,])
            print("   end*2 i16s =",self.i16s[-2*num_tran:,])
 