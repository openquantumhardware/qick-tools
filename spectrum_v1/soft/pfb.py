import numpy as np
from qick.ip import SocIP

# Sort FFT data. Output FFT is bit-reversed. Index is given by idx array.
def sort_br(x, idx):
    x_sort = np.zeros(len(x)) + 1j*np.zeros(len(x))
    for i in np.arange(len(x)):
        x_sort[idx[i]] = x[i]

    return x_sort

class AbsPfbAnalysis(SocIP):
    # Trace parameters.
    STREAM_IN_PORT  = 's_axis'
    STREAM_OUT_PORT = 'm_axis'

    # Flags.
    HAS_ADC         = False
    HAS_DMA         = False
    HAS_XFFT        = False
    HAS_ACC_XFFT    = False
    HAS_BUFF_ADC    = False
    HAS_SWITCH_ADC  = False
    HAS_BUFF_PFB    = False
    HAS_BUFF_XFFT   = False
    HAS_WXFFT       = False
    HAS_ACC_ZOOM    = False
    HAS_DDSCIC      = False

    def __init__(self, description):
        self.acc_xfft = None
        self.acc_zoom = None
        self.buff_xfft_chsel = None
        self.buff_xfft = None
        self.buff_pfb_chsel = None
        self.buff_pfb = None
        self.buff_adc = None
        self.switch_adc = None

        # Initialize ip
        super().__init__(description)

    def configure(self, fs):
        # Channel centers.
        self.fc = fs/self.dict['N']

        # Channel bandwidth.
        self.fb = fs/(self.dict['N']/2)

        # Add data into dictionary.
        self.dict['freq'] = {'fs' : fs, 'fc' : self.fc, 'fb' : self.fb}
    
    def configure_connections(self, soc):
        self.soc = soc

        ##################################################
        ### Backward tracing: should finish at the ADC ###
        ##################################################
        block, port, blocktype = soc.metadata.trace_back(self['fullpath'], self.STREAM_IN_PORT, ["usp_rf_data_converter", "axis_combiner", "axis_broadcaster"])

        while True:
            if blocktype == "axis_broadcaster":
                # Forward tracing: should end at DMA.
                if port != 'M00_AXIS':
                    raise RuntimeError("expected PFB to be on M00_AXIS port of broadcaster, but it's on %s" % (port))
                # Block/port for forward tracing second broadcaster port.
                block_fwd, port_fwd, _ = soc.metadata.trace_forward(block, 'M01_AXIS', ["mr_buffer_et"])

                # Add block into dictionary.
                self.HAS_BUFF_ADC = True
                self.dict['buff_adc'] = block_fwd
                self.buff_adc = soc._get_block(block_fwd)

                # Trace port.
                block_fwd, port_fwd, _ = soc.metadata.trace_forward(block_fwd, 'm00_axis', ["axi_dma"])

                # Add dma into dictionary.
                self.dict['buff_adc_dma'] = block_fwd
                self.buff_adc_dma = soc._get_block(block_fwd)

                # Normal block/port to continue with backwards trace.
                block, port, blocktype = soc.metadata.trace_back(block, 'S_AXIS', ["usp_rf_data_converter", "axis_combiner", "axis_switch"])
            else:
                if blocktype == "axis_switch":
                    # Add block into dictionary.
                    self.HAS_SWITCH_ADC = True
                    self.dict['switch_adc'] = block
                    self.switch_adc = soc._get_block(block)

                    # # Number of slave interfaces.
                    # NUM_SI_param = int(soc.metadata.get_param(block, 'NUM_SI'))

                    # # Back trace first slave.
                    # for iIn in range(NUM_SI_param):
                    #     inname = "S%02d_AXIS" % (iIn)
                    #     trace_result = soc.metadata.trace_back(block, inname, ["usp_rf_data_converter", "axis_combiner"])
                    #     # skip switch inputs that aren't connected to anything
                    #     if trace_result is None: continue
                    #     ro_block, port, blocktype = trace_result

                        # # trace the decimated output forward to find the avg_buf driven by this readout
                        # block, port, blocktype = soc.metadata.trace_forward(ro_block, 'm1_axis', BUF_TYPES)

                        # self.buf2switch[block] = iIn
                        # self.cfg['readouts'].append(block)

                    # Trace only first input
                    block, port, blocktype = soc.metadata.trace_back(block, 'S00_AXIS', ["usp_rf_data_converter", "axis_combiner"])

                if blocktype == "axis_combiner":
                    # Sanity check: combiner should have 2 slave ports.
                    nslave = int(soc.metadata.get_param(block, 'C_NUM_SI_SLOTS'))
                    if nslave != 2:
                        raise RuntimeError("Block %s has %d S_AXIS inputs. It should have 2." % (block, nslave))

                    # for dual ADC (ZCU111, RFSoC4x2) the RFDC block has two outputs per ADC, which we combine - look at the first one
                    ((block, port),) = soc.metadata.trace_bus(block, 'S00_AXIS')

                self.HAS_ADC = True
                # port names are of the form 'm02_axis'
                self.dict['adc'] = {'id': port[1:3]}
                break

        #################################################
        ### Forward tracing: should finish at the DMA ###
        #################################################

        pfb_outputs = soc.metadata.list_outputs(self['fullpath'], self.STREAM_OUT_PORT, ["axis_xfft_16x16384", "axis_xfft_16x32768", "axis_chsel_pfb_x1"])
        for block, port, blocktype in pfb_outputs:
            if blocktype == "axis_chsel_pfb_x1":
                self.dict['buff_pfb_chsel'] = block
                self.buff_pfb_chsel = soc._get_block(block)

                pfbch_outputs = soc.metadata.list_outputs(block, 'm_axis', ["axis_buffer_v1", "axis_buffer", "axis_ddscic_v3"])
                for block, port, blocktype in pfbch_outputs:
                    if blocktype == "axis_ddscic_v3":
                        self.HAS_DDSCIC = True
                        self.dict['ddscic'] = block

                        ddscic_outputs = soc.metadata.list_outputs(block, 'm_axis', ["axis_buffer_v1", "axis_buffer", "axis_wxfft_65536"])
                        for block, port, blocktype in ddscic_outputs:
                            if blocktype == "axis_wxfft_65536":
                                self.HAS_WXFFT = True
                                self.dict['wxfft'] = block

                                block, _, _ = soc.metadata.trace_forward(block, 'm_axis_data', ["axis_accumulator_v1", "axis_accumulator"])
                                self.HAS_ACC_ZOOM = True
                                self.dict['acc_zoom'] = block
                                self.acc_zoom = soc._get_block(block)

                                block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                                self.dict['buff_wxfft_dma'] = block
                            else:
                                # PFB Buffer can be at output of DDSCIC...
                                self.HAS_BUFF_PFB = True
                                self.dict['buff_pfb'] = block
                                self.buff_pfb = soc._get_block(block)

                                block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                                self.dict['buff_pfb_dma'] = block
                    else:
                        # ... or it can be at the output of the PFB_CHSEL 
                        self.HAS_BUFF_PFB = True
                        self.dict['buff_pfb'] = block
                        self.buff_pfb = soc._get_block(block)

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                        self.dict['buff_pfb_dma'] = block
            else: # xfft
                self.HAS_XFFT = True
                self.dict['xfft'] = block

                xfft_outputs = soc.metadata.list_outputs(block, 'm_axis', ["axis_accumulator_v1", "axis_accumulator", "axis_chsel_pfb_x1"])
                for block, port, blocktype in xfft_outputs:
                    if blocktype == "axis_chsel_pfb_x1":
                        self.dict['buff_xfft_chsel'] = block
                        self.buff_xfft_chsel = soc._get_block(block)

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axis_buffer_uram_v1"])
                        self.HAS_BUFF_XFFT = True
                        self.dict['buff_xfft'] = block
                        self.buff_xfft = soc._get_block(block)

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                        self.dict['buff_xfft_dma'] = block
                    else:
                        self.HAS_ACC_XFFT = True
                        self.dict['acc_xfft'] = block
                        self.acc_xfft = soc._get_block(block)

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                        self.HAS_DMA = True
                        self.dict['dma'] = block

        # Mixer dictionary.
        source_dict = {
            0: 'immediate',
            1: 'slice',
            2: 'tile',
            3: 'sysref',
            4: 'marker',
            5: 'pl',
        }
        mode_dict = {
                0: 'off',
                1: 'complex2complex',
                2: 'complex2real',
                3: 'real2ccomplex',
                4: 'real2real',
            }
        type_dict = {
                1: 'coarse',
                2: 'fine',
                3: 'off',
            }
        # Coarse Mixer Dictionary.
        coarse_dict = {
                0 : 'off',
                2 : 'fs_div_2',
                4 : 'fs_div_4',
                8 : 'mfs_div_4',
                16: 'bypass',
                }

        m_set = self.soc.rf._get_block('adc', self.dict['adc']['id']).MixerSettings.copy()
        self.dict['mixer'] = {
            #'mode'     : mode_dict[m_set['MixerMode']],
            'type'     : type_dict[m_set['MixerType']],
            #'evnt_src' : source_dict[m_set['EventSource']],
        }

        # Check type.
        if self.dict['mixer']['type'] == 'fine':
            self.dict['mixer']['freq'] = self.soc.rf.get_mixer_freq(self.dict['adc']['id'], 'adc')
        elif self.dict['mixer']['type'] == 'coarse':
            type_c = coarse_dict[m_set['CoarseMixFreq']]
            fs_adc = self.soc['rf']['adcs'][self.dict['adc']['id']]['fs']
            if type_c == 'fs_div_2':
                freq = fs_adc/2
            elif type_c == 'fs_div_4':
                freq = fs_adc/4
            elif type_c == 'mfs_div_4':
                freq = -fs_adc/4
            else:
                raise ValueError("Mixer CoarseMode %s not recognized" % (type_c))

            self.dict['mixer']['freq'] = freq

        self.dict['nqz'] = self.soc.rf.get_nyquist(self.dict['adc']['id'], 'adc')

    def set_mixer_freq(self, f):
        self.soc.rf.set_mixer_freq(self.dict['adc']['id'], f, 'adc')

    def get_mixer_freq(self):
        if self.dict['mixer']['type'] == 'coarse':
            return self.dict['mixer']['freq']
        else:
            return self.soc.rf.get_mixer_freq(self.dict['adc']['id'], 'adc')

    def freq2ch(self,f):
        """
        Convert from frequency to PFB channel number
        
        Parameters:
        -----------
            f : float, list of floats, or numpy array of floats
                frequency in MHz
        
        Returns:
        --------
            ch : int or numpyr array of np.int64
                The channel number that contains the frequency
            
        Raises:
            ValueError
                if any of the frequencies are outside the allowable range of +/- fs/2
                
        """
        # if f is a list convert it to numpy array
        if isinstance(f, list):
            f = np.array(f)
            
        # Check if all frequencies are in -fs/2 .. fs/2
        fMax = self.dict['freq']['fs']/2
        if np.any(abs(f) > fMax):
                    raise ValueError("Frequency value %s out of allowed range [%f,%f]" % (str(f),-fMax, fMax))

        k = np.round(f/self.dict['freq']['fc']).astype(int)
        if isinstance(k,np.int64):
            if k < 0:
                k += self.dict['N']
        else:
            k[k<0] += self.dict['N']
        return k
    
    def ch2freq(self,ch):
        """
        Convert from PFB input channel number to frequency at center of bin
        
        Parameters:
        -----------
           ch : int or numpy array of np.int64
                The channel number that contains the frequency
         
        Returns:
        --------
           f : float, list of floats, or numpy array of floats
                frequency in MHz at the center of the bin
             
        Raises:
            ValueError
                if any of the bin numbers are out of range [0,N)
                
        """
        # if ch is a list convert it to numpy array
        if isinstance(ch, list):
            ch = np.array(ch)
        N = self.dict['N']
        if np.any(ch < 0) or np.any(ch >= N):
                    raise ValueError("Channel value %s out of allowed range [0,%d)" % (str(ch),N))
      
        fc = self.dict['freq']['fc']
        freq = ch*fc
        
        if isinstance(ch, int) or isinstance(ch, np.int64):
            if ch >= N//2: 
                freq -= N*fc
        else:           
            freq = ch*fc
            freq[ch >= N//2] -= N*fc
        return freq
            
    def qout(self, qout):
        self.qout_reg = qout

    def get_fs(self):
        return self.fs

    def get_fc(self):
        return self.fc

    def get_fb(self):
        return self.fb

    def get_data_adc(self, verbose=False):
        # Return data.
        #return self.buff_adc.get_data()
        self.buff_adc.disable()
        self.buff_adc.enable()
        return self.buff_adc.transfer().T

    def get_bin_pfb(self, f, verbose=False):
        # Sanity check: is frequency on allowed range?
        fs = self.dict['freq']['fs']
        fmix = abs(self.get_mixer_freq())
        if np.abs(f - fmix) > fs/2:
            raise ValueError("Frequency value %f out of allowed range [%f,%f]" % (f,fmix-fs/2,fmix+fs/2))
        f_ = f - fmix
        k = self.freq2ch(f_)

        # Un-mask channel.
        self.buff_pfb_chsel.set(k)

        if verbose:
            print("{}: f = {} MHz, fd = {} MHz, k = {}".format(__class__.__name__, f, f_, k))

        # Get data.
        return self.buff_pfb.get_data()

    def get_bin_xfft(self, f, verbose=False):
        # Sanity check: is frequency on allowed range?
        fs = self.dict['freq']['fs']
        fmix = abs(self.get_mixer_freq())
        if np.abs(f - fmix) > fs/2:
            raise ValueError("Frequency value %f out of allowed range [%f,%f]" % (f,fmix-fs/2,fmix+fs/2))
        f_ = f - fmix
        k = self.freq2ch(f_)

        # Un-mask channel.
        self.buff_xfft_chsel.set(k)

        if verbose:
            print("{}: f = {} MHz, fd = {} MHz, k = {}".format(__class__.__name__, f, f_, k))

        # Get data.
        [xi,xq,idx] = self.buff_xfft.get_data()
        x = xi + 1j*xq
        x = sort_br(x,idx)
        return x.real,x.imag

    def get_data_acc(self, N, verbose=False):
        x = self.acc_xfft.single_shot(N=N)
        fft_n = self.acc_xfft.FFT_N
        x = np.roll(x, -int(fft_n/4))
        return x

    def get_data_acc_zoom(self, N, verbose=False):
        return self.acc_zoom.single_shot(N=N)

class AxisPfbAnalysis(AbsPfbAnalysis):
    """
    AxisPfbAnalysis class
    Supports AxisPfb4x1024V1, AxisPfbaPr4x256V1, AxisPfb4x64V1, AxisPfb8x16V1
    """
    bindto = ['user.org:user:axis_pfb_4x1024_v1:1.0'   ,
              'user.org:user:axis_pfb_4x64_v1:1.0'     ,
              'user.org:user:axis_pfba_pr_4x256_v1:1.0',
              'user.org:user:axis_pfb_8x16_v1:1.0'     ,
              'QICK:QICK:axis_pfb_8x16_v1:1.0'         ]
    
    def _init_config(self, description):
        self.REGISTERS = {  'scale_reg' : 0,
                            'qout_reg'  : 1 }
        # Dictionary.
        self.dict = {}
        #self.dict['N'] = int(description['parameters']['N'])
        self.dict['N'] = 16 #int(description['parameters']['N'])
        
    def _init_firmware(self):
        # Default registers.
        self.scale_reg  = 0
        self.qout_reg   = 0


