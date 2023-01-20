import sys
import MkidsSoc
import numpy as np
import xrfdc
           
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

        self.nInCh = self.pfb_in.N
        self.fcIn = self.pfb_in.get_fc()
        self.fbIn = self.pfb_in.get_fb()
        self.nOutCh = self.pfb_out.N
        self.fcOut = self.pfb_out.get_fc()
        self.fbOut = self.pfb_out.get_fb()
        
        # Start streamer and set default transfer length.
        self.streamLength = streamLength
        self.stream.set_nsamp(streamLength)

        self.pfb_in.qout(8)
        self.setDecimate(decimation)
        
        # Define the mixer
        self.mixer = Mixer(soc._soc.usp_rf_data_converter_0)
        self.multiTile = soc.multiTile
        self.multiBlock = soc.multiBlock
        
        self.dfMixer = 0.25
        self.fMixerQuantized = None
        self.setFMixer(1024.25) # Set a default value for the mixer
     
        # First Dummy transfer for DMA.
        self.chsel.set_single(0)
        self.stream.transfer_raw(streamLength, first=True)
        self.chsel.alloff()

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
        fOutCenters = self.outCh2freq(ch)
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
