import matplotlib.pyplot as plt
import copy,os,sys,time
import numpy as np
from numpy.polynomial.polynomial import Polynomial
from tqdm.notebook import trange, tqdm
from scipy.interpolate import interp1d
"""
The firmware chooses which input channels to read out.


The number of input channels is soc.nInCh and for the ZCU111 this is 4096.  Which channel to read out is defined by an address and a bit.  This points to a set of 8 input channels.

For the ZCU111 these numbers are:
    number of addresses = 16
    number of bits = 32
    This yields the same number of channels, 16*32*8 = 4096.16
"""

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
        if verbose:
            for i in range(len(freqs)):
                print("i, freqs[i], pfb_chs[i], dds_freqs[i], unwarpped_chs[i]",
                     i, freqs[i], pfb_chs[i], dds_freqs[i], unwrapped_chs[i])
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
        
    def prepRead(self, decimation, pfbInQout=8, verbose=False, debugChselSet=False):
        if verbose:
            print("in Scan.py prepRead:  self.toneFreqs=",self.toneFreqs)
        K, dds_freq, pfb_freq, ch = self.soc.pfb_in.freq2ch(self.toneFreqs)
        if verbose:
            print("in Scan.py prepRead:  ch =",ch)
        if len(set(K)) < len(self.toneFreqs):
            raise ValueError("input PFB channels are not unique: %s"%(K))
        streams, stream_idx = self.soc.chsel.ch2idx(K)
        
        inCh = self.soc.inFreq2ch(self.toneFreqs)
        #ntrans, addrs, bits = self.soc.chsel.ch2tran(ch) # bit ranges from 0 to 31 
        ntrans, addrs, bits = self.soc.chsel.ch2tran(inCh) # bit ranges from 0 to 31 
        i16Pattern = []
        bitPrev = -1
        addrPrev = -1
        for i,(ntran,addr,bit) in enumerate(zip(ntrans,addrs,bits)):
            if (bit != bitPrev) or (addr != addrPrev):
                bitPrev = bit
                addrPrev =  addr
                i16Pattern.append(int(ntran))
        
        if verbose:
            print("Scan.prepRead: i16Pattern =",i16Pattern)
            print("Scan.prepRead: ntrans =",ntrans)
            print("Scan.prepRead: addrs =",addrs)
            print("Scan.prepRead: bits =",bits)
            print("Scan.prepRead: K=",K)
            print("Scan.prepRead: streams =",streams)
            print("Scan.prepRead: stream_idx =",stream_idx)
        self.soc.pfb_in.qout(pfbInQout)
        self.soc.ddscic.decimation(value=decimation)
        fs = self.soc.pfb_in.get_fb()/self.soc.ddscic.get_decimate()
        self.soc.ddscic.dds_outsel(outsel="product")
        for i in range(len(self.toneFreqs)):
            self.soc.ddscic.set_ddsfreq(ch_id=K[i], f=dds_freq[i])
            if verbose:
                print("Scan.prepRead: i, ch_id, dds_freq =",i, K[i], dds_freq[i])
        # need to correct by 1.0 if in "product" mode?
        offset = np.full_like(K, 1.0)
        fcenter = pfb_freq+dds_freq
        num_tran, tran_idx = self.soc.chsel.set(K, debug=debugChselSet)
        self.ntranByTone, self.streamByTone = self.soc.inFreq2NtranStream(self.toneFreqs)
        if verbose:
            print("self.ntranByTone =",self.ntranByTone)
            print("self.streamByTone =",self.streamByTone)

    
    def readAndUnpack(self,  nt=1, nsamp=10000,
                      average=False, subtractInputPhase=True, iBegin=0,
                      debugTransfer=False, unpackVerbose=False):
        self.packets = self.soc.stream.transfer(nt=nt, nsamp=nsamp, debug=debugTransfer)
        return self.unpack(unpackVerbose, average, subtractInputPhase=subtractInputPhase, iBegin=iBegin)
    
    
    def unpack(self, verbose, average, subtractInputPhase=True, iBegin=0):
        if verbose: print("self.packets.shape =",self.packets.shape)
        packets = self.packets[:, iBegin:, :]
        if verbose: print("     packets.shape =",packets.shape)
        ntrans = packets[:,:,16]
        if verbose: print("      ntrans.shape =",ntrans.shape)
        xis = packets[:,:,0:16:2]
        if verbose: print("         xis.shape =",xis.shape)
        xqs = packets[:,:,1:17:2]
        if verbose: print("         xqs.shape =",xqs.shape)
        xs = xis + 1j*xqs
        if verbose: print("          xs.shape =",xs.shape)
    
        ntranPattern = np.sort(np.unique(self.ntranByTone))
        if verbose: print(" ntranPattern =",ntranPattern)
        nPattern = len(ntranPattern)

        xsByNtTone = []
        nt = xs.shape[0]
        nTone = len(self.ntranByTone)
        for it in range(nt):
            xsByTone = []
            for iTone,(ntran,stream) in enumerate(zip(self.ntranByTone,self.streamByTone)):
                temp = xs[it, ntrans[it]==ntran, stream]
                if verbose: print("   nt, iTone , x.shape", it, iTone, temp.shape)

                if subtractInputPhase:
                    temp = self._subtractInputPhase(temp, self.toneFis[iTone])

                xsByTone.append(temp)
            xsByNtTone.append(xsByTone)
        if average:
            retval = np.zeros((nt,nTone), dtype=complex)
            for it in range(nt):
                for iTone in range(nTone):
                    retval[it,iTone] =  xsByNtTone[it][iTone].mean()
            retval = retval.mean(axis=0)
        else:
            retval = xsByNtTone
        return retval

    def _subtractInputPhase(self, x, toneFi):
        """
        Return values with phase of x reducted by toneFi in radians
        """
        xrot = np.abs(x)*np.exp(1j * (np.angle(x)-toneFi))
        return xrot

    def fscan(self, freqs, amps, fis, 
              bandwidth, nf, decimation, nt, iBegin=200, nsamp=10000,
              pfbOutQout=0, verbose=False, doProgress=False,
              retainPackets = False, subtractInputPhase=True):
        dfs = np.linspace(-bandwidth/2, bandwidth/2, num=nf)
        xs = np.zeros((nf, len(freqs)), dtype=complex)
        if retainPackets:
            self.retainedPackets = []
        if doProgress:
            iValues = trange(len(dfs))
        else:
            iValues = range(len(dfs))

        for i in iValues:
            df = dfs[i]
            self.setTones(df+freqs, amps, fis)
            self.prepRead(decimation)
            x = self.readAndUnpack(nt, nsamp, average=True,
                                   subtractInputPhase=subtractInputPhase,
                                   iBegin=iBegin)
            if retainPackets:
                self.retainedPackets.append(self.packets)
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
        i0 = max(0, np.searchsorted(fList, fMin)-1)
        i1 = np.searchsorted(fList, fMax)+1
        return fList[i0:i1]
    
    def makeCalibration(self, fMixer, fMin, fMax, nf=100, nt=10, 
                        decimation=2, pfbOutQout=0, verbose=False,
                       randSeed=1234991, iBegin=500, doProgress=True,
                       nsamp=10000, nominalDelay=None):
        
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
        fscan = self.fscan(freqs, amps, fis, 
                           bandwidth, nf, decimation, 
                           nt, iBegin, nsamp,
                           pfbOutQout, verbose=verbose, doProgress=doProgress)
        if nominalDelay is not None:
            applyDelay(fscan, nominalDelay)
        fList = self.makeFList(fMixer, fMin, fMax)
        sFreqs, fAmps, sFis = fscanToSpectrum(fscan)
        sxs = fAmps*np.exp(1j*sFis)
        cInterps = []
        for i in range(len(fList)-1):
            f0 = fList[i]
            f1 = fList[i+1]
            inds = (f0 < sFreqs) & (sFreqs < f1)
            print(" in MakeCalibration:  i, f0, f1",i,f0,f1)
            interp = interp1d(sFreqs[inds], sxs[inds], bounds_error=False, fill_value="extrapolate")
            cInterps.append(interp)
        calib = {"fMixer":fMixer, "fList":fList, "cInterps":cInterps, 
                 "fMin":fMin, "fMax":fMax, "fscan":fscan, "nominalDelay":nominalDelay} 
        return calib
    
    def measureNominalDelay(self, outCh, nf=20, nt=1, verbose=False, doProgress=False, doPlot=False, decimation=32, iBegin=500, pfbOutQout=0, nsamp=10000):
        freqs = np.array([self.soc.outCh2FreqCenter(outCh)])
        amps = np.array([0.9])
        fis = np.array([0.0])
        bandwidth = self.soc.fcOut / 100
        self.mndScan = self.fscan(freqs, amps, fis, 
                                  bandwidth, nf, decimation, nt,
                      iBegin, nsamp, pfbOutQout, verbose=verbose, doProgress=doProgress)
       
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

def applyCalibration(fscan, calibration, amplitudeMax=30000):
    fscanCalib = copy.deepcopy(fscan)
    nominalDelay = calibration['nominalDelay']
    applyDelay(fscanCalib, nominalDelay)
    if nominalDelay != fscanCalib['delayApplied']:
        raise ValueError("fscan already had a delay applied", nominalDelay, fscanCalib['delayApplied'])
    dfs = fscanCalib['dfs']
    for iTone,(freq,xs) in enumerate(zip(fscanCalib['freqs'],fscanCalib['xs'])):
        freqs = freq+dfs
        xCalib = np.zeros(len(freqs), dtype=complex)
        for i, freq in enumerate(freqs):
            iCalib = np.searchsorted(calibration['fList'], freq)-1 
            xCalib[i] = calibration['cInterps'][iCalib](freq)
        gain = amplitudeMax/np.abs(xCalib)
        fscanCalib['xs'][:,iTone] *= gain
        dfi = np.angle(xCalib)
        xs = fscanCalib['xs'][:,iTone]
        fscanCalib['xs'][:,iTone] = np.abs(xs)*np.exp(1j*(np.angle(xs)-dfi))
    return fscanCalib                                                     


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
    for i,fTone in enumerate(freqs):
        allfreqs[i,:] = freqs[i]+dfs
    allfreqs = allfreqs.ravel()
    xs = np.transpose(fscan['xs'])
    allamps = np.abs(xs).ravel()
    allfis = np.angle(xs).ravel()
    inds = np.argsort(allfreqs)
    return allfreqs[inds], allamps[inds], allfis[inds]
   
def applyDelay(fscan, delay):
    try:
        fscan['delayApplied'] += delay
    except KeyError:
        fscan['delayApplied'] =  delay
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
