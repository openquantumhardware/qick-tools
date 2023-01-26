from pynq import Overlay, allocate
import xrfdc
import xrfclk
from qick.qick import SocIp
import matplotlib.pyplot as plt
import time
import os
import numpy as np

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

    def freq2ch(self,f):
        k = np.round(f/self.fc)

        return int(np.mod(k+self.N/2,self.N))

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
    DF_DDS_MHZ = 1
    
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
        self.DF_DDS_MHZ = self.FS_DDS/2**self.B_DDS
        
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
        ki = int(round(f/(self.DF_DDS_MHZ*2)))*2
        
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
        # Sanity check.
        if debug: print(" in  AxisChSelPfbV2.set:  ch=%d"%ch, end=" ")
        if ch < 0 or ch >= self.NCH:
            raise RuntimeError("invalid channel")
        # Transaction number and bit index.
        [addr,bit] = self.ch2tran(ch) # bit ranges from 0 to 31, there are 4096/32 channels
        
        # Data Mask.
        data = 2**bit
        
        # Write Value.
        self.addr_reg = addr
        self.data_reg = data
        self.we_reg = 1
        self.we_reg = 0
        if debug: print(" addr=%2d data=%08X   bit=%2d  done"%(addr, data, bit))

    def set_single(self, ch, debug=False):
        self.alloff()
        self.set(ch, debug)
            
    def ch2tran(self,ch):
        # Transaction number.
        ntran = int(np.floor(ch/self.L))
        
        # Mask Register Address (each is 32-bit).
        addr = int(np.floor(ntran/32))

        # Bit.
        bit = np.mod(ntran,32)
        
        return [addr,bit]
    
    def ch2idx(self,ch):
        return np.mod(ch, self.L)

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
    DF_DDS_MHZ      = 1
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
        self.DF_DDS_MHZ     = self.FS_DDS/2**self.B_DDS
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
        ki = int(round(f/self.DF_DDS_MHZ))

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
        for ch in np.arange(self.NCH_TOTAL):
            self.ddscfg(g=0, ch=ch)            

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

    def freqAbsolute2ch(self, f):
        # f is the absolute desired frequency (taking into consideration fmix).
        
        # Sanity check.
        if (f < self.FMIX - self.fs/2) or f > (self.FMIX + self.fs/2):
            raise ValueError('{%s}: frequency should be within [%f,%f] MHz'%(self.__class__.__name__,self.FMIX - self.fs/2,self.FMIX + self.fs/2))
        f_ = f - self.FMIX
        k = np.round(f_/self.fc)

        # mod will always return a non-negative result if N is positive
        ch = int(np.mod(k,self.N))

        return ch
    
    def freq2ch(self, f):
        # f is the tone seen by the PFB, from -fs/2 to fs/2, usually fTone-fMixer
        k = np.round(f/self.fc)
        #ch = int(np.mod(k,self.N))
        ch = np.mod(k,self.N)
        if isinstance(ch, np.ndarray):
            ch = ch.astype(int)
        else:
            ch = int(ch)       
        return ch
        
    def ch2freq(self, ch):
        """
        freq = ch*fc for N<N/2
        else, freq = (ch-N)*fc
        """
        folded_N = ((ch + self.N//2) % self.N) - self.N//2
        freq = folded_N*self.fc
        return freq

    def set_fmix(self,f):
        df = self.fb/2**16
        f = (round(f/df))*df
        self.mixer.set_mixer_freq(dacname=self.dacname, f=f)
        self.FMIX = f

    def get_fmix(self):
        return self.FMIX
    
class TopSoc(Overlay):    
    # Constructor.
    def __init__(self, bitfile=None, force_init_clks=False,
                 ignore_version=True,  decimation=2, switchSrc="pfbcic", 
                 streamLength=10000, **kwargs):
        # Load overlay (don't download to PL).
        Overlay.__init__(self, bitfile, ignore_version=ignore_version, download=False, **kwargs)
        
        # Configuration dictionary.
        self.cfg = {}
        self.cfg['board'] = os.environ["BOARD"]
        self.cfg['refclk_freq'] = 245.76

        # Read the config to get a list of enabled ADCs and DACs, and the sampling frequencies.
        self.list_rf_blocks(self.ip_dict['usp_rf_data_converter_0']['parameters'])
        
        # Configure PLLs if requested, or if any ADC/DAC is not locked.
        if force_init_clks:
            self.set_all_clks()
            self.download()
        else:
            self.download()        

        # Mixer.
        self.mixer = self.usp_rf_data_converter_0
        self.mixer.configure(self)

        # RF data converter (for configuring ADCs and DACs)
        self.rf = self.usp_rf_data_converter_0
        
        #################
        ### ADC Chain ###
        #################
        # PFB for Analysis.
        self.pfb_in = self.axis_pfb_4x1024_v1_0        
        self.pfb_in.configure(self.adcs['20']['fs']/2)
        
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
        self.pfb_out.configure(self.dacs['20']['fs']/4, self.mixer, '20')
        
        # DDS with 512 Channels for Synthesis.
        self.dds_out = self.axis_dds_v3_0
        self.dds_out.configure(self.pfb_out.get_fb())
        
        # First Dummy transfer for DMA.
        self.chsel.set_single(0)
        self.stream.transfer_raw(nsamp=10000, first=True)
        self.chsel.alloff()

    def list_rf_blocks(self, rf_config):
        """
        Lists the enabled ADCs and DACs and get the sampling frequencies.
        XRFdc_CheckBlockEnabled in xrfdc_ap.c is not accessible from the Python interface to the XRFdc driver.
        This re-implements that functionality.
        """

        hs_adc = rf_config['C_High_Speed_ADC']=='1'

        self.dac_tiles = []
        self.adc_tiles = []
        dac_fabric_freqs = []
        adc_fabric_freqs = []
        refclk_freqs = []
        self.dacs = {}
        self.adcs = {}

        for iTile in range(4):
            if rf_config['C_DAC%d_Enable'%(iTile)]!='1':
                continue
            self.dac_tiles.append(iTile)
            f_fabric = float(rf_config['C_DAC%d_Fabric_Freq'%(iTile)])
            f_refclk = float(rf_config['C_DAC%d_Refclk_Freq'%(iTile)])
            dac_fabric_freqs.append(f_fabric)
            refclk_freqs.append(f_refclk)
            fs = float(rf_config['C_DAC%d_Sampling_Rate'%(iTile)])*1000
            for iBlock in range(4):
                if rf_config['C_DAC_Slice%d%d_Enable'%(iTile,iBlock)]!='true':
                    continue
                self.dacs["%d%d"%(iTile,iBlock)] = {'fs':fs,
                                                    'f_fabric':f_fabric,
                                                    'tile':iTile,
                                                    'block':iBlock}

        for iTile in range(4):
            if rf_config['C_ADC%d_Enable'%(iTile)]!='1':
                continue
            self.adc_tiles.append(iTile)
            f_fabric = float(rf_config['C_ADC%d_Fabric_Freq'%(iTile)])
            f_refclk = float(rf_config['C_ADC%d_Refclk_Freq'%(iTile)])
            adc_fabric_freqs.append(f_fabric)
            refclk_freqs.append(f_refclk)
            fs = float(rf_config['C_ADC%d_Sampling_Rate'%(iTile)])*1000
            #for iBlock,block in enumerate(tile.blocks):
            for iBlock in range(4):
                if hs_adc:
                    if iBlock>=2 or rf_config['C_ADC_Slice%d%d_Enable'%(iTile,2*iBlock)]!='true':
                        continue
                else:
                    if rf_config['C_ADC_Slice%d%d_Enable'%(iTile,iBlock)]!='true':
                        continue
                self.adcs["%d%d"%(iTile,iBlock)] = {'fs':fs,
                                                    'f_fabric':f_fabric,
                                                    'tile':iTile,
                                                    'block':iBlock}

    def set_all_clks(self):
        """
        Resets all the board clocks
        """
        if self.cfg['board']=='ZCU111':
            print("resetting clocks:",self.cfg['refclk_freq'])
            xrfclk.set_all_ref_clks(self.cfg['refclk_freq'])
        elif self.cfg['board']=='ZCU216':
            lmk_freq = self.cfg['refclk_freq']
            lmx_freq = self.cfg['refclk_freq']*2
            print("resetting clocks:",lmk_freq, lmx_freq)
            xrfclk.set_ref_clks(lmk_freq=lmk_freq, lmx_freq=lmx_freq)

