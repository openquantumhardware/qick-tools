import matplotlib.pyplot as plt
import os,sys,time
import numpy as np
from numpy.polynomial.polynomial import Polynomial
from tqdm.notebook import trange, tqdm

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
            retval = results_complex
        else:
            retval = (x_buf + offset[:, np.newaxis, np.newaxis]).dot([1,1j])
        self._subtractInputPhase(retval)
        return retval
    
    def _subtractInputPhase(self, xs, inputPhase=True):
        for i,toneFi in enumerate(self.toneFis):
            if inputPhase:
                xs[i] = np.abs(xs[i])*np.exp(1j * (np.angle(xs[i])-toneFi))
 

    def fscan(self, freqs, amps, fis, 
              bandwidth, nf, decimation, nt, truncate, 
              pfbOutQout=0, verbose=False, doProgress=False):
        dfs = np.linspace(-bandwidth/2, bandwidth/2, num=nf)
        xs = np.zeros((nf, len(freqs)), dtype=complex)
        if doProgress:
            iValues = trange(len(dfs))
        else:
            iValues = range(len(dfs))

        for i in iValues:
            df = dfs[i]
            self.setTones(df+freqs, amps, fis)
            self.prepRead(decimation)
            x = self.read(truncate=truncate, average=True)
            xs[i] =  x  
        return {
                "fMixer": self.soc.get_mixer(),
                "freqs":freqs,
                "amps": amps,
                "dfs": dfs,
                "xs": xs
               }
    
    def makeFList(self, fMixer, fMin, fMax):
        self.soc.set_mixer(fMixer)
        fList = []
        # Add boundaries of input channels to fList
        
        freq = self.soc.inCh2FreqCenter(self.soc.inFreq2ch(fMin)) -  self.soc.fcIn/2
        fEnd = self.soc.inCh2FreqCenter(self.soc.inFreq2ch(fMax)) +  self.soc.fcIn/2
        while True:
            fList.append(freq)
            freq += self.soc.fcIn
            if freq >= fEnd: 
                fList.append(freq)
                break

        freq = self.soc.outCh2FreqCenter(self.soc.outFreq2ch(fMin)) -  self.soc.fcOut/2
        fEnd = self.soc.outCh2FreqCenter(self.soc.outFreq2ch(fMax)) +  self.soc.fcOut/2
        while True:
            fList.append(freq)
            freq += self.soc.fcOut
            if freq >= fEnd: 
                fList.append(freq)
                break

        fList = np.sort(np.unique(np.array(fList)))
        return fList
    
    def makeCalibration(self, fMixer, fMin, fMax, nf=100, nt=10, 
                        decimation=2, pfbOutQout=0, verbose=False,
                       randSeed=1234991, truncate=500, doProgress=True):
        
        fList = self.makeFList(fMixer, fMin, fMax)
        fcMax = max(self.soc.fcIn, self.soc.fcOut)
        fcMin = min(self.soc.fcIn, self.soc.fcOut)
        fMinCentered = self.soc.outCh2FreqCenter(self.soc.outFreq2ch(fMin))
        fMaxCentered = self.soc.outCh2FreqCenter(self.soc.outFreq2ch(fMax))
        freqs =  np.arange(fMinCentered-fcMax, fMaxCentered+fcMax, self.soc.fcOut)
        if verbose: print("Scan.makeCalibration:  len(freqs) =",len(freqs))
        amps = np.ones(len(freqs))*0.9/len(freqs)
        np.random.seed(randSeed)
        fis = np.random.uniform(0, 2*np.pi, len(freqs))
        bandwidth = self.soc.fcOut * (1-1/nf) 
        fscan = self.fscan(freqs, amps, fis, bandwidth, nf, decimation, nt,
                          truncate, pfbOutQout, verbose=verbose, doProgress=doProgress)
        
        return fscan
    
    def measureNominalDelay(self, outCh, nf=20, nt=1, verbose=False, doProgress=False, doPlot=False, decimation=32, truncate=500, pfbOutQout=0):
        freqs = np.array([self.soc.outCh2FreqCenter(outCh)])
        amps = np.array([0.9])
        fis = np.array([0.0])
        bandwidth = self.soc.fcOut / 100
        self.mndScan = self.fscan(freqs, amps, fis, bandwidth, nf, decimation, nt,
                      truncate, pfbOutQout, verbose=verbose, doProgress=doProgress)
       
        iTone = 0
        dfs = self.mndScan['dfs']
        fis = np.angle(self.mndScan['xs'][:,iTone])
        ufis = unwrapPhis(fis)
        fit = Polynomial.fit(dfs, ufis, 1)
        nominalDelay = fit.convert().coef[1]
        if doPlot:
                #plt.plot(dfs,fis, ".-")
                fig,ax = plt.subplots(2,1,sharex=True)
                ax[0].plot(dfs, ufis, ".",label="data")
                ax[0].plot(dfs, fit(dfs), label="fit")
                ax[0].set_ylabel("unwrapped phase [Radians]")
                ax[0].legend()
                ax[1].plot(dfs, ufis-fit(dfs),'.')
                ax[1].set_ylabel("fit residual [Radians]")
                ax[1].set_xlabel("f offset in out channel")
                plt.suptitle("outCh=%d DDSDelay = %f $\mu$sec"%(outCh,nominalDelay))
        return nominalDelay


def fscanPlot(fscan, iTone):
    dfs = fscan["dfs"]
    xs = fscan['xs'][:,iTone]
    fig,ax = plt.subplots(2,1,sharex=True)
    ax[0].plot(dfs, np.abs(xs), '-o')
    ax[0].set_ylabel("amplitude [ADUs]")
    ax[1].plot(dfs, np.angle(xs), '-o')
    ax[1].set_ylabel("phase [Radians]")
    ax[1].set_xlabel("Frequency-%f [MHz]"%fscan["freqs"][iTone])
    
def fscanToSpectrum(fscan):
    dfs = fscan['dfs']
    freqs = fscan['freqs']
    allfreqs = np.zeros((len(freqs),len(dfs)))
    #allAmps = np.zeros((len(fTones),len(dfs)))
    #allFis = np.zeros((len(fTones),len(dfs)))
    for i,fTone in enumerate(freqs):
        allfreqs[i,:] = freqs[i]+dfs
    print("allfreqs.shape =",allfreqs.shape)
    allfreqs = allfreqs.ravel()
    print("allfreqs.shape =",allfreqs.shape)
    xs = np.transpose(fscan['xs'])
    allamps = np.abs(xs).ravel()
    allfis = np.angle(xs).ravel()
    inds = np.argsort(allfreqs)
    return allfreqs[inds], allamps[inds], allfis[inds]
   
def applyDelay(fscan, delay):
    for iTone in range(fscan['xs'].shape[1]):
        xs = fscan['xs'][:,iTone]
        freqs = fscan['dfs'] + fscan['freqs'][iTone]
        
        fscan['xs'][:,iTone] = np.abs(xs)*np.exp( 1j*(np.angle(xs) - delay*freqs) )
        
def unwrapPhis(phis, sign=1):
    """
    Increment (or decrement) values after a large change in phase to unwrap them
    """
    uphis = sign*(phis.copy())
    for i in range(1,len(uphis)):
        if uphis[i-1] > uphis[i]:
            uphis[i:] += 2*np.pi
    return sign*uphis
