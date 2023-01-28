import matplotlib.pyplot as plt
import os,sys,time
import numpy as np

class Scan():
    
    def __init__(self, soc):
        self.soc = soc

    def setTones(self, freqsRequested, amplitudes, fis, pfbOutQout=0, verbose=False):
        # pdbOutQout:  0 for max output power, larger values give finer control
        self.soc.dds_out.alloff()
        self.toneFreqsRequested = freqsRequested
        freqs = self.soc.DF*np.round(freqsRequested/self.soc.DF)
        #freqs = freqsRequested
        pfb_chs, dds_freqs, _, unwrapped_chs = self.soc.pfb_out.freq2ch(freqs, self.soc.pfb_out.get_fmix())
        if len(set(pfb_chs)) != len(pfb_chs):
            raise ValueError("Output tones map to PFB channels %s, which are not unique"%(str(pfb_chs)))        
        for ch, fdds, amplitude, unwrapped_ch, fiDeg in zip(pfb_chs, dds_freqs, amplitudes, unwrapped_chs, np.rad2deg(fis)):
            if verbose: 
                print("Scan.setTones: ",ch,fdds,amplitude,unwrapped_ch,fiDeg)
            self.soc.dds_out.ddscfg(ch=ch, f=fdds, g=amplitude, fi=fiDeg)
        self.soc.pfb_out.qout(pfbOutQout)
        self.toneFreqs = freqs
        self.toneAmplitudes = amplitudes
        self.toneFis = fis
        
    def prepRead(self, decimation, nsamp=10000, pfbInQout=8, verbose=False):
        K, dds_freq, pfb_freq, ch = self.soc.pfb_in.freq2ch(self.toneFreqs)
        if len(set(K)) < len(self.toneFreqs):
            raise ValueError("input PFB channels are not unique: %s"%(K))
        streams, stream_idx = self.soc.chsel.ch2idx(K)
        self.soc.pfb_in.qout(pfbInQout)
        self.soc.ddscic.decimation(value=decimation)
        fs = self.soc.pfb_in.get_fb()/self.soc.ddscic.get_decimate()
        self.soc.ddscic.dds_outsel(outsel="product")
        for i in range(len(self.toneFreqs)):
            self.soc.ddscic.set_ddsfreq(ch_id=K[i], f=dds_freq[i]) # Is this in radians or degrees?
            if verbose:
                print("Scan.prepRead: ch_id, dds_freq =",ch_id, dds_freq)
        # need to correct by 1.0 if in "product" mode?
        offset = np.full_like(K, 1.0)
        fcenter = pfb_freq+dds_freq
        
        num_tran, tran_idx = self.soc.chsel.set(K)

        self.input_config = {}
        self.input_config['fs'] = fs
        self.input_config['pfb_ch'] = K
        self.input_config['dds_freq'] = dds_freq
        self.input_config['center_freq'] = fcenter
        self.input_config['num_tran'] = num_tran
        self.input_config['tran_idx'] = tran_idx
        self.input_config['streams'] = streams
        self.input_config['stream_idx'] = stream_idx
        self.input_config['offset'] = offset
        self.nsamp = nsamp
        #_ = self.soc.stream.get_all_data(nt=1, nsamp=nsamp, debug=False)


    def read(self, truncate=0, average=False, nt=1, nsamp=10000):
        num_tran = self.input_config['num_tran']
        tran_idx = self.input_config['tran_idx']
        streams = self.input_config['streams']
        stream_idx = self.input_config['stream_idx']
        offset = self.input_config['offset']
        x_buf = self.soc.stream.get_data_multi(idx=streams, nt=nt, nsamp=nsamp*num_tran)[:,truncate*num_tran:]
        x_buf = x_buf.reshape(len(streams), -1, num_tran, 2)[stream_idx, :, tran_idx, :]
        if average:
            results = x_buf.mean(axis=1)
            results += offset[:, np.newaxis]
            results_complex = results.dot([1, 1j])
            return results_complex
        else:
            return x_buf + offset[:, np.newaxis, np.newaxis]

        
                                                            