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
        firmwareName : str
            the name of the firmware to load, as reported by Scan.availableBitfiles()
            
        iKids : int, default 0
            which instance of KIDS IP to use
            
        iSimu : int, default 0
            which instantc of SIMU IP to use
        
        """
        board = getBoard()
        full_path = os.path.realpath(__file__)
        path, filename = os.path.split(full_path)
        bitpath = str(Path(path).parent.joinpath(Path(board), firmwareName+'.bit'))
        self.soc = MkidsSoc(bitpath)
        self.kidsChain = KidsChain(self.soc, dual=self.soc['dual'][iKids])
        self.simuChain = SimuChain(self.soc, simu=self.soc['simu'][iSimu])
        # Set quantization.
        self.simuChain.analysis.qout(3)
        self.simuChain.synthesis.qout(3) 
        # Disable all resonators
        self.simuChain.alloff()
        # Some useful constants
        fsDualOut = self.soc['dual'][0]['synthesis']['fs']
        fsDualIn = self.soc['dual'][0]['analysis']['fs']
        fsSimuOut = self.soc['simu'][0]['synthesis']['fs']
        fsSimuIn = self.soc['simu'][0]['analysis']['fs']
        assert fsDualOut == fsDualIn ==fsSimuOut == fsSimuIn, "fs not all equal: fsDualOut=%f, fsDualIn=%f, fsSimuOut=%f, fsSimuIn=%f"%(fsDualOut, fsDualIn, fsSimuOut, fsSimuIn)
        self.fs = fsDualOut

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
        fMixerSet = self.get_mixer()
        return fMixerSet

    def get_mixer(self):
        """
        Get the mixer frequency, after checking that KIDS and SIMU chains are the same
        
        Returns:
        --------
        fMixerSet : dbl
            the actual (quantized) frequency in MHz    
        """
        fMixerKids = self.kidsChain.synthesis.get_mixer_frequency()
        fMixerSimu = self.simuChain.synthesis.get_mixer_frequency()
        assert fMixerKids == fMixerSimu, "Trouble mixers not set correctly:  fMixerKids=%f fMixerSimu=%f"%(fMixerKids, fMixerSimu)
        return fMixerKids

    
    def nZoneFromFTone(self, fTone):
            """ Return the Nyquist zone for the frequency fTone"""
            fn = self.fs/2
            div,mod = np.divmod(fTone,fn)
            nZone = div.astype(int) + 1
            return nZone

    def fAliasedFromFTone(self, fTone):
            """ Return the aliased frequency for the frequency fTone"""
            fn = self.fs/2
            nZone = self.nZoneFromFTone(fTone)
            fAliased = nZone*fn - fTone # This is for the even-numbered Nyquist zones
            oddInds = np.mod(nZone,2) == 1
            try:
                fAliased[oddInds] =  fTone[oddInds] - (nZone[oddInds]-1)*fn
            except TypeError:
                if oddInds:
                    fAliased -= (nZone-1)*fn
            return fAliased

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
    
    