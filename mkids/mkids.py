from pynq import Overlay, allocate
import xrfdc
import xrfclk
from qick.qick import QickSoc, SocIp
import matplotlib.pyplot as plt
import os,sys,time
import numpy as np
from scipy.interpolate import interp1d
from pathlib import Path

class AxisPfb4x4096V1(SocIp):
    bindto = ['user.org:user:axis_pfb_4x4096_v1:1.0']
    REGISTERS = {'qout_reg' : 0}
    
    # Generic parameters.
    N = 4096
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.qout_reg = 0

    def configure(self, fs):
        # Sampling frequency at input.
        self.fs = fs

        # Channel centers.
        self.fc = fs/self.N

        # Channel bandwidth.
        self.fb = fs/(self.N/2)
        
    def freq2ch(self, freq):
        """Compute the correct input PFB channel for a desired frequency.

        Parameters
        ----------
        f : float or array of float
            desired frequency, in MHz

        Returns
        -------
        int or array of int
            PFB channel index (0 to N-1)
        float or array of float
            residual frequency offset that will need to be corrected using the DDS
        float or array of float
            center frequency of the PFB channel, in MHz
        int or array of int
            "unwrapped" channel number, for phase correction
        """
        if isinstance(freq, list):
            freq = np.array(freq)
        fc = self.fc
        n = self.N
        ch, remainder = np.divmod(freq+fc/2,fc)
        return np.int64(ch+n//2)%n, remainder-fc/2, fc*ch, ch

    def ch2freq(self,ch):
        if ch >= self.N/2:
            return ch*self.fc - self.fs/2
        else:
            return ch*self.fc + self.fs/2


    def get_fs(self):
        return self.fs

    def get_fc(self):
        return self.fc

    def get_fb(self):
        return self.fb
        
    def qout(self, qout):
        self.qout_reg = qout
        

class AxisPfb4x1024V1(SocIp):
    """input PFB
    """
    bindto = ['user.org:user:axis_pfb_4x1024_v1:1.0']
    REGISTERS = {'qout_reg' : 0}
    
    # Generic parameters.
    N = 1024
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.qout_reg = 0

    def configure(self, fs):
        # Sampling frequency at input.
        self.fs = fs

        # Channel centers.
        self.fc = fs/self.N

        # Channel bandwidth.
        self.fb = fs/(self.N/2)

    def freq2ch(self, freq):
        """Compute the correct input PFB channel for a desired frequency.

        Parameters
        ----------
        f : float or array of float
            desired frequency, in MHz

        Returns
        -------
        int or array of int
            PFB channel index (0 to N-1)
        float or array of float
            residual frequency offset that will need to be corrected using the DDS
        float or array of float
            center frequency of the PFB channel, in MHz
        int or array of int
            "unwrapped" channel number, for phase correction
        """
        if isinstance(freq, list):
            freq = np.array(freq)
        fc = self.fc
        n = self.N
        ch, remainder = np.divmod(freq+fc/2,fc)
        return np.int64(ch+n//2)%n, remainder-fc/2, fc*ch, ch

    def ch2freq(self,ch):
        if ch >= self.N/2:
            return ch*self.fc - self.fs/2
        else:
            return ch*self.fc + self.fs/2

    def get_fs(self):
        return self.fs

    def get_fc(self):
        return self.fc

    def get_fb(self):
        return self.fb
        
    def qout(self, qout):
        self.qout_reg = qout
        
class AxisDdsCicV2(SocIp):
    bindto = ['user.org:user:axis_ddscic_v2:1.0']
    REGISTERS = {'addr_nchan_reg' : 0, 
                 'addr_pinc_reg'  : 1, 
                 'addr_we_reg'    : 2, 
                 'dds_sync_reg'   : 3, 
                 'dds_outsel_reg' : 4,
                 'cic_rst_reg'    : 5,
                 'cic_d_reg'      : 6, 
                 'qdata_qsel_reg' : 7}
    
    # Decimation range.
    MIN_D = 2
    MAX_D = 250
    
    # Quantization range.
    MIN_Q = 0
    MAX_Q = 24
    
    # Sampling frequency and frequency resolution (MHz).
    FS_DDS = 1000
    DF_DDS = 1
    
    # DDS bits.
    B_DDS = 16
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.addr_nchan_reg = 0
        self.addr_pinc_reg  = 0
        self.addr_we_reg    = 0
        self.dds_sync_reg   = 1 # Keep syncing DDS.
        self.dds_outsel_reg = 0
        self.cic_rst_reg    = 1 # Keep resetting accumulator.
        self.cic_d_reg      = 2 # Decimate-by-4.
        self.qdata_qsel_reg = 0 # Upper bits for truncation.
        
        # Generics.
        self.L = int(description['parameters']['L'])
        self.NCH = int(description['parameters']['NCH'])
        self.NCH_TOTAL = self.L * self.NCH

        # Set DDS Frequencies to 0.
        for i in range(self.NCH_TOTAL):
            self.set_ddsfreq(ch_id = i)

        # Start DDS.
        self.dds_start()
        
        # Set default decimation value
        self.decimation(2)
        
    def configure(self, fs):
        fs_hz = fs
        self.FS_DDS = fs_hz
        self.DF_DDS = self.FS_DDS/2**self.B_DDS
        
    def dds_start(self):
        self.dds_sync_reg = 0
        self.cic_rst_reg  = 0
        
    def dds_outsel(self, outsel="product"):
        self.dds_outsel_reg = {"product": 0,
                "dds": 1,
                "input":2}[outsel]
            
    def decimate(self, decimate=4):
        # Sanity check.
        if (decimate < self.MIN_D or decimate > self.MAX_D):
            raise RuntimeError("invalid decimation value")
        self.cic_d_reg = decimate
            
    def qsel(self, value=0):
        # Sanity check.
        if (value < self.MIN_Q or value > self.MAX_Q):
            raise RuntimeError("invalid Q value")
        self.qdata_qsel_reg = value
            
    def get_decimate(self):
        return self.cic_d_reg
    
    def decimation(self, value):
        # Sanity check.
        if (value < self.MIN_D or value > self.MAX_D):
            raise RuntimeError("invalid decimation value")
        # Compute CIC output quantization.
        qsel = self.MAX_Q - np.ceil(3*np.log2(value))
        
        # Set values.
        self.decimate(value)
        self.qsel(qsel)    
    
    def set_ddsfreq(self, ch_id=0, f=0):
        # Sanity check.
        if (ch_id < 0 or ch_id >= self.NCH_TOTAL):
            raise RuntimeError("invalid channel ID")
        if (f < -self.FS_DDS/2 or f >= self.FS_DDS/2):
            raise RuntimeError("invalid DDS freq")
        # Compute register value.
        #TODO: do this frequency matching correctly
        ki = int(round(f/(self.DF_DDS*2)))*2
        
        # Write value into hardware.
        self.addr_nchan_reg = ch_id
        self.addr_pinc_reg = ki
        self.addr_we_reg = 1
        self.addr_we_reg = 0                
        
class AxisChSelPfbV2(SocIp):
    # AXIS Channel Selection PFB V1 Registers
    # START_REG
    # * 0 : stop.
    # * 1 : start.
    #
    # CHID_REG
    bindto = ['user.org:user:axis_chsel_pfb_v2:1.0']
    REGISTERS = {   'start_reg' : 0, 
                    'addr_reg'  : 1,
                    'data_reg'  : 2,
                    'we_reg'    : 3}
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Generics.
        self.B      = int(description['parameters']['B'])
        self.L      = int(description['parameters']['L'])        
        self.NCH    = int(description['parameters']['NCH'])        

        # Number of transactions per frame.
        self.NT     = self.NCH//self.L

        # Numbef of memory locations (32 bits per word).
        self.NM     = self.NT//32

        # Default registers.
        self.start_reg  = 0
        self.we_reg     = 0
        
        # Mask all channels.
        self.alloff()
        
        # Start block.
        self.start()

    def alloff(self):
        # All bits to 0.
        self.data_reg = 0
        
        for i in np.arange(self.NM):
            # Address.
            self.addr_reg = i

            # WE pulse.
            self.we_reg = 1
            self.we_reg = 0
    
    def stop(self):
        self.start_reg = 0

    def start(self):
        self.start_reg = 1
        
    def set(self, ch, debug=False):
        self.alloff()
        if isinstance(ch, list):
            ch = np.array(ch)
        # Sanity check.
        if debug: print(" in  AxisChSelPfbV2.set:  ch=%s"%ch, end=" ")
        if ch.min() < 0 or ch.max() >= self.NCH:
            raise RuntimeError("invalid channel")

        # Transaction number and bit index.
        ntran, addr, bit = self.ch2tran(ch) # bit ranges from 0 to 31, there are 4096/32 channels

        # The streamer will loop through the transactions we select.
        # We need to figure out which channels are going to appear in which transactions.
        unique_ntran = sorted(set(ntran))
        tran_index = np.array([unique_ntran.index(i) for i in ntran])

        # we need to set NM 32-bit bitmasks
        datas = np.zeros(self.NM, dtype=np.uint32)
        # set all the correct bits to 1
        np.bitwise_or.at(datas, addr, (1<<bit).astype(np.uint32))
        
        # Write Value.
        for addr, data in enumerate(datas):
            self.addr_reg = addr
            self.data_reg = data
            self.we_reg = 1
            self.we_reg = 0
            if debug: print(" addr=%2d data=%08X done"%(addr, data))

        return len(unique_ntran), tran_index

    def set_single(self, ch, debug=False):
        self.set([ch], debug)
            
    def ch2tran(self,ch):
        # Transaction number.
        ntran = ch//self.L
        
        # Mask Register Address (each is 32-bit).
        addr = ntran//32

        # Bit.
        bit = ntran%32
        
        return ntran, addr, bit
    
    def ch2idx(self,ch):
        streamer_ch = ch%self.L
        unique_ch = sorted(set(streamer_ch))
        ch_index = np.array([unique_ch.index(i) for i in streamer_ch])
        return np.array(unique_ch), ch_index

class AxisStreamerV1(SocIp):
    # AXIS_Streamer V1 registers.
    # START_REG
    # * 0 : stop.
    # * 1 : start.
    #
    # NSAMP_REG : number of samples per transaction (for TLAST generation).
    #
    # MODE_REG
    # * 0 : one-shot.
    # * 1 : continuous.

    bindto = ['user.org:user:axis_streamer_v1:1.0']
    REGISTERS = {'start_reg' : 0, 'nsamp_reg' : 1, 'mode_reg' : 2}
    DTYPE = np.int16
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.start_reg = 0
        self.nsamp_reg = 0
        self.mode_reg  = 1
        
        # Generics.
        self.BDATA  = int(description['parameters']['BDATA'])
        self.BUSER  = int(description['parameters']['BUSER'])        
        self.BAXIS  = int(description['parameters']['BAXIS'])
        
        # Number of samples per AXIS transaction (buffer uses 16 bit integer).
        self.NS_TR  = int(self.BAXIS/16)
        
        # Number of data samples per transaction.
        self.NS = int(self.NS_TR/2)
        
        # Number of index samples per transaction.
        self.NI = 1
        
        # Number of useful samples per transaction.
        self.NS_NI = self.NS + self.NI

        # DMA buffer.
        self.buff = None
        
    def configure(self,axi_dma):
        self.dma = axi_dma

    def idle(self):
        return self.dma.recvchannel.idle
    
    def stop(self):
        self.start_reg = 0

    def start(self):
        self.start_reg = 1

    def set_nsamp(self, nsamp):
        # Configure parameters.
        self.nsamp_reg  = nsamp
        nbuf = nsamp*self.NS_TR
        # if we need a bigger buffer, allocate one
        # it's possible to exhaust the supply of DMA-able memory, so we only do this if necessary
        if self.buff is None or nbuf > len(self.buff):
            self.buff = allocate(shape=(nbuf,), dtype=self.DTYPE)
        
    def transfer_raw(self, nsamp, first = False):
        self.set_nsamp(nsamp)
        # DMA is always Not Idle on the first transfer.
        if first:
            # Start streamer.
            self.start()

            # DMA data.
            self.dma.recvchannel.transfer(self.buff)
            self.dma.recvchannel.wait()   

            # Stop streamer.
            self.stop()            
        
        # DMA is not Idle from second transfer on.
        else:
            if not self.idle():
                raise RuntimeError('DMA Channel must be IDLE to start new transfer')

            # Start DMA.
            self.dma.recvchannel.transfer(self.buff)

            # Wait until DMA shows idle to start transferring.
            while True:
                if not self.idle():
                    break;

            # Start streamer.
            self.start()

            # Wait until transfer is done.
            self.dma.recvchannel.wait()
            
            # Stop streamer.
            self.stop()

        return self.buff

    def transfer(self, nt, nsamp, debug=False):
        # Data structure:
        # First dimention: number of dma transfers.
        # Second dimension: number of streamer transactions.
        # Third dimension: Number of I + Number of Q + Index (17 samples, 16-bit each).

        self.set_nsamp(nsamp)

        data = np.zeros((nt,self.nsamp_reg,self.NS_NI), dtype=self.DTYPE)
        # Stash a copy of the 
        self.third = []

        for i in np.arange(nt):
            if debug:
                print('AxisStreamer: Checking DMA idle')

            # DMA must be Idle.
            if not self.idle():
                raise RuntimeError('DMA Channel must be IDLE to start new transfer')

            if debug:
                print('AxisStreamer: Starting DMA')
        
            # Start DMA.
            self.dma.recvchannel.transfer(self.buff, nbytes=int(self.nsamp_reg*self.NS_TR*2))

            # Wait until DMA shows idle to start transferring.
            while True:
                if not self.idle():
                    break;

            if debug:
                print('AxisStreamer: Starting streamer')

            # Start streamer.
            self.start()

            if debug:
                print('AxisStreamer: Waiting DMA to finish')
            
            # Wait until transfer is done.
            self.dma.recvchannel.wait()

            if debug:
                print('AxisStreamer: Stopping streamer')
            
            # Stop streamer.
            self.stop()
                
            # Data format:
            # Each streamer transaction is 512 bits. It contains 8 samples (32-bit each) plus 1 sample (16-bit) for TUSER.
            # The upper 15 samples are filled with zeros.        
            data[i,:,:] = self.buff.reshape((-1, self.NS_TR))[:self.nsamp_reg,:self.NS_NI]
            self.third.append(data[:,:,16])

        return data
    
    def get_data(self, nt=1, nsamp=10000, idx=0, debug=False):
        # nt: number of dma transfers.
        # idx: from 0..7, index of channel.

        # Format data.
        data_iq = self.get_all_data(nt=nt, nsamp=nsamp, debug=debug)
        return data_iq[:,2*idx:2*idx+2]

    def get_data_multi(self, idx, nt=1, nsamp=10000, debug=False):
        # nt: number of dma transfers.
        # idx: from 0..7, index of channel.
        #idx_arr = np.outer(2*idx, [1,1])+np.array([0,1])
        idx_arr = (np.outer(2*idx, [1,1])+np.array([0,1])).flatten()


        # Format data.
        data_iq = self.get_all_data(nt=nt, nsamp=nsamp, debug=debug)
        return np.moveaxis(data_iq[:,idx_arr].reshape(-1,len(idx),2),1,0)
    #return data_iq[:,idx_arr].T.reshape(len(idx),2,-1)

    def get_all_data(self, nt=1, nsamp=10000, debug=False):
        # nt: number of dma transfers.
        # idx: from 0..7, index of channel.

        packets = self.transfer(nt=nt, nsamp=nsamp, debug=debug)
            
        # Number of samples per transfer.
        ns = len(packets[0])
        
        # Format data.
        data_iq = packets[:,:,:16].reshape((-1,16))
        return data_iq

    async def transfer_async(self):
        # DMA data.
        self.dma.recvchannel.transfer(self.buff)
        await self.dma.recvchannel.wait_async()

        # Format data.
        data = self.buff & 0xFFFFF;
        indx = (self.buff >> 24) & 0xFF;

        return [indx,data]

class AxisDdsV3(SocIp):
    bindto = ['user.org:user:axis_dds_v3:1.0']
    REGISTERS = {'addr_nchan_reg' : 0, 
                 'addr_pinc_reg'  : 1, 
                 'addr_phase_reg' : 2,
                 'addr_gain_reg'  : 3,
                 'addr_cfg_reg'   : 4,
                 'addr_we_reg'    : 5,                  
                 'dds_sync_reg'   : 6}
    
    # Sampling frequency and frequency resolution (Hz).
    FS_DDS      = 1000
    DF_DDS      = 1
    DFI_DDS     = 1
    
    # DDS bits.
    B_DDS       = 16

    # Gain.
    B_GAIN      = 16
    MIN_GAIN    = -1
    MAX_GAIN    = 1

    # Phase.
    MIN_PHI     = 0
    MAX_PHI     = 360

    # Mixer frequency (MHz).
    FMIX        = 1000

    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.addr_nchan_reg = 0;
        self.addr_pinc_reg  = 0;
        self.addr_phase_reg = 0;
        self.addr_gain_reg  = 0;
        self.addr_cfg_reg   = 0; # DDS output.
        self.addr_we_reg    = 0;
        self.dds_sync_reg   = 1; # Sync DDS.

        # Generics
        self.L      = int(description['parameters']['L'])
        self.NCH    = int(description['parameters']['NCH'])
        self.NCH_TOTAL = self.L * self.NCH

        # Initialize DDSs.
        for i in range(self.NCH_TOTAL):
            self.ddscfg(ch = i)

        # Start DDS.
        self.start()
        
    def configure(self, fs_dds):
        # Frequency constants.
        self.FS_DDS     = fs_dds
        self.DF_DDS     = self.FS_DDS/2**self.B_DDS
        self.DFI_DDS    = self.MAX_PHI/2**self.B_DDS

    def start(self):
        self.dds_sync_reg   = 0

    def ddscfg(self, f=0, fi=0, g=0, ch=0, sel="dds"):
        """Configure DDS output.

        Parameters
        ----------
        f : float
            DDS frequency in MHz
        fi : float
            DDS phase in degrees, range 0 to 360
        g : float
            DDS gain, range -1 to 1
        ch : int
            PFB channel
        sel : str
            "dds" or "noise"

        Returns
        -------
        float
            frequency step common to the two channels

        """
        # Sanity check.
        if (ch < 0 or ch >= self.NCH_TOTAL):
            raise ValueError('ch=%d not contained in [%d,%d)'%(ch,0,self.NCH_TOTAL))
        if (f < -self.FS_DDS/2 or f >= self.FS_DDS/2):
            raise ValueError('frequency=%f not contained in [%f,%f)'%(f,-self.FS_DDS/2,self.FS_DDS/2))
        if (fi < self.MIN_PHI or fi >= self.MAX_PHI): 
            raise ValueError('phase=%f not contained in [%f,%f)'%(fi,self.MIN_PHI,self.MAX_PHI))
        if (g < self.MIN_GAIN or g >= self.MAX_GAIN):
            raise ValueError('gain=%f not contained in [%f,%f)'%(g,self.MIN_GAIN,self.MAX_GAIN))

        #if f != 0:
        #    print("in AxisDdsV3.ddscfg:  ch,f,fi,g=",ch,f,fi,g)

        # Compute pinc value.
        ki = int(round(f/self.DF_DDS))

        # Compute phase value.
        fik = int(round(fi/self.DFI_DDS))

        # Compute gain.
        gi  = int(round(g*(2**(self.B_GAIN-1))))

        # Output selection.
        if sel == "noise":
            self.addr_cfg_reg = 1
        else:
            self.addr_cfg_reg = 0

        # Write values to hardware.
        self.addr_nchan_reg = ch
        self.addr_pinc_reg  = ki
        self.addr_phase_reg = fik
        self.addr_gain_reg  = gi
        self.addr_we_reg    = 1
        self.addr_we_reg    = 0
            
    def alloff(self):
        self.ddscfg(g=0, ch=0)
        # now we can write those values to all channels
        for ch in np.arange(self.NCH_TOTAL):
            self.addr_nchan_reg = ch
            self.addr_we_reg    = 1
            self.addr_we_reg    = 0

class AxisPfbSynth4x512V1(SocIp):
    # This is the output PFB
    bindto = ['user.org:user:axis_pfbsynth_4x512_v1:1.0']
    REGISTERS = {'qout_reg':0}
    
    # Number of channels.
    N = 512

    # Mixer frequency (MHz).
    FMIX = 1000
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.qout_reg   = 0

    def configure(self, fs,  mixer, dacname):
        # Sampling frequency at output of the PFB before DAC and its decimation
        self.fs = fs

        # Difference between channel centers.
        self.fc = fs/self.N

        # Channel bandwidth.
        self.fb = fs/(self.N/2)

        # Mixer.
        self.mixer = mixer
        self.dacname = dacname

    def get_fs(self):
        return self.fs

    def get_fc(self):
        return self.fc

    def get_fb(self):
        return self.fb

    def qout(self, value):
        self.qout_reg = value

    def freq2ch(self, freq, fmix):
        """Compute the correct output PFB channel for a desired frequency.

        Parameters
        ----------
        f : float or array of float
            desired frequency, in MHz

        Returns
        -------
        int or array of int
            PFB channel index (0 to N-1)
        float or array of float
            residual frequency offset that will need to be corrected using the DDS
        float or array of float
            center frequency of the PFB channel, in MHz
        int or array of int
            "unwrapped" channel number, for phase correction
        """
        if isinstance(freq, list):
            freq = np.array(freq)
        fc = self.fc
        minf = fmix - self.fs/2 - fc/2
        maxf = fmix + self.fs/2 - fc/2
        if np.min(freq) < minf or np.max(freq) > maxf:
            raise ValueError('output PFB: frequency should be within [%f,%f] MHz'%(minf, maxf))
        ch, remainder = np.divmod(freq-fmix+fc/2,fc)
        return np.int64(ch)%self.N, remainder-fc/2, fc*ch, ch

    def ch2freq(self, ch):
        """
        freq = ch*fc for N<N/2
        else, freq = (ch-N)*fc
        """
        ##
        ##folded_N = ((ch + self.N//2) % self.N) - self.N//2
        ##freq = folded_N*self.fc
        ##return freq
        ##
        freq = ch*self.fc
        if isinstance(ch, np.ndarray):
            freq[ch >= self.N/2] -= self.fs
        elif ch >= self.N/2:
            freq -= self.fs
        return freq
    
    
    
    def set_fmix(self,f):
        df = self.fb/2**16
        f = (round(f/df))*df
        self.mixer.set_mixer_freq(dacname=self.dacname, f=f)
        self.FMIX = f

    def get_fmix(self):
        return self.FMIX
    
class TopSoc(QickSoc):
    # Constructor.
    def __init__(self, bitfile=None,
                 decimation=2, switchSrc="pfbcic", 
                 streamLength=10000, **kwargs):
        
        self.board = os.environ["BOARD"]
        if self.board == 'ZCU111':
            bitFileName = str(Path(Path(__file__).parent.parent,"mkids_111_4x4096","mkids_4x4096_v4.bit"))
            self.adcChannel = '00'
            self.dacChannel = '12'

            #bitfile = "../mkids_216_4x1024/mkids_4x1024.bit"
        elif self.board == 'ZCU216':
            temp = str(Path(Path(__file__).parent.parent,"mkids_216_4x1024"))
            bitFileName = temp+'/mkids_4x1024.bit'
            self.adcChannel = '20'
            self.dacChannel = '20'

        super().__init__(bitFileName, no_tproc=True, **kwargs)
     
        if self.board == 'ZCU111':
            self.pfb_in = self.axis_pfb_4x4096_v1_0        
        elif self.board == 'ZCU216':
            self.pfb_in = self.axis_pfb_4x1024_v1_0        

        # Mixer.
        self.mixer = self.usp_rf_data_converter_0
        self.mixer.configure(self)

        # RF data converter (for configuring ADCs and DACs)
        self.rf = self.usp_rf_data_converter_0
        
        #################
        ### ADC Chain ###
        #################
        # PFB for Analysis.
        self.pfb_in.configure(self.adcs[self.adcChannel]['fs']/2)
        
        # DDS + CIC block.
        self.ddscic = self.axis_ddscic_v2_0
        self.ddscic.configure(self.pfb_in.get_fb())

        # Channel selection.
        self.chsel = self.axis_chsel_pfb_v2_0

        # Streamer.
        self.stream = self.axis_streamer_v1_0
        self.stream.configure(self.axi_dma_0)
        
        #################
        ### DAC Chain ###
        #################
        # PFB with 512 Channels for Synthesis.
        self.pfb_out = self.axis_pfbsynth_4x512_0
        self.pfb_out.configure(self.dacs[self.dacChannel]['fs']/4, self.mixer, self.dacChannel)
        
        # DDS with 512 Channels for Synthesis.
        self.dds_out = self.axis_dds_v3_0
        self.dds_out.configure(self.pfb_out.get_fb())
        
        # First Dummy transfer for DMA.
        self.chsel.set_single(0)
        self.stream.transfer_raw(nsamp=10000, first=True)
        self.chsel.alloff()

        ####################
        ### Calibrations ###
        ####################
        # output gain vs. DDS offset
        # normalize to the minimum gain in the working band (which is +/- fb/2)
        # we're going to divide the output gain by this function, so we want the function to be always >=1
        # (otherwise we might exceed the output range)
        try:
            output_freqs, output_gains = np.load("output_gain.npy")
            mingain = output_gains[:(len(output_gains)+1)//2].min()
            self.output_gain = interp1d(output_freqs, output_gains/mingain)
        except FileNotFoundError:
            self.output_gain = None
            
        # output polarity vs. PFB channel
        try:
            self.output_signs = np.load("output_sign.npy")
        except FileNotFoundError:
            self.output_signs = None
            
        # input gain vs. DDS offset
        try:
            self.input_gain = interp1d(*np.load("input_gain.npy"))
        except FileNotFoundError:
            self.input_gain = None
            
        self.PHASE_STEP_OUTPUT = -1.82216429
        self.PHASE_STEP_INPUT = 0.0524290536
        #self.PHASE_SLOPE = -4.41828551
        self.PHASE_SLOPE = -4.5

        # eed the max of input and output
        self.DF = max(self.dds_out.DF_DDS,self.ddscic.DF_DDS)

        # Useful constants
        self.nInCh = self.pfb_in.N
        self.fsIn = self.adcs[self.adcChannel]['fs']
        self.fbIn = self.pfb_in.get_fb()
        self.fcIn = self.pfb_in.get_fc()

        self.nOutCh = self.pfb_out.N
        self.fsOut = self.pfb_out.fs
        self.fbOut = self.pfb_out.get_fb()
        self.fcOut = self.pfb_out.get_fc()


    def round_freq(self, f): # in MHz
        return np.round(f/self.DF)*self.DF

    def set_mixer(self, fmix): # fmix in MHz
        # Set mixer frequency.
        self.pfb_out.set_fmix(fmix)
        return self.pfb_out.get_fmix()
    
    def get_mixer(self):
        return self.pfb_out.get_fmix()

    def set_outputs(self, freqs, gains, equalize=True): 
        # freqs in MHz, gain 1 for full range, fi in radians
        # try to convert to float; if that fails, assume it's a list of floats
        try:
            gain_list = [float(gains)]*len(freqs)
        except TypeError:
            gain_list = gains
        assert len(freqs)==len(gain_list)
        
        # All channels off.
        self.dds_out.alloff()
        pfb_chs, dds_freqs, _, unwrapped_chs = self.pfb_out.freq2ch(freqs, self.pfb_out.get_fmix())
        if len(set(pfb_chs)) != len(pfb_chs):
            raise RuntimeError("Output tones map to PFB channels %s, which are not unique"%(str(pfb_chs)))
        
        for ch, fdds, gain, unwrapped_ch in zip(pfb_chs, dds_freqs, gain_list, unwrapped_chs):
            if equalize:
                equalized_gain = gain * self.output_signs[ch] / self.output_gain(np.abs(fdds)/(self.dds_out.FS_DDS))
                phase = np.rad2deg(-self.PHASE_STEP_OUTPUT*unwrapped_ch)%360
            else:
                equalized_gain = gain
                phase = 0
            self.dds_out.ddscfg(ch=ch, f=fdds, g=equalized_gain, fi=phase)
            
        # Set the PFB quantization, which sets the PFB dynamic range.
        # 0 gives you max output power, larger values give you finer control
        self.pfb_out.qout(0)

    def set_inputs(self, freqs, decimation, downconvert, equalize=True):
        if isinstance(freqs, list):
            freqs = np.array(freqs)
        nfreqs = len(freqs)

        # before we do anything, calculate channel mappings and check for collisions
        K, dds_freq, pfb_freq, ch = self.pfb_in.freq2ch(freqs)
        if len(set(K)) < nfreqs:
            raise RuntimeError("input PFB channels are not unique: %s"%(K))

        streams, stream_idx = self.chsel.ch2idx(K)
        #if len(set(streamer_ch)) < nfreqs:
        #    raise RuntimeError("streamer channels are not unique: %s"%(streamer_ch))
        
        # Set the PFB quantization, which sets the PFB dynamic range.
        # this sets how many of the least significant bits are truncated, or something like that
        # larger values mean a given power will get converted to a smaller number of arbitrary units
        # the appropriate value depends on the signal strength
        # if you make this too small, your signal may overflow the range and you will see weird stuff:
        #     periodic sawtooth-y waveforms in the IQ data, lots of spurious spikes in the frequency spectrum
        # if you make this too big, your signal-to-noise ratio suffers (eventually your IQ values are all zero)
        # Values >=12 seem to be equivalent to 0
        self.pfb_in.qout(7)
        
        # Set decimation value.
        # This also automatically sets the CIC quantization.
        self.ddscic.decimation(value=decimation)

        # Channel's sampling frequency = bandwidth/decimation
        fs = self.pfb_in.get_fb()/self.ddscic.get_decimate()

        if downconvert:
            # Use DDS.
            self.ddscic.dds_outsel(outsel="product")
            # Set DDS frequency.
            for i in range(nfreqs):
                self.ddscic.set_ddsfreq(ch_id=K[i], f=dds_freq[i])
            # need to correct by 1.0 if in "product" mode?
            offset = np.full_like(K, 1.0)
            fcenter = pfb_freq+dds_freq
        else:
            # By-pass DDS product.
            self.ddscic.dds_outsel(outsel="input")
            # need to correct offset, which depends on channel
            #offset = 1.0 if K%2==0 else 0.5
            offset = 1.0 - 0.5*(K%2)
            fcenter = pfb_freq

        # Un-mask channels.
        num_tran, tran_idx = self.chsel.set(K)

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
        if equalize:
            gain = self.input_gain(np.abs(dds_freq/self.pfb_in.fb))
        else:
            gain = 1
        phase = (self.PHASE_SLOPE*freqs + self.PHASE_STEP_INPUT*ch)
        self.input_config['correction'] = np.exp(-1j*phase)/gain

    def measure(self, freqs, gain, decimation=2, downconvert=True, truncate=200, equalize=True, average=True):
        self.set_outputs(freqs, gain, equalize=equalize)
        self.set_inputs(freqs, decimation, downconvert, equalize=equalize)
        return self.read(truncate=truncate, equalize=equalize, average=average)

    def read(self, truncate=200, equalize=True, average=True, nt=1, nsamp=10000):
        # nsamp * number of PFB channels * decimation / ADC sampling freq
        # example: 1e4*1024*250/2457.6e6 = ~1 sec
        num_tran = self.input_config['num_tran']
        tran_idx = self.input_config['tran_idx']
        streams = self.input_config['streams']
        stream_idx = self.input_config['stream_idx']
        offset = self.input_config['offset']
        correction = self.input_config['correction']

        # Transfer data.
        x_buf = self.stream.get_data_multi(idx=streams, nt=nt, nsamp=nsamp*num_tran)[:,truncate*num_tran:]
        x_buf = x_buf.reshape(len(streams), -1, num_tran, 2)[stream_idx, :, tran_idx, :]
        if average:
            results = x_buf.mean(axis=1)
            results += offset[:, np.newaxis]
            results_complex = results.dot([1, 1j])
            if equalize:
                results_complex *= correction
            return results_complex
        else:
            return x_buf + offset[:, np.newaxis, np.newaxis]

    def calib_phase(self, freqs, results_complex, dry_run=False):
        """Adjust the phase calibration using data from a frequency sweep.

        Parameters
        ----------
        freqs : array of float
            frequencies, in MHz
        results_complex : array of complex float
            IQ values
        """
        a = np.vstack([freqs, np.ones_like(freqs)]).T
        phase_correction = np.linalg.lstsq(a, np.unwrap(np.angle(results_complex)), rcond=None)[0][0]
        print("adjusting phase slope by %.4f rad/MHz"%(phase_correction))
        if dry_run:
            print("dry run, keeping value of %.4f rad/MHz"%(self.PHASE_SLOPE))
        else:
            self.PHASE_SLOPE += phase_correction
            print("old value %.4f rad/MHz, new value %.4f rad/MHz"%(self.PHASE_SLOPE, self.PHASE_SLOPE+phase_correction))

    def info(self, stream=sys.stdout):
        print("Board model: %s"%self.board, file=stream)
        print("Input:", file=stream)
        print("         number of input channels: %7d"%self.nInCh)
        print("         input sampling frequency: %7.2f MHz"%self.fsIn)
        print("             input DDS resolution: %7.4f Hz"%(1e6*self.ddscic.DF_DDS))
        print("  bandwidth of each input channel: %7.2f MHz"%self.fbIn)
        print("   spacing between input channels: %7.2f MHz"%self.fcIn)
        print("            total input bandwidth: %7.2f MHz"%(self.nInCh*self.fcIn))
        print("Output:", file=stream)
        print("        number of output channels: %7d"%self.nOutCh)
        print("        output sampling frequency: %7.2f MHz"%self.fsOut)
        print("            output DDS resolution: %7.4f Hz"%(1e6*self.dds_out.DF_DDS))
        print(" bandwidth of each output channel: %7.2f MHz"%self.fbOut)
        print("  spacing between output channels: %7.2f MHz"%self.fcOut)
        print("           total output bandwidth: %7.2f MHz"%(self.nOutCh*self.fcOut))

        print("")
        print("             frequency resolution: %7.4f Hz"%(1e6*self.DF))
        print("      output/input DDS resolution: %f"%(self.dds_out.DF_DDS/self.ddscic.DF_DDS))

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
        f = frequency# - self.get_mixer()
        ch = self.pfb_out.freq2ch(f, self.get_mixer())[0]
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

        f = frequency  #- self.get_mixer()
        ch = self.pfb_out.freq2ch(f, self.get_mixer())[0]
        fOutCenters = self.outCh2FreqCenter(ch)
        offsets = f - fOutCenters  #+ self.get_mixer()
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
        frequency = f + self.get_mixer()
        return frequency

