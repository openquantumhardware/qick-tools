import sys
import MkidsSoc
import numpy as np
import xrfdc
import time 
from collections import OrderedDict
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

    def setMultiTones(self, amplitudes, frequencies, fis, fMixer, verbose=False):
        """
        Generates tones on the output DAC
        """
        self.multiAmplitudes = amplitudes
        self.multiFreqs = np.floor(frequencies/self.dfDdsMhz)*self.dfDdsMhz
        if verbose: 
            print("setMultiTones:  multiFreqs =",self.multiFreqs)
        if not self.outTonesInUniqueChannels(self.multiFreqs, fMixer):
            for freq in self.multiFreqs:
                outCh = self.outFreq2ch(freq)
                print("outCh=%4d freq=%f"%(outCh,freq))
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



