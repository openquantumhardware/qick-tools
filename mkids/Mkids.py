import sys
import MkidsSoc
import numpy as np
import xrfdc
import copy, time 
from collections import OrderedDict
from numpy.polynomial.polynomial import Polynomial
from scipy.interpolate import interp1d

from tqdm.notebook import trange, tqdm
import matplotlib.pyplot as plt
class Mixer():
    # rf
    rf = 0
    
    def __init__(self, ip):        
        # Get Mixer Object.
        self.rf = ip
    
    def set_freq(self,f,tile,dac):
        # Make a copy of mixer settings.
        dac_mixer = self.rf.dac_tiles[tile].blocks[dac].MixerSettings        
        new_mixcfg = dac_mixer.copy()

        # Update the copy
        new_mixcfg.update({
            'EventSource': xrfdc.EVNT_SRC_IMMEDIATE,
            'Freq' : f,
            'MixerType': xrfdc.MIXER_TYPE_FINE,
            'PhaseOffset' : 0})

        # Update settings.             
        self.rf.dac_tiles[tile].blocks[dac].MixerSettings = new_mixcfg
        self.rf.dac_tiles[tile].blocks[dac].UpdateEvent(xrfdc.EVENT_MIXER)
       
    def set_nyquist(self,nz,tile,dac):
        dac_tile = self.rf.dac_tiles[tile]
        dac_block = dac_tile.blocks[dac]
        dac_block.NyquistZone = nz          

 
class Mkids():
    def __init__(self, soc, decimation=2, streamLength=10000):
        self.soc = soc

        # Point to useful parts of the soc
        self.stream = self.soc._soc.stream
        self.pfb_in = self.soc._soc.pfb_in
        self.fsIn = self.soc.fsIn
        self.pfb_out = self.soc._soc.pfb_out
        self.fsOut = self.pfb_out.fs
        self.ddscic = self.soc._soc.ddscic
        self.chsel = self.soc._soc.chsel
        self.board = self.soc.board
        self.dds_out = self.soc._soc.dds_out
        self.nInCh = self.pfb_in.N
        self.fcIn = self.pfb_in.get_fc()
        self.fbIn = self.pfb_in.get_fb()
        self.nOutCh = self.pfb_out.N
        self.fcOut = self.pfb_out.get_fc()
        self.fbOut = self.pfb_out.get_fb()
        self.dfDdsMhz = max(self.dds_out.DF_DDS,self.ddscic.DF_DDS)/1e6
        
        # Setup streaming
        self.setStreamLength(streamLength)
        self.chsel.set_single(0)
        self.stream.transfer_raw(streamLength, first=True)
        self.chsel.alloff()
        
        self.pfb_in.qout(8)
        self.setDecimate(decimation)
        
        # Define the mixer
        self.mixer = Mixer(soc._soc.usp_rf_data_converter_0)
        self.multiTile = soc.multiTile
        self.multiBlock = soc.multiBlock
        
        self.dfMixer = 0.25
        self.fMixerQuantized = None
        self.setFMixer(1024.25) # Set a default value for the mixer
     
        
        # Calibration information
        self.nominalDelayMts = None

    def setStreamLength(self, streamLength):
        self.streamLength = streamLength
        self.stream.set_nsamp(streamLength)
        # do a dummy transfer to clear out old data here?
       
        
    def setDecimate(self, decimate):
        """
        Set the decimation value pfbcic values 
        
        Parameters
        ---------- 
        decimate : int
            decimation value, in the range [2,250]
            
        """
        self.ddscic.decimation(decimate)
        #self.setSwitchSrc(self.switchSrc)
        self.fb = self.fsIn/((self.pfb_in.N/2)*self.ddscic.get_decimate())
        self.time = self.streamLength/(self.fb*1e6) # In Seconds
        self.msecs = np.arange(self.streamLength)/(self.fb*1e3) # For plotting, in milli seconds

    def info(self, stream=sys.stdout):
        print("Board model: %s"%self.board, file=stream)
        print("Input:", file=stream)
        print("         number of input channels: %7d"%self.nInCh)
        print("         input sampling frequency: %7.2f MHz"%self.fsIn)
        print("  bandwidth of each input channel: %7.2f MHz"%self.fbIn)
        print("   spacing between input channels: %7.2f MHz"%self.fcIn)
        print("            total input bandwidth: %7.2f MHz"%(self.nInCh*self.fcIn))
        print("Output:", file=stream)
        print("        number of output channels: %7d"%self.nOutCh)
        print("        output sampling frequency: %7.2f MHz"%self.fsOut)
        print(" bandwidth of each output channel: %7.2f MHz"%self.fbOut)
        print("  spacing between output channels: %7.2f MHz"%self.fcOut)
        print("           total output bandwidth: %7.2f MHz"%(self.nOutCh*self.fcOut))

        print("")
        print("      frequency quantization size: %f Hz"%(1e6*self.dfDdsMhz))
        
    def setFMixer(self, fMixer):
        self.fMixerRequested = fMixer
        temp = self.dfMixer*np.floor(fMixer/self.dfMixer)
        # Send the command to set_freq only if it is new
        if temp != self.fMixerQuantized:
            self.fMixerQuantized = temp
            self.mixer.set_freq(self.fMixerQuantized,
                                self.multiTile, 
                                self.multiBlock)
            
            
    def inFreq2ch(self, frequency):
        """
        Return the input PFB bin that contains the frequency

        Parameters
        ----------
        frequency : double
            in MHz

        Returns
        -------
            ch : int
                the PFB channel
        """  
        N = self.pfb_in.N
        fc = self.fsIn/N
        k =np.round(frequency/fc)
        ch = (np.mod(k+N/2, N)).astype(int)
        return ch


    def inFreq2chOffset(self, frequency):
        """
        Return the input PFB bin that contains the frequency, along with the offset from the center


        Parameters
        ----------
        frequency : double
            in MHz
            
        Returns
        -------
            tuple (ch,offset) 
            
            ch : int
                the PFB channel
            offset : offset
                offset from the center frequency, in MHz
        """  

        N = self.pfb_in.N
        fc = self.fsIn/N
        k = np.round(frequency/fc)
        ch = (np.mod(k+N/2, N)).astype(int)
        fCenter = k*fc
        offset = frequency-fCenter
        return ch,offset
    
    def inCh2FreqCenter(self, ch):
        """
        Converts from input channel number to the frequency at the center of that channel

        Parameters
        ----------
        ch : int
            The PFB channel

        Returns
        -------
        fCenter : double
            frequency at the center of the channel (MHz)
        """
   
        fCenter = np.mod(ch*self.fsIn/self.pfb_in.N + self.fsIn/2, self.fsIn)
        return fCenter
    
    def outFreq2ch(self, frequency):
        """
        Return the output PFB bin that contains the frequency

        Parameters
        ----------
        frequency : double
            in MHz

        Returns
        -------
            ch : int
                the PFB channel
        """  
        f = frequency - self.fMixerQuantized
        ch = self.pfb_out.freq2ch(f)
        return ch
    
    def outFreq2chOffset(self, frequency):
        """
        Return the output PFB bin that contains the frequency, along with the offset from the center


        Parameters
        ----------
        frequency : double
            in MHz
            
        Returns
        -------
            tuple (ch,offset) 
            
            ch : int
                the PFB channel
            offset : offset
                offset from the center frequency, in MHz
        """  

        f = frequency - self.fMixerQuantized
        ch = self.pfb_out.freq2ch(f)
        fOutCenters = self.outCh2FreqCenter(ch)
        offsets = f - fOutCenters + self.fMixerQuantized
        return ch,offsets
 
    
    def outCh2FreqCenter(self, ch):
        """
        Converts from output channel number to the frequency at the center of that channel

        Parameters
        ----------
        ch : int
            The PFB channel

        Returns
        -------
        fCenter : double
            frequency at the center of the channel (MHz)
        """
        f = self.pfb_out.ch2freq(ch)
        frequency = f + self.fMixerQuantized
        return frequency

    def setMultiTones(self, frequencies, amplitudes, fis, fMixer, verbose=False):
        """
        Generates tones on the output DAC
        """
        self.setFMixer(fMixer)
        self.multiAmplitudes = amplitudes
        self.multiFreqs = np.floor(frequencies/self.dfDdsMhz)*self.dfDdsMhz
        if verbose: 
            print("setMultiTones:  multiFreqs =",self.multiFreqs)
        if not self.outTonesInUniqueChannels(self.multiFreqs, fMixer):
            for freq in self.multiFreqs:
                outCh = self.outFreq2ch(freq)
                print("Trouble:  outCh=%4d freq=%f"%(outCh,freq))
            raise ValueError("Tones are not in unique output channels")
        self.multiFis = fis
        self.dds_out.alloff()
        self.setFMixer(fMixer)
        if verbose:
            print("setMultiTones:  fMixer =",fMixer, " fMixerQuantized =",self.fMixerQuantized)
        self.multiOutChs, self.multiOutDdss = self.outFreq2chOffset(self.multiFreqs)
        for multiOutDds, amplitude, outCh, fi in zip(self.multiOutDdss, self.multiAmplitudes, self.multiOutChs, self.multiFis):
            if verbose:
                print("setMultiTones:  outCh=%4d f=%+f amplitude=%f "%(outCh, multiOutDds, amplitude))
            self.dds_out.ddscfg(f=multiOutDds*1e6, fi=np.degrees(fi), g=amplitude, ch=outCh)
        # Prepare for readouts
        self.multiInChs, self.inDdss = self.inFreq2chOffset(self.multiFreqs)
        self.ddscic.dds_outsel(outsel="product")
        for inCh, inDds in zip(self.multiInChs, self.inDdss):       
            if verbose:
                print("setMultiTones:   inCh=%4d f=%+f"%(inCh, inDds))
            self.ddscic.set_ddsfreq(inCh, inDds*1e6)
        self.idxs = np.mod(self.multiInChs,8)
        self.setupReadAllMultitones(verbose)
        return
     
    def outTonesInUniqueChannels(self, outFreqs, fMixer):
        """ See if requested tones are in unique channels.  Returns a boolean"""
        self.setFMixer(fMixer)
        outChs = self.outFreq2ch(outFreqs)
        nUnique = len(np.unique(outChs))
        return nUnique == len(outChs)
    
    def setupReadAllMultitones(self, verbose=False):
        self.chsel.alloff()
        datas = np.zeros(int(self.chsel.NM), dtype=np.uint32)
        for inCh in self.multiInChs:
            [ntran, bit] = self.chsel.ch2tran(inCh)
            addr = int(np.floor(ntran/32))
            datas[addr] |= 2**bit
            if verbose: print("setupReadAllMultitones: for inCh=%d set bit=%d in addr=%d"%(inCh,bit,addr))
        for addr,data in enumerate(datas):
            if verbose: print("setupReadAllMultitones: addr=%2d  data=%08x"%(addr,data))
            self.chsel.addr_reg = addr
            self.chsel.data_reg = data
            self.chsel.we_reg = 1
            self.chsel.we_reg = 0
        time.sleep(0.1)
        _ = self.stream.transfer(nt=1)
        
    def readAllMultiTones(self, nt=1):
        packets = self.stream.transfer(nt=nt)
        self.packets = packets # stash this here in case you want to inspect in detail
        data_iq = packets[:,:,:16].reshape((-1,16)).T
        d16 = packets[:,:,16]
        data_iqs = OrderedDict()
        nSamples = OrderedDict()
        xs = OrderedDict()
        for inCh in self.multiInChs:
            inCh8 = inCh//8
            data_iqs[inCh8] = []
            nSamples[inCh8] = 0
        for it in range(packets.shape[0]):
            i0 = it*packets.shape[1]
            i1 = i0+packets.shape[1]
            for inCh8 in np.unique(np.int16(self.multiInChs/8)):
                data_iqs[inCh8].append(data_iq[:,i0:i1][:,d16[it,:]==inCh8])
                nSamples[inCh8] += (data_iqs[inCh8][-1].size)//16
        for inCh,idx in zip(self.multiInChs, self.idxs):
            inCh8 = inCh//8
            xs[inCh] = np.zeros(nSamples[inCh8], dtype=complex)
            i0 = 0
            i1 = 0
            for data_iq in data_iqs[inCh8]:
                i1 += data_iq.size//16
                xs[inCh][i0:i1].real, xs[inCh][i0:i1].imag = data_iq[2*idx:2*idx+2]
                i0 = i1
        return xs

    def fiAmpFromMulti(self, fTones, fis, amplitudes,fMixer, nt=1, verbose=False):
        if verbose:
            print("fiAmpFromMulti:  fTones =",fTones)
        xs = self.setAndReadMultiTones(np.array(fTones), np.array(fis),
                                       np.array(amplitudes), fMixer, nt, 
                                       verbose=verbose)
        inChs = self.inFreq2ch(np.array(fTones))
        fiOuts = np.zeros(len(fTones))
        ampOuts = np.zeros(len(fTones))
        for i,inCh in enumerate(inChs):
            x = xs[inCh]
            fiMeas = np.angle(x.mean())
            fiOuts[i] = np.angle(np.exp(1j*(fiMeas-fis[i])))
            ampOuts[i] = np.abs(x.mean())
        return fiOuts, ampOuts
    
    def setAndReadMultiTones(self, fTones, fis, amplitudes,fMixer,nt=1,verbose=False):
        self.setMultiTones(np.array(fTones), np.array(amplitudes),  np.array(fis),
                           fMixer, verbose=verbose)   
        self.setupReadAllMultitones()
        xs = self.readAllMultiTones(nt=nt)
        return xs
  
    def multiToneScan(self, fTones, amplitudes, fis, bandwidth, nMeas, fMixer, nt,
                      includeEndpoints=False,
                      verbose=False, doProgress=False):
        
        """
        Perform a scan with multiple tones

        Parameters
        ----------
        fTones:
            np array of tone frequencies at center of scan [MHz]
        amplitudes:
            np array of tone amplitudes (ranging from 0 to 1)
        fis:
            np array of phase values, in Radians
        
        bandwidth:
            width of scan, in MHz
            
        nMeas:
            number of measurements to make inside the bandwidth
        
        fMixer:
            mixer frequency (in MHz)
            
        nt:
            number of measurements at each frequency step
            
        verbose:
            True to dump output
            
        doProgress:
            True to show tqdm progress bar
            
        Returns
        -------
        
        A dictionary containing:
        'dfs' -- the nMeas delta frequency values used to scan [MHz]
        'amplitudes' -- the measured amplitudes, for each tone
        'fis' -- the measured phases [Radians]
        'fMixer' -- the mixer frequency used 
        'fTones' -- the central tone values used
        """
  
        self.setFMixer(fMixer)
        if verbose:
            print("multiToneScan:  fTones =",fTones)
        if nMeas == 1:
            dfs = np.zeros(1)
        else:
            if includeEndpoints:
                dfs = np.linspace(0, bandwidth, num=nMeas, endpoint=True) - bandwidth/2
            else:
                dfs = (0.5+np.arange(nMeas))*bandwidth/(nMeas) - bandwidth/2
        if verbose:
            print("multiToneScan:  dfs =",dfs)
        fiOuts = np.zeros((len(fTones), nMeas ))
        ampOuts = np.zeros((len(fTones), nMeas))

        if doProgress:
            iValues = trange(len(dfs))
        else:
            iValues = range(len(dfs))
        for i in iValues:
            df = dfs[i]
            if verbose:
                print("multiToneScan:  i=%d  df=%f"%(i,df))
                print("multiToneScan:  fTones+df =",fTones+df)
            fiOuts[:,i], ampOuts[:,i] = self.fiAmpFromMulti(fTones+df, fis, amplitudes, fMixer, nt,verbose=verbose)
        return {"dfs":dfs,"fis":fiOuts,"amplitudes":ampOuts,
                "fMixer":fMixer, "fTones":fTones}
     
    def mtsPlot(self, mts, iTone, milliRad=False):
        """
        Plot the values in the results of multiTonScan (mts) for the tone.
        
        Use millrad=True to expand phase axis
        """
        freqs = mts['dfs'] + mts['fTones'][iTone]
        amplitudes = mts['amplitudes'][iTone]
        fis = mts['fis'][iTone]
        fig,ax = plt.subplots(2,1,sharex=True)
        fc = freqs.mean()
        ax[0].plot(freqs-fc, amplitudes, "o-")
        ax[0].set_ylabel("amplitude [ADCs]")
        ax[1].set_xlabel("frequency-%.2f [MHz]"%fc)

        if milliRad:
            fisMean = fis.mean()
            ax[1].plot(freqs-fc, 1000*(fis-fisMean), "o-")
            ax[1].set_ylabel("$\Delta$ phase [mRadians]")
        else:
            ax[1].plot(freqs-fc, fis, "o-")
            ax[1].set_ylabel("phase [Radians]")
 
    def mtsUnwind(self, mts):
        """
        organize the results of a multiToneScan to three arrays, returning
        a tuple of (freqs, amps, fis)
        """
        dfs = mts['dfs']
        fTones = mts['fTones']
        freqs = np.zeros((len(fTones),len(dfs)))
        #amps = np.zeros((len(fTones),len(dfs)))
        #fiss = np.zeros((len(fTones),len(dfs)))
        for i,fTone in enumerate(fTones):
            freqs[i,:] = fTones[i]+dfs
            #amps[i,:] = mts['amplitudes'][i]
            #fis[i,:] =  mts['fis']
        freqs = freqs.ravel()
        amps = mts['amplitudes'].ravel()
        fis = mts['fis'].ravel()
        inds = np.argsort(freqs)
        return freqs[inds], amps[inds], fis[inds]

    def measureNominalDelay(self, outCh, nMeas=10, nt=1, verbose=False, doProgress=False, doPlot=False):
        """
        Measure the nominal delay near the center of one output channel.
        
        Parameters
        ----------
        outCh
            output channel number to use
            
        nMeas
            number of frequency steps to take
            
        nt
            number of measurements each frequency
            
        verbose
            True to get diagnostics printed to stdout
            
        doProgress
            True to show progress bar in a jupyter notebook
            
        doPlot
            True to make a plot to show fit and residual
            
        Return
        ------
        nominalDelay
            in microseconds
        """
        toneFreqs = np.array([self.outCh2FreqCenter(outCh)])
        toneAmplitudes = np.array([0.9])
        toneFis = np.array([0.0])
        bandwidth = self.fcOut/1000
        fMixer = self.fMixerQuantized
        self.nominalDelayMts = self.multiToneScan(toneFreqs, toneAmplitudes, toneFis,
                                            bandwidth, nMeas, fMixer, nt, 
                                            verbose=verbose,
                                            doProgress=doProgress)
        iTone = 0
        dfs = self.nominalDelayMts['dfs']
        fis = self.nominalDelayMts['fis'][iTone]
        ufis = self.unwrapPhis(fis)
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

    def unwrapPhis(self, phis, sign=1):
        """
        Increment (or decrement) values after a large change in phase to unwrap them
        """
        uphis = sign*(phis.copy())
        for i in range(1,len(uphis)):
            if uphis[i-1] > uphis[i]:
                uphis[i:] += 2*np.pi
        return sign*uphis

    def applyDelayCorrection(self, mts, delay):
        """
        Apply the delay correction to phases in the mts
        
        Parameters
        ----------
        
        mts
            results of the multi tone scan to correct
            
        delay
            result of measureNominalDelay (in microseconds)
            
        Return
        ------
        mtsOut
            a deep copy of the input mts with phases corrected
        """
        mtsOut = copy.deepcopy(mts)
        for iTone in range(len(mtsOut['fis'])):
            freqs = mts['fTones'][iTone] + mts['dfs']
            fis = mts['fis'][iTone]
            mtsOut['fis'][iTone] = np.angle(np.exp(1j*(fis - delay*freqs)))
        return mtsOut
    
    def makeCorrection(self, fMixer, fMin, fMax, delay, nMeas=100, nt=4, verbose=True):
        self.setFMixer(fMixer)
        fcMax = max(self.fcIn, self.fcOut)
        fcMin = min(self.fcIn, self.fcOut)
        print(fcMin, fcMax)
        fMinCentered = self.outCh2FreqCenter(self.outFreq2ch(fMin))
        fMaxCentered = self.outCh2FreqCenter(self.outFreq2ch(fMax))
        fTones =  np.arange(fMin-fcMax, fMax+fcMax, self.fcOut)
        toneAmplitudes = np.ones(len(toneFreqs))*0.9/len(toneFreqs)
        np.random.seed(12394321)
        toneFis = 2* np.pi * np.random.uniform(size=len(toneFreqs))
        bandwidth = mkids.fcOut
        nMeas = 100
        
    def makeCorrectionsOld(self, fMin, fMax, mts, delay, verbose=True):
        """
        With the frequencies use the results of the mts to create a calibration dictionary.  Begin by applying the delay corrections to the phases, and then save data segments of frequency,amplitude, and phase.
        
        The mts is from multiToneScan, where it is configured to yield a continuous measurements in the frequency range.
        
        delay is the nominal delay
        """
        if verbose:
            print("makeCorrectionsOld: fMin,fMax =",fMin,fMax)
        fList = []
        # Add boundaries of input channels to fList
        
        freq = self.inCh2FreqCenter(self.inFreq2ch(fMin)) -  self.fcIn/2
        fEnd = self.inCh2FreqCenter(self.inFreq2ch(fMax)) +  self.fcIn/2
        while True:
            fList.append(freq)
            freq += self.fcIn
            if freq >= fEnd: 
                fList.append(freq)
                break

        print(self.outFreq2ch(fMin))       
        freq = self.outCh2FreqCenter(self.outFreq2ch(fMin)) -  self.fcOut/2
        fEnd = self.outCh2FreqCenter(self.outFreq2ch(fMax)) +  self.fcOut/2
        while True:
            fList.append(freq)
            freq += self.fcOut
            if freq >= fEnd: 
                fList.append(freq)
                break

        fList = np.sort(np.unique(np.array(fList)))
        mtsDelayed = self.applyDelayCorrection(mts, delay)
        freqs, amps, fis = self.mtsUnwind(mtsDelayed)
        freqsCorr = []
        ampsCorr = []
        fisCorr = []
        for i in range(len(fList)-1):
            inds = (freqs > fList[i]) & (freqs < fList[i+1]) # non-inclusive both sides
            freqsCorr.append(freqs[inds])
            ampsCorr.append(amps[inds])
            fisCorr.append(fis[inds])
        if verbose:
            print("makeCorrectionsOld:  fList =",fList)
        
        correction = {
            "fMixer":self.fMixerQuantized,
            "fList":fList,
            "freqsCorr":freqsCorr,
            "ampsCorr":ampsCorr,
            "fisCorr":fisCorr,
            "fMin":fMin,
            "fMax":fMax,
            "delay":delay}
        
        return correction
        
#when to apply delay correction the MTS used to make corrections, and to this mts?

    def applyCorrection(self, mts, correction, verbose=False):
        """
        Apply the amplitude, phase, and delay corrections.
        
        The mts is from multiToneScan.
        """
        if verbose: print("applyCorrection:  delay =",correction['delay'])
        mtsDelayed = self.applyDelayCorrection(mts, correction['delay'])
 
        if verbose: print("applyCorrection: prepare interpolation functions")
        ampFuncsCorr = []
        fiFuncsCorr = []
        for freqs,amps,fis in zip(correction['freqsCorr'],correction['ampsCorr'],correction['fisCorr']):
            ampFuncsCorr.append(interp1d(freqs,amps))
            fiFuncsCorr.append(interp1d(freqs,fis))

        fList = correction['fList']
        for iTone in range(len(mtsDelayed['fTones'])):
            if verbose: print(" iTone =", iTone)
            freqs = mtsDelayed['dfs'] + mtsDelayed['fTones'][iTone]
            amplitudes = mtsDelayed['amplitudes'][iTone]
            fis = mtsDelayed['fis'][iTone]
            #plt.plot(freqs,fis)
            for iPoint, (freq,amplitude,fi) in enumerate(zip(freqs,amplitudes,fis)):
                index = np.searchsorted(fList, freq) - 1
                ampCorr = ampFuncsCorr[index](freq)
                fiCorr = fiFuncsCorr[index](freq)
                #print(freq, index, amplitude,ampCorr, fi, fiCorr)
                mtsDelayed['amplitudes'][iTone][iPoint] = amplitude/ampCorr
                mtsDelayed['fis'][iTone][iPoint] =  np.angle(np.exp(1j*(fi-fiCorr)))
        return mtsDelayed 