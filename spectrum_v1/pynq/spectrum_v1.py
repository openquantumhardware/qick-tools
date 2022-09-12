from qick.qick import *
import matplotlib.pyplot as plt
import time

class AxisPfb8x16V1(SocIp):
    bindto = ['user.org:user:axis_pfb_8x16_v1:1.0']
    REGISTERS = {   'scale_reg' : 0,
                    'qout_reg'  : 1}
    
    # Generic parameters.
    N = 16
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.scale_reg  = 0
        self.qout_reg   = 0

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
        
    def freq2ch(self, f):
        if (0 < f < self.fs):
            k = round(f/self.fc)

            return int(np.mod(k+self.N/2,self.N))
        else:
            print('f must be within [0,{}] range'.format(self.fs))
            return 0

    def ch2freq(self, k):     
        if k >= self.N/2:
            return k*self.fc - self.fs/2
        else:
            return k*self.fc + self.fs/2
          
class AxisAccumulatorV6(SocIp):
    bindto = ['user.org:user:axis_accumulator:1.0']
    REGISTERS = {   'process_reg'           :0, 
                    'tx_and_cnt_reg'        :1, 
                    'tx_and_rst_reg'        :2, 
                    'usr_round_samples_reg' :3, 
                    'usr_epoch_rounds_reg'  :4, 
                    'debug_reg'             :12, 
                    'round_cnt_reg'         :13, 
                    'epoch_cnt_reg'         :14, 
                    'transmitting_reg'      :15}
        
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.process_reg            = 0
        self.tx_and_cnt_reg         = 0
        self.tx_and_rst_reg         = 0
        self.usr_round_samples_reg  = 100
        self.usr_epoch_rounds_reg   = 1
        
        # Generics
        self.AXIS_IN_DW     = int(description['parameters']['AXIS_IN_DW'])
        self.AXIS_OUT_DW    = int(description['parameters']['AXIS_OUT_DW'])
        self.FFT_AW         = int(description['parameters']['FFT_AW'])
        self.BANK_ARRAY_AW  = int(description['parameters']['BANK_ARRAY_AW'])
        self.MEM_DW         = int(description['parameters']['MEM_DW'])
        self.MEM_PIPE       = int(description['parameters']['MEM_PIPE'])
        self.FFT_STORE      = int(description['parameters']['FFT_STORE'])
        self.IQ_FORMAT      = int(description['parameters']['IQ_FORMAT'])

        # Check Parameters.
        if (self.AXIS_IN_DW != 64):
            raise ValueError('Data Width=%d not supported. Must be 64-bit'%self.AXIS_IN_DW)

        # 16 inputs.
        if (self.BANK_ARRAY_AW == 4):
            # FFT Length.
            if (self.FFT_AW != 14):
                raise ValueError('FFT length=%d not supported. Must be 16384'%2**(self.FFT_AW))

            # Store half the bins.
            if (self.FFT_STORE != 1):
                raise ValueError('FFT_STORE must be set to half (1)')

            # IQ Format.
            if (self.IQ_FORMAT != 1):
                raise ValueError('IQ_FORMAT must be set QIQIQIQI (1)')            

            # Buffer length:
            # * Half the FFT Bins x Number of inputs.
            # * One more for metadata.
            # NOTE: each sample is 128 bits.
            self.BUFFER_LENGTH = 2**(self.FFT_AW-1) * 2**self.BANK_ARRAY_AW + 1


        # 1 input.
        elif (self.BANK_ARRAY_AW == 0):
            # FFT Length.
            if (self.FFT_AW != 16):
                raise ValueError('FFT length=%d not supported. Must be 65536'%2**(self.FFT_AW))

            # Store all bins.
            if (self.FFT_STORE != 0):
                raise ValueError('FFT_STORE must be set to all (0)')

            # Buffer length:
            # * FFT Bins x 1.
            # * One more for metadata.
            # NOTE: each sample is 128 bits.
            self.BUFFER_LENGTH = 2**self.FFT_AW + 1
            
        else:
            raise ValueError('Number of parallel input=%d not supported. Must be 1 or 16'%2**(self.BANK_ARRAY_AW))

        # Define buffer:         
        self.buff = allocate(shape=(self.BUFFER_LENGTH,2), dtype=np.int64)

        # FFT Length.
        self.FFT_N = 2**self.FFT_AW

    def configure(self, dma):
        self.dma = dma

    def start(self):
        self.process_reg = 1

    def stop(self):
        self.process_reg = 0

    def single_shot(self,N=1):
        # Set number of averages.
        self.setavg(N)
        
        # Start.
        self.start()
        
        # Wait until average is done.
        while not self.transmitting():
            time.sleep(0.1)
        
        # Stop block.
        self.stop()
        
        # Transfer data.
        return self.transfer()

    def setavg(self, N = 100):
        self.usr_round_samples_reg  = N

    def transmitting(self):
        return self.transmitting_reg

    def transfer(self):
        # DMA data.
        self.dma.recvchannel.transfer(self.buff)
        self.dma.recvchannel.wait()
        
        # Format data:
        # First dimension: Lower 64 bits.
        # Second dimension: Upper 64 bts.
        # Last sample: Meta Data.
        s_low = self.buff[:-1,0]
        s_low = s_low.astype(np.float64)
        s_high = self.buff[:-1,1]
        s_high = s_high.astype(np.float64)
        samples = s_low + (2**64 * s_high).astype(np.float64)
        meta0   = self.buff[-1,0]
        meta1   = self.buff[-1,1]
        nsamp = meta0 >> np.int64(32)

        return samples/nsamp

class AxisChSelPfbx1(SocIp):
    # AXIS Channel Selection PFB Registers
    # CHID_REG
    bindto = ['user.org:user:axis_chsel_pfb_x1:1.0']
    REGISTERS = {'chid_reg' : 0}
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)

        # Generics.
        self.B = int(description['parameters']['B'])
        self.N = int(description['parameters']['N'])

        # Default registers.
        self.set()

    def set(self,ch=0):
        # Change channel
        self.chid_reg = ch         

class AxisBuffer(SocIp):
    # AXIS_buffer registers.
    # DW_CAPTURE_REG
    # * 0 : disable capture.
    # * 1 : enable capture.
    #
    # DR_START_REG
    # * 0 : start reader.
    # * 1 : stop reader.
    bindto = ['user.org:user:axis_buffer:1.0']
    REGISTERS = {'dw_capture' : 0, 'dr_start' : 1}
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.dw_capture = 0
        self.dr_start = 0
        
        # Generics.
        self.B = int(description['parameters']['B'])
        self.N = int(description['parameters']['N'])
        self.BUFFER_LENGTH = (1 << self.N)
        
    def configure(self,axi_dma):
        self.dma = axi_dma
    
    def capture(self):
        # Enable capture
        self.dw_capture = 1
        
        # Wait for capture
        time.sleep(0.1)
        
        # Stop capture
        self.dw_capture = 0
        
    def transfer(self):
        self.dr_start = 0
        
        buff = allocate(shape=(self.BUFFER_LENGTH,), dtype=np.uint32)

        # Start transfer.
        self.dr_start = 1

        # DMA data.
        self.dma.recvchannel.transfer(buff)
        self.dma.recvchannel.wait()

        # Stop transfer.
        self.dr_start = 0
        
        # Return data
        # Format:
        # -> lower 16 bits: I value.
        # -> higher 16 bits: Q value.
        data = buff
        dataI = data & 0xFFFF
        dataI = dataI.astype(np.int16)
        dataQ = data >> 16
        dataQ = dataQ.astype(np.int16)

        return dataI,dataQ
    
    def get_data(self):
        # Capture data.
        self.capture()
        
        # Transfer data.
        return self.transfer()    

class AxisDdsCicV3(SocIp):
    bindto = ['user.org:user:axis_ddscic_v3:1.0']
    REGISTERS = {'pinc_reg'     : 0, 
                 'pinc_we_reg'  : 1, 
                 'prodsel_reg'  : 2,
                 'cicsel_reg'   : 3,
                 'qprod_reg'    : 4, 
                 'qcic_reg'     : 5, 
                 'dec_reg'      : 6}
    
    # Decimation range.
    MIN_D       = 2
    MAX_D       = 1000
    
    # Quantization range for product.
    MIN_QPROD   = 0
    MAX_QPROD   = 16

    # Quantization range for cic.
    MIN_QCIC    = 0
    MAX_QCIC    = 30
    
    # Sampling frequency and frequency resolution (Hz).
    FS_DDS      = 1000
    DF_DDS      = 1
    
    # DDS bits.
    B_DDS       = 32
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.pinc_reg       = 0              # DC frequency.
        self.pinc_we_reg    = 0              # Don't write.
        self.prodsel_reg    = 2              # By-pass DDS.
        self.cicsel_reg     = 1              # By-pass CIC.
        self.qprod_reg      = self.MIN_QPROD # Lower bits.
        self.qcic_reg       = self.MIN_QCIC  # Lower bits.
        self.dec_reg        = self.MIN_D     # Minimum decimation.
        
    def configure(self, fs):
        fs_hz = fs*1000*1000
        self.FS_DDS = fs_hz
        self.DF_DDS = self.FS_DDS/2**self.B_DDS

    def ddsfreq(self, f=0):
        # Sanity check.
        if (f >= 0 and f < self.FS_DDS):
            # Compute register value.
            ki = int(round(f/self.DF_DDS))
            
            # Write value into hardware.
            self.pinc_reg       = ki
            self.pinc_we_reg    = 1
            self.pinc_we_reg    = 0
        
    def prodsel(self, sel="product"):
        if sel == "product":
            self.prodsel_reg = 0
        elif sel == "dds":
            self.prodsel_reg = 1
        elif sel == "input":
            self.prodsel_reg = 2

    def cicsel(self, sel="yes"):
        if sel == "yes":
            self.cicsel_reg = 0
        if sel == "no":
            self.cicsel_reg = 1

    def outsel(self, data="product", cic="yes"):
        self.prodsel(data)
        self.cicsel(cic)

    def set_qprod(self, value=0):
        # Sanity check.
        if (value >= self.MIN_QPROD and value <= self.MAX_QPROD):
            self.qprod_reg = value
            
    def get_qprod(self):
        return self.qprod_reg            

    def set_qcic(self, value=0):
        # Sanity check.
        if (value >= self.MIN_QCIC and value <= self.MAX_QCIC):
            self.qcic_reg = value
            
    def get_qcic(self):
        return self.qcic_reg
            
    def set_dec(self, value):
        # Sanity check.
        if (value >= self.MIN_D and value <= self.MAX_D):
            self.dec_reg = value

    def decimation(self, value):
        # Sanity check.
        if (value >= self.MIN_D and value <= self.MAX_D):
            # Compute CIC output quantization.
            qsel = np.ceil(3*np.log2(value))
            
            # Set values.
            self.set_dec(value)
            self.set_qcic(qsel)
            
    def get_decimation(self):
        if self.cicsel_reg:
            return 1
        else:
            return self.dec_reg

class AxisWxfft65536(SocIp):
    bindto = ['user.org:user:axis_wxfft_65536:1.0']
    REGISTERS = {   'dw_addr_reg'   : 0, 
                    'dw_we_reg'     : 1}
    
    # Number of FFT points.
    N = 65536
    
    # Number of bits.
    B = 16
    
    # Window Gain.
    Aw = 1
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.dw_addr_reg    = 0
        self.dw_we_reg      = 0 # Don't write.

        # Define buffer for window.
        self.buff = allocate(shape=self.N, dtype=np.int16)

    def configure(self, axi_dma):
        # dma.
        self.dma = axi_dma

    def window(self, wtype="hanning"):
        w = self.gen_window(wtype)
        self.load(win=w)
        self.Aw = len(w)/np.sum(w)
        
    def gen_window(self, wtype="hanning"):
        if wtype == "hanning":
            w = (2**(self.B-1)-1)*np.hanning(self.N)
        elif wtype == "rect":
            w = (2**(self.B-1)-1)*np.ones(self.N)
            
        return w

    # Load window coefficients.
    def load(self, win, addr=0):
        # Check for max length.
        if len(win) != self.N:
            raise RuntimeError("%s: buffer length must be %d samples." %(self.__class__.__name__, self.N))

        # Check for max value.
        if np.max(win) > np.iinfo(np.int16).max or np.min(win) < np.iinfo(np.int16).min:
            raise ValueError("window data exceeds limits of int16 datatype")

        # Format data.
        win = win.astype(np.int16)
        np.copyto(self.buff, win)

        #################
        ### Load data ###
        #################
        # Enable writes.
        self._wr_enable(addr)

        # DMA data.
        self.dma.sendchannel.transfer(self.buff)
        self.dma.sendchannel.wait()

        # Disable writes.
        self._wr_disable()

    def _wr_enable(self, addr=0):
        self.dw_addr_reg = addr
        self.dw_we_reg = 1

    def _wr_disable(self):
        self.dw_we_reg = 0

class AxisConstantIQ(SocIp):
    # AXIS Constant IQ registers:
    # REAL_REG : 16-bit.
    # IMAG_REG : 16-bit.
    # WE_REG   : 1-bit. Update registers.
    bindto = ['user.org:user:axis_constant_iq:1.0']
    REGISTERS = {   'real_reg'  :0, 
                    'imag_reg'  :1, 
                    'we_reg'    :2}
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)

        # Generics.
        self.B = int(description['parameters']['B'])
        self.N = int(description['parameters']['N'])
        self.MAX_V = 2**(self.B-1)-1
        
        # Default registers.
        self.real_reg = 30000
        self.imag_reg = 30000
        
        # Register update.
        self.update()

    def update(self):
        self.we_reg = 1
        self.we_reg = 0
        
    def set_iq(self,i=1,q=1):
        # Set registers.
        self.real_reg = int(i*self.MAX_V)
        self.imag_reg = int(q*self.MAX_V)
        
        # Register update.
        self.update()
        
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

class TopSoc(Overlay):    
    # Constructor.
    def __init__(self, bitfile=None, force_init_clks=False, ignore_version=True,  **kwargs):
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
        # PFB 8x16.
        self.pfb = self.axis_pfb_8x16_v1_0        
        self.pfb.configure(self.adcs['00']['fs']/2)
        
        # Accumulator 16x16384.
        self.acc_full = self.axis_accumulator_0
        self.acc_full.configure(self.axi_dma_0)
        
        # Channel selection (PFB).
        self.chsel = self.axis_chsel_pfb_x1_0
        
        # Buffer (PFB).
        self.buff = self.axis_buffer_0
        self.buff.configure(self.axi_dma_1)        

        # DDS + CIC. 
        self.ddscic = self.axis_ddscic_v3_0
        self.ddscic.configure(self.pfb.get_fb())

        # WXFFT 64k.
        self.fft = self.axis_wxfft_65536_0
        self.fft.configure(self.axi_dma_2)
        self.fft.window(wtype="hanning")

        # Accumulator 1x65536
        self.acc_zoom = self.axis_accumulator_1
        self.acc_zoom.configure(self.axi_dma_2)

        #################
        ### DAC Chain ###
        #################
        # Constant IQ.
        self.iq = self.axis_constant_iq_0
        
        # Mixer.
        self.mixer = Mixer(self.usp_rf_data_converter_0)
        
        #############################
        ### Initial Configuration ###
        #############################
        # PFB quantization.
        self.pfb.qout(3)
        
    def findPeak(self, x,y,xmin=-1,xmax=-1):
        if xmin == -1:
            xmin = np.min(x)        
        if xmax == -1:
            xmax = np.max(x)        

        imin = np.argwhere(x <= xmin)
        imin = imin[-1].item()
        imax = np.argwhere(x >= xmax)
        imax = imax[0].item()

        # Find max.
        idxmax = np.argmax(y[imin:imax]) + imin

        # x, y.
        Xmax = x[idxmax].item()
        Ymax = y[idxmax].item()

        return Xmax, Ymax        
    
    # Sort FFT data. Output FFT is bit-reversed. Index is given by idx array.
    def sort_br(self, x, idx):
        x_sort = np.zeros(len(x)) + 1j*np.zeros(len(x))
        for i in np.arange(len(x)):
            x_sort[idx[i]] = x[i]

        return x_sort    
        
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
