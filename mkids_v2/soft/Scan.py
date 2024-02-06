from pathlib import Path
from mkids import *
import os
class Scan():
    """ Convenience class to deal with MKIDs and Resonator firmware to set and scan tones"""
    def __init__(self, firmwareName, iKids=0, iSimu=0):
        """
        Load and initialize the named firmware
        
        Parameters
        ----------
        firmwareName : str or MkidsSoc instance
            the name of the firmware to load, as reported by Scan.availableBitfiles(), or previously-loaded firmware soc
            
        iKids : int, default 0
            which instance of KIDS IP to use
            
        iSimu : int, default 0
            which instance of SIMU IP to use
        
        """
        board = getBoard()
        if not isinstance(firmwareName, MkidsSoc):
            full_path = os.path.realpath(__file__)
            path, filename = os.path.split(full_path)
            bitpath = str(Path(path).parent.joinpath(Path(board), firmwareName+'.bit'))
            self.soc = MkidsSoc(bitpath)
        else:
            self.soc = firmwareName
            firmwareName = os.path.splitext(os.path.split(self.soc.bitfile_name)[1])[0]
        self.iKids = iKids
        self.iSimu = iSimu
        self.kidsChain = KidsChain(self.soc, dual=self.soc['dual'][iKids])
        
        self.kidsChain.analysis.set_decimation(2)
        self.kidsChain.analysis.source("product")
        
        self.nInCh = self.kidsChain.analysis.dict['chain']['nch']
        self.nOutCh = self.kidsChain.synthesis.dict['chain']['nch']        
        self.simuChain = SimuChain(self.soc, simu=self.soc['simu'][iSimu])
        self.dfChannel = self.kidsChain.analysis.dict['chain']['fc_ch']
        # Set quantization.
        self.simuChain.analysis.qout(3)
        self.simuChain.synthesis.qout(3) 
        # Disable all resonators
        self.simuChain.alloff()
        # Some useful constants
        fsDualOut = self.soc['dual'][iKids]['synthesis']['fs']
        fsDualIn = self.soc['dual'][iKids]['analysis']['fs']
        fsSimuOut = self.soc['simu'][iSimu]['synthesis']['fs']
        fsSimuIn = self.soc['simu'][iSimu]['analysis']['fs']
        assert fsDualOut == fsDualIn ==fsSimuOut == fsSimuIn, "fs not all equal: fsDualOut=%f, fsDualIn=%f, fsSimuOut=%f, fsSimuIn=%f"%(fsDualOut, fsDualIn, fsSimuOut, fsSimuIn)
        fsAdc, fsDac = self.soc.getSamplingFrequencies(self.iKids)
        if fsAdc != fsDac:
            raise ValueError("Scan assumes fsAdc=fsDac but fsAdc=%f fsDac=%f"%(fsAdc, fsDac))
        self.fNyquist = fsAdc/2
        
        # Nominal delay
        self.nominalDelay = 0
        if firmwareName == "mkids_2x2_kidsim_v2" and board == "zcu216":
            self.nominalDelay = -8.51 # microseconds
        elif firwareName == "mkids_v3" and board == "rfsoc4x2":
            self.nominalDelay = -4.262 # microsecionds found in demo__06_phase.ipynb

    def set_mixer(self, fMixer):
        """ 
        Set all the mixers
        
        Parameters:
        -----------
        fMixer : dbl
             requested mixer frequency in MHz
        
        Returns:
        --------
        fMixerSet : dbl
            the actual (quantized) frequency in MHz
        """
        self.simuChain.set_mixer_frequency(fMixer)
        self.kidsChain.set_mixer_frequency(fMixer)
        self.fMixer = self.get_mixer()
        return self.fMixer

    def get_mixer(self):
        """
        Get the mixer frequency, after checking that KIDS and SIMU chains are the same
        
        Returns:
        --------
        fMixerSet : double
            the actual (quantized) frequency in MHz    
        """
        fMixerKids = self.kidsChain.synthesis.get_mixer_frequency()
        fMixerSimu = self.simuChain.synthesis.get_mixer_frequency()
        assert fMixerKids == fMixerSimu, "Trouble mixers not set correctly:  fMixerKids=%f fMixerSimu=%f"%(fMixerKids, fMixerSimu)
        return fMixerKids

    
    def nZoneFromFTone(self, fTone):
            """ 
            Return the Nyquist zone for the frequency fTone
            
            Parameters:  
            -----------           
            fTone: double or nparray of doubles
                tone frequncy in MHz
                
            Returns:
            --------
            fAliased: int or nparray of ints
                The Nyquist zone for the fTone
            """
            
            div,mod = np.divmod(fTone,self.fNyquist)
            nZone = div.astype(int) + 1
            return nZone

    def fAliasedFromFTone(self, fTone):
            """ 
            Return the aliased frequency for the frequency fTone
            
            Parameters:  
            -----------            
            fTone: double or nparray of doubles
                tone frequency in MHz
                
            Returns:
            --------
            fAliased: double or nparray of doubles
                The aliased frequency to generate for the fTone
            """
            fn = self.fNyquist
            nZone = self.nZoneFromFTone(fTone)
            fAliased = nZone*fn - fTone # This is for the even-numbered Nyquist zones
            oddInds = np.mod(nZone,2) == 1
            try:
                fAliased[oddInds] =  fTone[oddInds] - (nZone[oddInds]-1)*fn
            except TypeError:
                if oddInds:
                    fAliased -= (nZone-1)*fn
            return fAliased
        
    def inFreq2ch(self, inFreqs):
        """ Return input channel numbers of the input frequencies"""
        return self.kidsChain.analysis.freq2ch(inFreqs)
    
    def inCh2Freq(self, inChs):
        """ Return the frequency at the center of the input channels"""
        return self.kidsChain.analysis.ch2freq(inChs)

    def outFreq2ch(self, outFreqs):
        """ Return input channel numbers of the output frequencies"""
        return self.kidsChain.synthesis.freq2ch(outFreqs)
    
    def outCh2Freq(self, outChs):
        """ Return the frequency at the center of the output channels"""
        return self.kidsChain.synthesis.ch2freq(outChs)

    def sweep_tones(self, freqs, fis, gs, cgs, bandwidth, nf, doProgress=True, verbose=False, mean=True, nPreTruncate=100, doApplyDelay=True, additionalDelay = 0.0, phiCenter = 0.0):
        """
        Perform a frequency sweep of the tones set by set_tones()
                        
        Parameters:
        -----------
            freqs:  np array of double
                Tone frequency (MHz)
            fis: np array of double
                Tone phase (Radians)
            gs: np array of double
                Gains, in the range [0,1) but note that it is your responsibilty 
                confirm that freqs,fis,gs do not saturate
            cgs: np array of complex doubles
                compensation gain, or None to not apply compensation

            bandwidth: double
                nominal width of frequency scan
            nf: int
                number of frequency falues
            doProgress: boolean (default=True)
                show progress bar in a jupyter notebook
            verbose:  boolean (default=False)
                talk to me!
            mean:  boolean (default=True)
                calculates the mean value of all samples
            nPreTruncate: int (default=100)
                number of samples at beginning of read to ignore
                
        Returns:
        --------
            xs : ndarray of complex doubles
                first index:  frequency offset value
                second index: tone number
                third index (if mean=False): sample number
                
        """
        self.kidsChain.set_tones(freqs, fis, gs, cgs, verbose)
        xs = self.kidsChain.sweep_tones(bandwidth, nf, doProgress, verbose, mean, nPreTruncate)
        if doApplyDelay:
            delay = self.nominalDelay + additionalDelay
            xs = applyDelay(freqs, self.kidsChain.scanFOffsets, xs, delay)
        if phiCenter is not None:
            iMid = xs.shape[0]//2
            rotPhis = phiCenter - np.angle(xs[iMid,:])
            xs = rotateTones(xs, rotPhis)
        return xs

def rotateTones(xs, phis):
    """
    Rotate each tone by phi, in place
 
    Parameters:
    -----------
        xs: 2d nparray of complex values
            The second index is the tone number
        phis: 1d nparray of double
            amount to rotate each tone (in Radians)
            
    Returns:
    --------
        None
            The xs values are changed in place
    
    Raises:
    -------
        ValueError
            if the second dimension of xs is not the same as the length of phi
    
    """
    xs = np.abs(xs)*np.exp(1j*(np.angle(xs)+phis))
    return xs

def availableBitfiles():
    """ Return a list of firmware names available. """
    board = getBoard()
    full_path = os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    bitpath = Path(path).parent.joinpath(Path(board))
    retval = []
    for bitfile in bitpath.glob('*.bit'):
        retval.append(bitfile.stem)
    retval.sort()
    return retval

def getBoard():
    """
    Get the name of the board in use.  Note that this is 
    converted to all lowercase, and to work around the
    pynq3 feature that reports zcu208, replace this string
    to report zcu216.  
    """
    board = os.environ["BOARD"].lower().replace("208","216")
    return board
    
def sweptTonesToSpectrum(sweptTones, fTones, scanFOffsets):
    """
    Reorganize results of a simulatanous sweep of N tones to frequency,X arrays
    
    Parameters:
    -----------
        sweptTones: np array of complex
            results returned from Scan.sweep_tones
        fTones: np array of doubles
            nominal tone frequencies (MHz)
        scanFOffsets:
            offset values applied to sweep
            
    Returns:
    --------
        f,x: tuple of
            f: np array of double, frequencies (MHz)
            X: np array of complex, I,Q values (ADUs)
    
    """
    nOffset = sweptTones.shape[0]
    nTones = sweptTones.shape[1]
    nFreqs = nOffset*nTones
    freqs = np.zeros(nFreqs)
    xValues = np.zeros(nFreqs, dtype=complex)
    i = 0
    for iTone in range(nTones):
        for iOffset in range(nOffset):
            freqs[i] = fTones[iTone] + scanFOffsets[iOffset]
            xValues[i] = sweptTones[iOffset,iTone]
            i += 1
    return freqs,xValues