"""
"""
from qick.qick import *
import matplotlib.pyplot as plt
import copy, time
from collections import OrderedDict
from scipy.optimize import minimize
from numpy.polynomial.polynomial import Polynomial
from tqdm.notebook import trange, tqdm
from scipy.stats import sigmaclip
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
    
    # Sampling frequency and frequency resolution (Hz).
    FS_DDS_HZ = 1000
    FS_DDS_MHZ = 1/1000
    DF_DDS_HZ = 1
    DF_DDS_MHZ = 1/1000/1000
    
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
        self.cic_d_reg      = 4 # Decimate-by-4.
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
        
    def configure(self, fsMHz):
        fs_hz = fsMHz*1000*1000
        self.FS_DDS_HZ = fs_hz
        self.FS_DDS_MHZ = fsMHz
        self.DF_DDS_HZ = self.FS_DDS_HZ/2**self.B_DDS
        self.DF_DDS_MHZ = self.DF_DDS_HZ/1000/1000
        
    def dds_start(self):
        self.dds_sync_reg = 0
        self.cic_rst_reg  = 0
        
    def dds_outsel(self, outsel="product"):
        if outsel == "product":
            self.dds_outsel_reg = 0
        elif outsel == "dds":
            self.dds_outsel_reg = 1
        elif outsel == "input":
            self.dds_outsel_reg = 2
            
    def decimate(self, decimate=4):
        # Sanity check.
        if (decimate >= self.MIN_D and decimate <= self.MAX_D):
            self.cic_d_reg = decimate
            
    def qsel(self, value=0):
        # Sanity check.
        if (value >= self.MIN_Q and value <= self.MAX_Q):
            self.qdata_qsel_reg = value
            
    def get_decimate(self):
        return self.cic_d_reg
    
    def decimation(self, value):
        # Sanity check.
        if (value >= self.MIN_D and value <= self.MAX_D):
            # Compute CIC output quantization.
            qsel = self.MAX_Q - np.ceil(3*np.log2(value))
            
            # Set values.
            self.decimate(value)
            self.qsel(qsel)    
    
    def set_ddsfreq(self, ch_id=0, fMhz=0):
        # Sanity check.
        if (ch_id >= 0 and ch_id < self.NCH_TOTAL):
            if (fMhz >= -self.FS_DDS_MHZ/2 and fMhz < self.FS_DDS_MHZ/2):
            #if (f >= 0 and f < self.FS_DDS):
                # Compute register value.
                ki = int(round(fMhz/self.DF_DDS_MHZ))
                
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
        self.NT     = self.NCH/self.L

        # Numbef of memory locations (32 bits per word).
        self.NM     = self.NT/32

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
        if ch < self.NCH:
            # Transaction number and bit index.
            [ntran,bit] = self.ch2tran(ch) # bit ranges from 0 to 31, there are 4096/32 channels
            
            # Mask Register Address (each is 32-bit).
            addr = int(np.floor(ntran/32))
            
            # Data Mask.
            data = 2**bit
            
            # Write Value.
            self.addr_reg = addr
            self.data_reg = data
            self.we_reg = 1
            self.we_reg = 0
            if debug: print(" addr=%2d data=%08X   bit=%2d  done"%(addr, data, bit))
        else:
            if debug: print(" NOT SET")
    def set_single(self,ch):
        self.alloff()
        self.set(ch)
            
    def ch2tran(self,ch):
        # Transaction number.
        ntran = int(np.floor(ch/self.L))
        
        # Bit.
        bit = np.mod(ntran,32)
        
        return [ntran,bit]
    
    def ch2idx(self,ch):
        return np.mod(ch,8)

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
        
        # Placeholder buffer to hold data transfers
        self.buff = None
        
    def configure(self,axi_dma, oneShot=True):
        if oneShot:
            self.mode_reg  = 0  # one-shot.
        else:
            self.mode_reg  = 1  # continuous.
        self.dma = axi_dma

    def idle(self):
        return self.dma.recvchannel.idle
    
    def stop(self):
        self.start_reg = 0

    def start(self):
        self.start_reg = 1

    #def set(self, nsamp=100):
    #    # Configure parameters.
    #    self.nsamp_reg  = nsamp
    #    nbuf = nsamp*self.NS_TR
    #    self.buff = allocate(shape=(nbuf,), dtype=np.int16)

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

    def transfer(self, nt=1):
        # Data structure:
        # First dimention: number of dma transfers.
        # Second dimension: number of streamer transactions.
        # Third dimension: Number of I + Number of Q + Index (17 samples, 16-bit each).
        data = np.zeros((nt,self.nsamp_reg,self.NS_NI))
        # Stash a copy of the 
        self.third = []

        for i in np.arange(nt):
            # DMA must be Idle.
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
                
            # Data format:
            # Each streamer transaction is 512 bits. It contains 8 samples (32-bit each) plus 1 sample (16-bit) for TUSER.
            # The upper 15 samples are filled with zeros.        
            data[i,:,:] = self.buff.reshape((self.nsamp_reg, -1))[:,:self.NS_NI]
            self.third.append(data[:,:,16])
        return data
    
    def get_data(self,nt=1,idx=0):
        # nt: number of dma transfers.
        # idx: from 0..7, index of channel.

        packets = self.transfer(nt=nt)
            
        # Number of samples per transfer.
        ns = len(packets[0])
        
        # Format data.
        data_iq = packets[:,:,:16].reshape((-1,16)).T
        xi,xq = data_iq[2*idx:2*idx+2]        
                
        return [xi,xq]

    async def transfer_async(self):
        # DMA data.
        self.dma.recvchannel.transfer(self.buff)
        await self.dma.recvchannel.wait_async()

        # Format data.
        data = self.buff & 0xFFFFF;
        indx = (self.buff >> 24) & 0xFF;

        return [indx,data]

class AxisDdsV2(SocIp):
    bindto = ['user.org:user:axis_dds_v2:1.0']
    REGISTERS = {'addr_nchan_reg' : 0, 
                 'addr_pinc_reg'  : 1, 
                 'addr_phase_reg' : 2,
                 'addr_gain_reg'  : 3,
                 'addr_cfg_reg'   : 4,
                 'addr_we_reg'    : 5,                  
                 'dds_sync_reg'   : 6}
    
    # Sampling frequency and frequency resolution (Hz).
    FS_DDS      = 1000
    DF_DDS_HZ      = 1
    DF_DDS_MHZ     = 1/1000/1000
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
        
    def configure(self, fsMhz):
        fs_hz = fs*1000*1000
        self.FS_DDS_HZ     = fs_hz
        self.FS_DDS_MHZ    = fsMhz
        self.DF_DDS_HZ     = self.FS_DDS_HZ/2**self.B_DDS
        self.DF_DDS_MHZ     = self.FS_DDS_MHZ/2**self.B_DDS
        self.DFI_DDS    = self.MAX_PHI/2**self.B_DDS

    def start(self):
        self.dds_sync_reg   = 0

    def ddscfg(self, f=0, fi=0, g=0, ch=0, sel="dds"):
        # Sanity check.
        if (ch >= 0 and ch < self.NCH_TOTAL):
            if (f >= -self.FS_DDS/2 and f < self.FS_DDS/2):
                if (fi >= self.MIN_PHI and fi < self.MAX_PHI): 
                    if (g >= self.MIN_GAIN and g < self.MAX_GAIN):
                        # Compute pinc value.
                        ki = int(round(f/self.DF_DDS))

                        # Compute phase value.
                        fik = int(round(fi/self.DFI_DDS))

                        # Compute gain.
                        gi  = g*(2**(self.B_GAIN-1))

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
                    else:
                        raise ValueError('gain=%f not contained in [%f,%f)'%(g,self.MIN_GAIN,self.MAX_GAIN))
                else:
                    raise ValueError('phase=%f not contained in [%f,%f)'%(fi,self.MIN_PHI,self.MAX_PHI))
            else:
                raise ValueError('frequency=%f not contained in [%f,%f)'%(f,0,self.FS_DDS))
        else:
            raise ValueError('ch=%d not contained in [%d,%d)'%(ch,0,self.NCH_TOTAL))
            
    def alloff(self):
        for ch in np.arange(self.NCH_TOTAL):
            self.ddscfg(g=0, ch=ch)            
            
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
    FS_DDS_HZ      = 1000
    FS_DDS_MHZ     = 1/1000
    DF_DDS_HZ      = 1
    DF_DDS_MHZ = DF_DDS_HZ
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
        
    def configure(self, fsMhz):
        fs_hz = fsMhz*1000*1000
        self.FS_DDS_HZ     = fs_hz
        self.FS_DDS_MHZ    = fsMhz
        self.DF_DDS_HZ     = self.FS_DDS_HZ/2**self.B_DDS
        self.DF_DDS_MHZ     = self.FS_DDS_MHZ/2**self.B_DDS
        self.DFI_DDS    = self.MAX_PHI/2**self.B_DDS

    def start(self):
        self.dds_sync_reg   = 0

    def ddscfg(self, f=0, fi=0, g=0, ch=0, sel="dds"):
        # Sanity check.
        if (ch >= 0 and ch < self.NCH_TOTAL):
            if (f >= -self.FS_DDS_MHZ/2 and f < self.FS_DDS_MHZ/2):
                if (fi >= self.MIN_PHI and fi < self.MAX_PHI): 
                    if (g >= self.MIN_GAIN and g < self.MAX_GAIN):
                        #if f != 0:
                        #    print("in AxisDdsV3.ddscfg:  ch,f,fi,g=",ch,f,fi,g)

                        # Compute pinc value.
                        ki = int(round(f/self.DF_DDS_MHZ))

                        # Compute phase value.
                        fik = int(round(fi/self.DFI_DDS))

                        # Compute gain.
                        gi  = g*(2**(self.B_GAIN-1))

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
                    else:
                        raise ValueError('gain=%f not contained in [%f,%f)'%(g,self.MIN_GAIN,self.MAX_GAIN))
                else:
                    raise ValueError('phase=%f not contained in [%f,%f)'%(fi,self.MIN_PHI,self.MAX_PHI))
            else:
                raise ValueError('frequency=%f not contained in [%f,%f)'%(f,0,self.FS_DDS_MHZ))
        else:
            raise ValueError('ch=%d not contained in [%d,%d)'%(ch,0,self.NCH_TOTAL))
            
    def alloff(self):
        for ch in np.arange(self.NCH_TOTAL):
            self.ddscfg(g=0, ch=ch)            

class AxisPfbSynth4x512V1(SocIp):
    # This is the output PFB
    bindto = ['user.org:user:axis_pfbsynth_4x512_v1:1.0']
    REGISTERS = {'qout_reg':0}
    
    # Number of channels.
    N = 512
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.qout_reg   = 0

    def configure(self, fs):
        # Sampling frequency at output of the PFB before DAC and its decimation
        self.fs = fs

        # Difference between channel centers.
        self.fc = fs/self.N

        # Channel bandwidth.
        self.fb = fs/(self.N/2)

    def get_fs(self):
        return self.fs

    def get_fc(self):
        return self.fc

    def get_fb(self):
        return self.fb

    def qout(self, value):
        self.qout_reg = value

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
        freq = ch*self.fc
        if isinstance(ch, np.ndarray):
            freq[ch >= self.N/2] -= self.fs
        elif ch >= self.N/2:
            freq -= self.fs
        return freq
    
class Mixer:    
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

class AxisSignalGenV4Ctrl(SocIp):
    # Signal Generator V4 Control registers.
    # ADDR_REG
    bindto = ['user.org:user:axis_signal_gen_v4_ctrl:1.0']
    REGISTERS = {
        'freq'    : 0,
        'phase'   : 1,
        'addr'    : 2,
        'gain'    : 3,
        'nsamp'   : 4,
        'outsel'  : 5,
        'mode'    : 6,
        'stdysel' : 7,
        'phrst'   : 8,
        'we'      : 9}
    
    # Generics of Signal Generator.
    N     = 10
    NDDS  = 16
    BDDS  = 32 # Frequency resolution.
    B     = 16 # Amplitude resolution.
    MAX_v = np.power(2,B-1)-1
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.freq    = 0
        self.phase   = 0
        self.addr    = 0
        self.gain    = 30000
        self.nsamp   = 16*100
        self.outsel  = 1 # dds
        self.mode    = 1 # periodic
        self.stdysel = 1 # zero
        self.phrst   = 0
        self.we      = 0

    def configure(self, fs):
        self.FS = fs
        self.DF = self.FS/2**self.BDDS
        self.DFI = 360/2**self.BDDS
        
    def set(self, f = 0, fi = 0, g = 0.5, deg=False, phrst=False):
        # Compute frequency.
        k0 = f/self.DF
        
        # Compute phase.
        if deg:
            fi0 = fi/self.DFI
        else:
            fi0 = (360*fi/(2*np.pi))/self.DFI
            
        # Phase reset flag.
        if phrst:
            self.phrst = 1
        else:
            self.phrst = 0

        # Compute gain.
        g0 = g*self.MAX_v

        self.freq    = int(np.round(k0))
        self.phase   = int(np.round(fi0))
        self.gain    = g0
        
        # Write fifo..
        self.we = 1        
        self.we = 0         
        
    def get(self):
        return self.freq*self.DF

class TopSoc(Overlay):    
    # Constructor.
    def __init__(self, bitfile=None, force_init_clks=False,
                 ignore_version=True,  decimation=2, switchSrc="pfbcic", oneShot=False,
                 streamLength=10000, **kwargs):
        # Load overlay (don't download to PL).
        Overlay.__init__(self, bitfile, ignore_version=ignore_version, download=False, **kwargs)
        
        # Configuration dictionary.
        self.cfg = {}
        self.cfg['board'] = os.environ["BOARD"]
        self.cfg['refclk_freq'] = 409.6        

        # Read the config to get a list of enabled ADCs and DACs, and the sampling frequencies.
        self.list_rf_blocks(self.ip_dict['usp_rf_data_converter_0']['parameters'])
        
        # Configure PLLs if requested, or if any ADC/DAC is not locked.
        if force_init_clks:
            self.set_all_clks()
            self.download()
        else:
            self.download()        
        
        #################
        ### ADC Chain ###
        #################
        # PFB for Analysis.
        self.pfb_in = self.axis_pfb_4x4096_v1_0        
        self.pfb_in.configure(self.adcs['00']['fs']/2)
        
        # DDS + CIC block.
        self.ddscic = self.axis_ddscic_v2_0
        print("before call to self.ddscic.configure:  self.pfb_in.get_fb() =",self.pfb_in.get_fb())
        self.ddscic.configure(self.pfb_in.get_fb())

        # Channel selection.
        self.chsel = self.axis_chsel_pfb_v2_0

        # Streamer.
        self.stream = self.axis_streamer_v1_0
        self.stream.configure(self.axi_dma_0, oneShot)
        
        #################
        ### DAC Chain ###
        #################
        # PFB with 512 Channels for Synthesis.
        self.pfb_out = self.axis_pfbsynth_4x512_0
        self.pfb_out.configure(self.dacs['12']['fs']/4)
        
        # DDS with 512 Channels for Synthesis.
        self.dds_out = self.axis_dds_v3_0
        self.dds_out.configure(self.pfb_out.get_fb())

        # RF data converter (for configuring ADCs and DACs)
        self.rf = self.usp_rf_data_converter_0
        
        # Output frequency generation.
        self.gen = self.axis_signal_gen_v4_c_0
        self.gen.configure(fs = self.dacs['13']['fs'])
       
        # Mixer.
        self.mixer = Mixer(self.usp_rf_data_converter_0)

        # Start streamer and set default transfer length.
        self.streamLength = streamLength
        self.stream.set_nsamp(streamLength)

        self.pfb_in.qout(8)
        self.setDecimate(decimation)
        
        # First Dummy transfer for DMA.
        self.chsel.set_single(0)
        self.stream.transfer_raw(streamLength, first=True)
        self.chsel.alloff()
        
        
    
    def setSwitchSrc(self, switchSrc="pfbcic"):
        """
        Set the switch that chooses what to output

        Parameters
        ----------
        switchSrc : str
            Use 'pfbcic' to choose the demodulation, filtering, and decimation, any other string for the PFB tone
            
        This sets useful members:
        
        fb : double
            sampling frequency of data returned
        time : double
            duration of buffer read
        msecs : nparray(double)
            numpy array of time values, useful for plotting time series, in milliseconds
        """
        
        self.switchSrc = switchSrc
        if switchSrc == "pfb":
            self.switch.sel(slv=0) # pfb only
            self.fb = self.fsIn/(self.pfb_in.N/2)
        else:
            self.switch.sel(slv=1) # pfb & cic
            self.fb = self.fsIn/((self.pfb_in.N/2)*self.ddscic.get_decimate())
        self.time = self.buff.BUFFER_LENGTH/(self.fb*1e6) # In Seconds
        self.msecs = np.arange(self.buff.BUFFER_LENGTH)/(self.fb*1e3) # For plotting, in milli seconds
    def decimation(self, decimate):
        self.ddscic.decimation(decimate)
        
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

    def setDdscicQsel(self, ddscicQselValue):
        """
        Set the number of bits to shift left after decimation.  In general the values
        of (decimate,ddscicQselValue) are anti-correlated, for example 
        (2,21), (4,18), ..., (128,3), (250,0)
        
        Parameters
        ----------
        
        ddscicQselValue : int
            the number of bits to shift left
        """
        
        self.ddscic.qsel(value=ddscicQselValue)
        
    def setDdsFreq(self, ch, ddsFreqMhz):
        """
        Set the dds demodulation frequency for a channel
        
        Parameters
        ----------
        ch : int
            the PFB channel
        ddsFreqMhz : double
            the frequency, in MHz.  Note that in ordinary operations, use the value of the
            member offsetQuantized calculated in the function setTone
        """
        
        ddsFreqHz = 1e6*ddsFreqMhz
        self.ddscic.set_ddsfreq(ch_id=ch, f=ddsFreqHz)
        
    def setDdsOutsel(self, ddscicDdsOutsel):
        """
        Select the output of the ddscic block
        
        Parameters
        ----------
        ddscicDdsOutsel : str
            'product' for normal operation, mixing the input and the dds
            'dds' to pass along only the dds values
            'input' to pass along only the input values
            
        """
        self.ddscic.dds_outsel(outsel=ddscicDdsOutsel)
        
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

    # Convert between channels and frequency for in and out pfbs
    
