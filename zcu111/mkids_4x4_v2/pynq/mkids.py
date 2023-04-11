from qick.qick import *

class AxisSgInt4V1(AbsSignalGen):
    """
    AxisSgInt4V1

    The default max amplitude for this generator is 0.9 times the maximum of int16.
    This is necessary to prevent interpolation overshoot:
    the output of the interpolation filter may exceed the max value of the input points.
    (https://blogs.keysight.com/blogs/tech/rfmw.entry.html/2019/05/07/confronting_measurem-IBRp.html)
    The result of overshoot is integer overflow in the filter output and big negative spikes.
    If the input to the filter is a square pulse, the rising edge of the output overshoots by 10%.
    Therefore, scaling envelopes by 90% seems safe.

    AXIS Signal Generator with envelope x4 interpolation V1 Registers.
    START_ADDR_REG

    WE_REG
    * 0 : disable writes.
    * 1 : enable writes.
    """
    bindto = ['user.org:user:axis_sg_int4_v1:1.0']
    REGISTERS = {'start_addr_reg': 0, 'we_reg': 1}

    # Flags.
    HAS_MIXER           = True
    FS_INTERPOLATION    = 4
    MAXV_SCALE          = 0.9

    # Trace parameters.
    STREAM_IN_PORT      = 's1_axis'
    STREAM_OUT_PORT     = 'm_axis'

    # Flags.
    HAS_CTRL    = False
    HAS_DAC     = False

    def __init__(self, description):
        """
        Constructor method
        """
        super().__init__(description)

        # Default registers.
        self.start_addr_reg = 0
        self.we_reg = 0

        # Generics
        self.N = int(description['parameters']['N'])
        self.NDDS = 4  # Fixed by design, not accesible.

        # Frequency resolution
        self.B_DDS = 16

        # Maximum number of samples
        # Table is interpolated. Length is given only by parameter N.
        self.MAX_LENGTH = 2**self.N

        # Dictionary.
        self.dict = {}
        self.dict['b']      = 16 # Amplitude resolution.
        self.dict['bdds']   = self.B_DDS # Frequency/phase resolution.

    def configure(self, fs):
        self.dict['freq'] = {'fs' : fs}

    def configure_connections(self, soc, verbose=False):
        self.soc = soc

        #####################################################
        ### Backward tracing: should finish at CTRL block ###
        #####################################################
        if verbose:
            print(' ')
            print('{} backward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_IN_PORT)
        if verbose:
            print('{}: Port {} driven by {}.{}'.format(self.fullpath, self.STREAM_IN_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "axis_sg_int4_v1_ctrl":
                self.HAS_CTRL = True

                # Add ctrl to dictionary.
                self.dict['ctrl'] = block
                if verbose:
                    print('{}: done backward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'S_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

        #############################################
        ### Forward tracing: should finish on DAC ###
        #############################################
        if verbose:
            print(' ')
            print('{} forward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_OUT_PORT)
        if verbose:
            print('{}: Port {} drives {}.{}'.format(self.fullpath, self.STREAM_OUT_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "usp_rf_data_converter":
                self.HAS_DAC = True

                # Get DAC and tile.
                tile, dac_ch = self.port2dac(port)

                # Add dac data into dictionary.
                id_ = str(tile) + str(dac_ch)
                self.dict['dac'] = {'tile' : tile, 'ch' : dac_ch, 'id' : id_}
                if verbose:
                    print('{}: done forward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'M_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_register_slice_nb":
                ((block, port),) = soc.metadata.trace_bus(block, 'm_axis')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

    def port2dac(self, port):
        # This function cheks the port correspond to a DAC.
        # The correspondance is:
        #
        # DAC0, tile 0.
        # s00_axis
        #
        # DAC1, tile 0.
        # s01_axis
        #
        # DAC2, tile 0.
        # s02_axis
        #
        # DAC3, tile 0.
        # s03_axis
        #
        # DAC0, tile 1.
        # s10_axis
        #
        # DAC1, tile 1.
        # s11_axis
        #
        # DAC2, tile 1.
        # s12_axis
        #
        # DAC3, tile 1.
        # s13_axis
        #
        # DAC0, tile 2.
        # s20_axis
        #
        # DAC1, tile 2.
        # s21_axis
        #
        # DAC2, tile 2.
        # s22_axis
        #
        # DAC3, tile 2.
        # s23_axis
        #
        # DAC0, tile 3.
        # s30_axis
        #
        # DAC1, tile 3.
        # s31_axis
        #
        # DAC2, tile 3.
        # s32_axis
        #
        # DAC3, tile 3.
        # s33_axis
        #
        # First value, tile.
        # Second value, dac.
        dac_dict =  {
            '0' :   {
                        '0' : {'port' : 's00'}, 
                        '1' : {'port' : 's01'}, 
                        '2' : {'port' : 's02'}, 
                        '3' : {'port' : 's03'}, 
                    },
            '1' :   {
                        '0' : {'port' : 's10'}, 
                        '1' : {'port' : 's11'}, 
                        '2' : {'port' : 's12'}, 
                        '3' : {'port' : 's13'}, 
                    },
            '2' :   {
                        '0' : {'port' : 's20'}, 
                        '1' : {'port' : 's21'}, 
                        '2' : {'port' : 's22'}, 
                        '3' : {'port' : 's23'}, 
                    },
            '3' :   {
                        '0' : {'port' : 's30'}, 
                        '1' : {'port' : 's31'}, 
                        '2' : {'port' : 's32'}, 
                        '3' : {'port' : 's33'}, 
                    },
                    }
        p_n = port[0:3]

        # Find adc<->port.
        for tile in dac_dict.keys():
            for dac in dac_dict[tile].keys():
                if p_n == dac_dict[tile][dac]['port']:
                    return tile,dac

        # If I got here, dac not found.
        raise RuntimeError("Cannot find correspondance with any DAC for port %s" % (port))

class AxisSGInt4V1Ctrl(SocIp):
    bindto = ['user.org:user:axis_sg_int4_v1_ctrl:1.0']
    REGISTERS = {
        'freq_reg'    : 0,
        'phase_reg'   : 1,
        'addr_reg'    : 2,
        'gain_reg'    : 3,
        'nsamp_reg'   : 4,
        'outsel_reg'  : 5,
        'mode_reg'    : 6,
        'we_reg'      : 7}
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.freq_reg    = 0
        self.phase_reg   = 0
        self.addr_reg    = 0
        self.gain_reg    = 30000
        self.nsamp_reg   = 16*100
        self.outsel_reg  = 1 # dds
        self.mode_reg    = 1 # periodic
        self.we_reg      = 0

        # Dictionary.
        self.dict = {}

    def configure(self, gen):
        # Amplitude resolution.
        self.dict['b']    = gen.dict['b']
        self.dict['MAX_g']= 2**(self.dict['b']-1) - 1

        # Frequency resolution.
        self.dict['bdds'] = gen.dict['bdds']
        self.dict['fs']   = gen.dict['freq']['fs']
        self.dict['df']   = self.dict['fs']/2**self.dict['bdds']
        
    def set(self, f = 0, g = 0.5, verbose=False):
        # Compute frequency.
        k0 = f/self.dict['df']
        
        # Compute gain.
        g0 = g*self.dict['MAX_g']

        if verbose:
            print("{}: f = {} MHz, g = {}, df = {} MHz, MAX_g = {}, k0 = {}, g0 = {}".format(self.fullpath, f, g, self.dict['df'], self.dict['MAX_g'], k0, g0))

        # Update registers.
        self.freq_reg = int(np.round(k0))
        self.gain_reg = int(g0)
        
        # Write fifo..
        self.we_reg = 1        
        self.we_reg = 0         

class AxisPfb4x1024V1(SocIp):
    bindto = ['user.org:user:axis_pfb_4x1024_v1:1.0']
    REGISTERS = {'qout_reg' : 0}
    
    # Generic parameters.
    N = 1024

    # Trace parameters.
    STREAM_IN_PORT = 's_axis'
    STREAM_OUT_PORT = 'm_axis'

    # Flags.
    HAS_ADC         = False
    HAS_DDSCIC      = False
    HAS_DDS_DUAL    = False
    HAS_CIC         = False
    HAS_CHSEL       = False
    HAS_STREAMER    = False
    HAS_DMA         = False
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.qout_reg = 0

        # Dictionary.
        self.dict = {}
        self.dict['NCH'] = self.N

    def configure_connections(self, soc, verbose=False):
        self.soc = soc

        ##################################################
        ### Backward tracing: should finish at the ADC ###
        ##################################################
        if verbose:
            print(' ')
            print('{} backward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_IN_PORT)
        if verbose:
            print('{}: Port {} driven by {}.{}'.format(self.fullpath, self.STREAM_IN_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "usp_rf_data_converter":
                self.HAS_ADC = True
                # TODO: find ADC channel when there is no combiner (ZCU216,4x2).
                if verbose:
                    print('{}: done backward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'S_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_reorder_iq_v1":
                ((block, port),) = soc.metadata.trace_bus(block, 's_axis')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_combiner":
                # Sanity check: combiner should have 2 slave ports.
                nslave = int(soc.metadata.get_param(block, 'C_NUM_SI_SLOTS'))

                if nslave != 2:
                    raise RuntimeError("Block %s has %d S_AXIS inputs. It should have 2." % (block, nslave))

                # Trace the two interfaces.
                ((block0, port0),) = soc.metadata.trace_bus(block, 'S00_AXIS')
                ((block1, port1),) = soc.metadata.trace_bus(block, 'S01_AXIS')

                # Get ADC and tile.
                tile, adc_ch = self.ports2adc(port0, port1)

                # Fill adc data dictionary.
                id_ = str(tile) + str(adc_ch)
                self.dict['adc'] = {'tile' : tile, 'ch' : adc_ch, 'id' : id_}

                # Keep tracing back.
                block = block0
                port = port0
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block0, port0))
                    print('{}: {}.{}'.format(self.fullpath, block1, port1))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

        #################################################
        ### Forward tracing: should finish on the DMA ###
        #################################################
        if verbose:
            print(' ')
            print('{} forward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_OUT_PORT)
        if verbose:
            print('{}: Port {} drives {}.{}'.format(self.fullpath, self.STREAM_OUT_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "axi_dma":
                self.HAS_DMA = True

                # Add dma into dictionary.
                self.dict['dma'] = block
                if verbose:
                    print('{}: done forward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'M_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_ddscic_v2":
                self.HAS_DDSCIC = True

                # Add ddscic into dictionary.
                self.dict['ddscic'] = block

                ((block, port),) = soc.metadata.trace_bus(block, 'm_axis')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_dds_dual_v1":
                self.HAS_DDS_DUAL = True

                # Add ddscic into dictionary.
                self.dict['dds'] = block
                ((block, port),) = soc.metadata.trace_bus(block, 'm1_axis')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_cic_v1":
                self.HAS_CIC = True

                # Add ddscic into dictionary.
                self.dict['cic'] = block
                ((block, port),) = soc.metadata.trace_bus(block, 'm_axis')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_chsel_pfb_v2":
                self.HAS_CHSEL = True

                # Add chsel into dictionary.
                self.dict['chsel'] = block

                ((block, port),) = soc.metadata.trace_bus(block, 'm_axis')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            elif blocktype == "axis_streamer_v1":
                self.HAS_STREAMER = True

                # Add streamer into dictionary.
                self.dict['streamer'] = block

                ((block, port),) = soc.metadata.trace_bus(block, 'm_axis')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

    def ports2adc(self, port0, port1):
        # This function cheks the given ports correspond to the same ADC.
        # The correspondance is:
        #
        # ADC0, tile 0.
        # m00_axis: I
        # m01_axis: Q
        #
        # ADC1, tile 0.
        # m02_axis: I
        # m03_axis: Q
        #
        # ADC0, tile 1.
        # m10_axis: I
        # m11_axis: Q
        #
        # ADC1, tile 1.
        # m12_axis: I
        # m13_axis: Q
        #
        # ADC0, tile 2.
        # m20_axis: I
        # m21_axis: Q
        #
        # ADC1, tile 2.
        # m22_axis: I
        # m23_axis: Q
        #
        # ADC0, tile 3.
        # m30_axis: I
        # m31_axis: Q
        #
        # ADC1, tile 3.
        # m32_axis: I
        # m33_axis: Q
        adc_dict = {
            '0' :   {
                        '0' : {'port 0' : 'm00', 'port 1' : 'm01'}, 
                        '1' : {'port 0' : 'm02', 'port 1' : 'm03'}, 
                    },
            '1' :   {
                        '0' : {'port 0' : 'm10', 'port 1' : 'm11'}, 
                        '1' : {'port 0' : 'm12', 'port 1' : 'm13'}, 
                    },
            '2' :   {
                        '0' : {'port 0' : 'm20', 'port 1' : 'm21'}, 
                        '1' : {'port 0' : 'm22', 'port 1' : 'm23'}, 
                    },
            '3' :   {
                        '0' : {'port 0' : 'm30', 'port 1' : 'm31'}, 
                        '1' : {'port 0' : 'm32', 'port 1' : 'm33'}, 
                    },
                    }
        p0_n = port0[0:3]
        p1_n = port1[0:3]

        # Find adc<->port.
        for tile in adc_dict.keys():
            for adc in adc_dict[tile].keys():
                # First possibility.
                if p0_n == adc_dict[tile][adc]['port 0']:
                    if p1_n == adc_dict[tile][adc]['port 1']:
                        return tile,adc
                # Second possibility.
                if p1_n == adc_dict[tile][adc]['port 0']:
                    if p0_n == adc_dict[tile][adc]['port 1']:
                        return tile,adc

        # If I got here, adc not found.
        raise RuntimeError("Cannot find correspondance with any ADC for ports %s,%s" % (port0,port1))

    def configure(self, fs):
        # Channel centers.
        fc = fs/self.N

        # Channel bandwidth.
        fb = fs/(self.N/2)

        # Add data into dictionary.
        self.dict['freq'] = {'fs' : fs, 'fc' : fc, 'fb' : fb}

    def freq2ch(self,f):
        # Check if frequency is on -fs/2 .. fs/2.
        if ( -self.dict['freq']['fs']/2 < f < self.dict['freq']['fs']/2):
            k = np.round(f/self.dict['freq']['fc'])

            if k >= 0:
                return int(k)
            else:
                return int (self.N + k)

    def ch2freq(self,ch):
        if ch >= self.N/2:
            ch_ = self.N - ch
            return -(ch_*self.dict['freq']['fc'])
        else:
            return ch*self.dict['freq']['fc']

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
    MIN_D = 1
    MAX_D = 250
    
    # Quantization range.
    MIN_Q = 0
    MAX_Q = 24
    
    # Sampling frequency and frequency resolution (Hz).
    FS_DDS = 1000
    DF_DDS = 1
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

    def configure(self, fs):
        fs_hz = fs*1000*1000
        self.FS_DDS = fs_hz
        self.DF_DDS = self.FS_DDS/2**self.B_DDS
        self.DF_DDS_MHZ = self.DF_DDS/1000/1000
        
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
    
    def set_ddsfreq(self, ch_id=0, f=0):
        # Sanity check.
        if (ch_id >= 0 and ch_id < self.NCH_TOTAL):
            if (f >= -self.FS_DDS/2 and f < self.FS_DDS/2):
            #if (f >= 0 and f < self.FS_DDS):
                # Compute register value.
                ki = int(round(f/self.DF_DDS))
                
                # Write value into hardware.
                self.addr_nchan_reg = ch_id
                self.addr_pinc_reg = ki
                self.addr_we_reg = 1
                self.addr_we_reg = 0                
        
class AxisCicV1(SocIp):
    bindto = ['user.org:user:axis_cic_v1:1.0']
    REGISTERS = {'cic_rst_reg'    : 0,
                 'cic_d_reg'      : 1, 
                 'qdata_qsel_reg' : 2}
    
    # Decimation range.
    MIN_D = 1
    MAX_D = 250
    
    # Quantization range.
    MIN_Q = 0
    MAX_Q = 24
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.cic_rst_reg    = 1 # Keep resetting accumulator.
        self.cic_d_reg      = 4 # Decimate-by-4.
        self.qdata_qsel_reg = 0 # Upper bits for truncation.
        
        # Generics.
        self.L = int(description['parameters']['L'])
        self.NCH = int(description['parameters']['NCH'])
        self.NCH_TOTAL = self.L * self.NCH

        # Start.
        self.start()

    def start(self):
        self.cic_rst_reg  = 0
        
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
    
class AxisChSelPfbV2(SocIp):
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

        # Dictionary for enabled transactions and channels.
        self.dict = {}
        self.dict['addr'] = [0]*self.NM
        self.dict['tran'] = []
        self.dict['chan'] = []

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

        # Update dictionary.
        self.dict['addr'] = [0]*self.NM
        self.dict['tran'] = [] 
        self.dict['chan'] = [] 
    
    def stop(self):
        self.start_reg = 0

    def start(self):
        self.start_reg = 1

    def tran2channels(self, tran):
        # Sanity check.
        if tran < self.NT:
            return np.arange(tran*self.L, (tran+1)*self.L)
        else:
            raise ValueError("%s: transaction should be within [0,%d]" % (self.fullpath, self.NT-1))
        
    @property
    def enabled_channels(self):
        if len(self.dict['chan']) > 0:
            self.dict['chan'].sort()
            return self.dict['chan'].astype(int)
        else:
            return self.dict['chan']

    def set(self, ch, single=True, verbose=False):
        # Sanity check.
        if ch < 0 or ch >= self.NCH:
            raise ValueError("%s: channel must be within [0,%d]" %(self.fullpath, self.NCH-1))
        else:
            if verbose:
                print("{}: channel = {}".format(self.fullpath, ch))

            # Is channel already enabled?
            if ch not in self.dict['chan']:
                # Need to mask previously un-masked channels?
                if single:
                    self.alloff()

                    if verbose:
                        print("{}: masking previously enabled channels.".format(self.fullpath))

                # Transaction number and bit index.
                ntran, addr, bit = self.ch2tran(ch)

                if verbose:
                    print("{}: ch = {}, ntran = {}, addr = {}, bit = {}".format(self.fullpath, ch, ntran, addr, bit))

                # Enable neighbors.
                self.dict['chan'] = np.append(self.dict['chan'], self.tran2channels(ntran))

                # Enable transaction.
                self.dict['tran'] = np.append(self.dict['tran'], ntran)

                # Data Mask.
                data = self.dict['addr'][addr] + 2**bit
                if verbose:
                    print("{}: Original Mask: {}, Updated Mask: {}".format(self.fullpath, self.dict['addr'][addr], data))
                self.dict['addr'][addr] = data
            
                # Write Value.
                self.addr_reg = addr
                self.data_reg = data
                self.we_reg = 1
                self.we_reg = 0
            
    def set_single(self,ch):
        self.alloff()
        self.set(ch)
            
    def ch2tran(self,ch):
        # Transaction number.
        ntran = ch//self.L

        # Mask Register Address (each is 32-bit).
        addr = ntran//32
        
        # Bit.
        bit = ntran%32
        
        return ntran,addr, bit
    
    def ch2idx(self,ch):
        return np.mod(ch,self.L)

class AxisStreamerV1(SocIp):
    # AXIS_Streamer V1 registers.
    # START_REG
    # * 0 : stop.
    # * 1 : start.
    #
    # NSAMP_REG : number of samples per transaction (for TLAST generation).
    bindto = ['user.org:user:axis_streamer_v1:1.0']
    REGISTERS = {'start_reg' : 0, 'nsamp_reg' : 1}
    
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
        
        # Number of total samples per transaction.
        self.NS_NI = self.NS + self.NI
        
    def configure(self,axi_dma):
        self.dma = axi_dma
    
    def stop(self):
        self.start_reg = 0

    def start(self):
        self.start_reg = 1

    def set(self, nsamp=100):
        # Configure parameters.
        self.nsamp_reg  = nsamp
        nbuf = nsamp*self.NS_TR
        self.buff = allocate(shape=(nbuf,), dtype=np.int16)
        
        # Update register value.
        self.stop()
        self.start()
        
    def transfer_raw(self):
        # DMA data.
        self.dma.recvchannel.transfer(self.buff)
        self.dma.recvchannel.wait()   
        
        return self.buff

    def transfer(self,nt=1):
        # Data structure:
        # First dimention: number of dma transfers.
        # Second dimension: number of streamer transactions.
        # Third dimension: Number of I + Number of Q + Index (17 samples, 16-bit each).
        data = np.zeros((nt,self.nsamp_reg,self.NS_NI))
        
        for i in np.arange(nt):
        
            # DMA data.
            self.dma.recvchannel.transfer(self.buff)
            self.dma.recvchannel.wait()
                
            # Data format:
            # Each streamer transaction is 512 bits. It contains 8 samples (32-bit each) plus 1 sample (16-bit) for TUSER.
            # The upper 15 samples are filled with zeros.        
            data[i,:,:] = self.buff.reshape((self.nsamp_reg, -1))[:,:self.NS_NI]
            
        return data
    
    def get_data(self,nt=1,idx=0):
        # nt: number of dma transfers.
        # idx: from 0..7, index of channel.
        
        # Get data.
        packets = self.transfer(nt=nt)
        
        # Number of samples per transfer.
        ns = len(packets[0])
        
        # Format data.
        data_iq = packets[:,:,:16].reshape((-1,16)).T
        xi,xq = data_iq[2*idx:2*idx+2]        
                
        return [xi,xq]

    def get_data_all(self, verbose=False):
        # Get packets.
        packets = self.transfer()

        # Format data.
        data = {'raw' : [], 'idx' : [], 'samples' : {}}

        # Raw packets.
        data['raw'] = packets[:,:,:self.NS].reshape((-1,self.NS)).T

        # Active transactions.
        data['idx']     = packets[:,:,-1].reshape(-1).astype(int)

        # Group samples per transaction index.
        unique_idx = np.unique(data['idx'])
        for i in unique_idx:
            idx = np.argwhere(data['idx'] == i).reshape(-1)
            data['samples'][i] = data['raw'][:,idx]

        return data


    def format_data(self, data):
        unique_idx = np.unique(data['idx'])

        for i in unique_idx:
            idx = np.argwhere(data['idx'] == i).reshape(-1)
            samples[i] = data['samples'][:,idx]

        return samples

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
        
    def configure(self, fs):
        fs_hz = fs*1000*1000
        self.FS_DDS     = fs_hz
        self.DF_DDS     = self.FS_DDS/2**self.B_DDS
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
        
    def configure(self, fs):
        fs_hz = fs*1000*1000
        self.FS_DDS     = fs_hz
        self.DF_DDS     = self.FS_DDS/2**self.B_DDS
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

class AxisDdsDualV1(SocIp):
    bindto = ['user.org:user:axis_dds_dual_v1:1.0']
    REGISTERS = {'addr_nchan_reg'       : 0, 
                 'addr_pinc_reg'        : 1, 
                 'addr_phase_reg'       : 2,
                 'addr_dds_gain_reg'    : 3,
                 'addr_comp_gain_reg'   : 4,
                 'addr_cfg_reg'         : 5,
                 'addr_we_reg'          : 6,                  
                 'dds_sync_reg'         : 7}
    
    # Sampling frequency and frequency resolution (Hz).
    FS_DDS      = 1000
    DF_DDS      = 1
    DFI_DDS     = 1
    
    # DDS bits.
    B_DDS       = 32

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
        self.addr_nchan_reg     = 0;
        self.addr_pinc_reg      = 0;
        self.addr_phase_reg     = 0;
        self.addr_dds_gain_reg  = 0;
        self.addr_comp_gain_reg = 0;
        self.addr_cfg_reg       = 0; # Down-coverted and compensated output.
        self.addr_we_reg        = 0;
        self.dds_sync_reg       = 1; # Sync DDS.

        # Default sel.
        self.sel_default = "product"

        # Generics
        self.L      = int(description['parameters']['L'])
        self.NCH    = int(description['parameters']['NCH'])
        self.NCH_TOTAL = self.L * self.NCH

        # Initialize DDSs.
        for i in range(self.NCH_TOTAL):
            self.ddscfg(ch = i)

        # Start DDS.
        self.start()
        
    def configure(self, fs):
        fs_hz = fs*1000*1000
        self.FS_DDS     = fs_hz
        self.DF_DDS     = self.FS_DDS/2**self.B_DDS
        self.DFI_DDS    = self.MAX_PHI/2**self.B_DDS

    def start(self):
        self.dds_sync_reg   = 0

    def dds_outsel(self, sel="product"):
        # Set default outsel (for compatibility with DDS+CIC).
        self.sel_default = sel

    def ddscfg(self, f=0, fi=0, g=0, cg_i=0, cg_q=0, ch=0, comp=False):
        # Sanity check.
        if (ch >= 0 and ch < self.NCH_TOTAL):
            if (f >= -self.FS_DDS/2 and f < self.FS_DDS/2):
                if (fi >= self.MIN_PHI and fi < self.MAX_PHI): 
                    if (g >= self.MIN_GAIN and g < self.MAX_GAIN):
                        if (cg_i >= self.MIN_GAIN and cg_i < self.MAX_GAIN):
                            if (cg_q >= self.MIN_GAIN and cg_q < self.MAX_GAIN):
                                # Compute pinc value.
                                ki = int(round(f/self.DF_DDS))

                                # Compute phase value.
                                fik = int(round(fi/self.DFI_DDS))

                                # Compute gain.
                                gi  = g*(2**(self.B_GAIN-1))

                                # Output selection.
                                if self.sel_default == "product":
                                    cfg = 0
                                elif self.sel_default == "dds":
                                    cfg = 1
                                elif self.sel_default == "input":
                                    cfg = 2
                                else:
                                    cfg = 3 # 0 value.

                                # Compensation.
                                if not comp:
                                    cfg += 4

                                self.addr_cfg_reg = 0


                                # Write values to hardware.
                                self.addr_nchan_reg     = ch
                                self.addr_pinc_reg      = ki
                                self.addr_phase_reg     = fik
                                self.addr_dds_gain_reg  = gi
                                # TODO: compensation gain.
                                self.addr_cfg_reg       = cfg
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
            self.ddscfg(ch=ch) # WIll zero-out output and down-convert with 0 freq.

class AxisPfbSynth4x512V1(SocIp):
    bindto = ['user.org:user:axis_pfbsynth_4x512_v1:1.0']
    REGISTERS = {'qout_reg':0}
    
    # Number of channels.
    N = 512

    # Trace parameters.
    STREAM_IN_PORT = 's_axis'
    STREAM_OUT_PORT = 'm_axis'

    # Flags.
    HAS_DAC         = False
    HAS_DDS         = False
    HAS_DDS_DUAL    = False
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.qout_reg   = 0

        # Dictionary.
        self.dict = {}
        self.dict['NCH'] = self.N

    def configure_connections(self, soc, verbose=False):
        self.soc = soc

        ##################################################
        ### Backward tracing: should finish at the DDS ###
        ##################################################
        if verbose:
            print(' ')
            print('{} backward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_IN_PORT)
        if verbose:
            print('{}: Port {} driven by {}.{}'.format(self.fullpath, self.STREAM_IN_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "axis_dds_v3":
                self.HAS_DDS = True

                # Add dds to dictionary.
                self.dict['dds'] = block
                if verbose:
                    print('{}: done backward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'S_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

        #############################################
        ### Forward tracing: should finish on DAC ###
        #############################################
        if verbose:
            print(' ')
            print('{} forward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_OUT_PORT)
        if verbose:
            print('{}: Port {} drives {}.{}'.format(self.fullpath, self.STREAM_OUT_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "usp_rf_data_converter":
                self.HAS_DAC = True

                # Get DAC and tile.
                tile, dac_ch = self.port2dac(port)

                # Add dac data into dictionary.
                id_ = str(tile) + str(dac_ch)
                self.dict['dac'] = {'tile' : tile, 'ch' : dac_ch, 'id' : id_}
                if verbose:
                    print('{}: done forward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'M_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

    def port2dac(self, port):
        # This function cheks the port correspond to a DAC.
        # The correspondance is:
        #
        # DAC0, tile 0.
        # s00_axis
        #
        # DAC1, tile 0.
        # s01_axis
        #
        # DAC2, tile 0.
        # s02_axis
        #
        # DAC3, tile 0.
        # s03_axis
        #
        # DAC0, tile 1.
        # s10_axis
        #
        # DAC1, tile 1.
        # s11_axis
        #
        # DAC2, tile 1.
        # s12_axis
        #
        # DAC3, tile 1.
        # s13_axis
        #
        # DAC0, tile 2.
        # s20_axis
        #
        # DAC1, tile 2.
        # s21_axis
        #
        # DAC2, tile 2.
        # s22_axis
        #
        # DAC3, tile 2.
        # s23_axis
        #
        # DAC0, tile 3.
        # s30_axis
        #
        # DAC1, tile 3.
        # s31_axis
        #
        # DAC2, tile 3.
        # s32_axis
        #
        # DAC3, tile 3.
        # s33_axis
        #
        # First value, tile.
        # Second value, dac.
        dac_dict =  {
            '0' :   {
                        '0' : {'port' : 's00'}, 
                        '1' : {'port' : 's01'}, 
                        '2' : {'port' : 's02'}, 
                        '3' : {'port' : 's03'}, 
                    },
            '1' :   {
                        '0' : {'port' : 's10'}, 
                        '1' : {'port' : 's11'}, 
                        '2' : {'port' : 's12'}, 
                        '3' : {'port' : 's13'}, 
                    },
            '2' :   {
                        '0' : {'port' : 's20'}, 
                        '1' : {'port' : 's21'}, 
                        '2' : {'port' : 's22'}, 
                        '3' : {'port' : 's23'}, 
                    },
            '3' :   {
                        '0' : {'port' : 's30'}, 
                        '1' : {'port' : 's31'}, 
                        '2' : {'port' : 's32'}, 
                        '3' : {'port' : 's33'}, 
                    },
                    }
        p_n = port[0:3]

        # Find adc<->port.
        for tile in dac_dict.keys():
            for dac in dac_dict[tile].keys():
                if p_n == dac_dict[tile][dac]['port']:
                    return tile,dac

        # If I got here, dac not found.
        raise RuntimeError("Cannot find correspondance with any DAC for port %s" % (port))

    def configure(self, fs):
        # Channel centers.
        fc = fs/self.N

        # Channel bandwidth.
        fb = fs/(self.N/2)

        # Add data into dictionary.
        self.dict['freq'] = {'fs' : fs, 'fc' : fc, 'fb' : fb}

    def freq2ch(self,f):
        # Check if frequency is on -fs/2 .. fs/2.
        if ( -self.dict['freq']['fs']/2 < f < self.dict['freq']['fs']/2):
            k = np.round(f/self.dict['freq']['fc'])

            if k >= 0:
                return int(k)
            else:
                return int (self.N + k)

    def ch2freq(self,ch):
        if ch >= self.N/2:
            ch_ = self.N - ch
            return -(ch_*self.dict['freq']['fc'])
        else:
            return ch*self.dict['freq']['fc']

    def qout(self, value):
        self.qout_reg = value

class AxisPfbSynth4x1024V1(SocIp):
    bindto = ['user.org:user:axis_pfbsynth_4x1024_v1:1.0']
    REGISTERS = {'qout_reg':0}
    
    # Number of channels.
    N = 1024

    # Trace parameters.
    STREAM_IN_PORT = 's_axis'
    STREAM_OUT_PORT = 'm_axis'

    # Flags.
    HAS_DAC         = False
    HAS_DDS         = False
    HAS_DDS_DUAL    = False
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)
        
        # Default registers.
        self.qout_reg   = 0

        # Dictionary.
        self.dict = {}
        self.dict['NCH'] = self.N

    def configure_connections(self, soc, verbose=False):
        self.soc = soc

        ##################################################
        ### Backward tracing: should finish at the DDS ###
        ##################################################
        if verbose:
            print(' ')
            print('{} backward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_IN_PORT)
        if verbose:
            print('{}: Port {} driven by {}.{}'.format(self.fullpath, self.STREAM_IN_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "axis_dds_v3":
                self.HAS_DDS = True

                # Add dds to dictionary.
                self.dict['dds'] = block
                if verbose:
                    print('{}: done backward tracing.'.format(self.fullpath))
                break
            if blocktype == "axis_dds_dual_v1":
                self.HAS_DDS_DUAL = True

                # Add dds to dictionary.
                self.dict['dds'] = block
                if verbose:
                    print('{}: done backward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'S_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

        #############################################
        ### Forward tracing: should finish on DAC ###
        #############################################
        if verbose:
            print(' ')
            print('{} forward tracing start'.format(self.fullpath))

        ((block,port),) = soc.metadata.trace_bus(self.fullpath, self.STREAM_OUT_PORT)
        if verbose:
            print('{}: Port {} drives {}.{}'.format(self.fullpath, self.STREAM_OUT_PORT, block, port))

        while True:
            blocktype = soc.metadata.mod2type(block)

            if blocktype == "usp_rf_data_converter":
                self.HAS_DAC = True

                # Get DAC and tile.
                tile, dac_ch = self.port2dac(port)

                # Add dac data into dictionary.
                id_ = str(tile) + str(dac_ch)
                self.dict['dac'] = {'tile' : tile, 'ch' : dac_ch, 'id' : id_}
                if verbose:
                    print('{}: done forward tracing.'.format(self.fullpath))
                break
            elif blocktype == "axis_register_slice":
                ((block, port),) = soc.metadata.trace_bus(block, 'M_AXIS')
                if verbose:
                    print('{}: {}.{}'.format(self.fullpath, block, port))
            else:
                raise RuntimeError("falied to trace port for %s - unrecognized IP block %s" % (self.fullpath, block))

    def port2dac(self, port):
        # This function cheks the port correspond to a DAC.
        # The correspondance is:
        #
        # DAC0, tile 0.
        # s00_axis
        #
        # DAC1, tile 0.
        # s01_axis
        #
        # DAC2, tile 0.
        # s02_axis
        #
        # DAC3, tile 0.
        # s03_axis
        #
        # DAC0, tile 1.
        # s10_axis
        #
        # DAC1, tile 1.
        # s11_axis
        #
        # DAC2, tile 1.
        # s12_axis
        #
        # DAC3, tile 1.
        # s13_axis
        #
        # DAC0, tile 2.
        # s20_axis
        #
        # DAC1, tile 2.
        # s21_axis
        #
        # DAC2, tile 2.
        # s22_axis
        #
        # DAC3, tile 2.
        # s23_axis
        #
        # DAC0, tile 3.
        # s30_axis
        #
        # DAC1, tile 3.
        # s31_axis
        #
        # DAC2, tile 3.
        # s32_axis
        #
        # DAC3, tile 3.
        # s33_axis
        #
        # First value, tile.
        # Second value, dac.
        dac_dict =  {
            '0' :   {
                        '0' : {'port' : 's00'}, 
                        '1' : {'port' : 's01'}, 
                        '2' : {'port' : 's02'}, 
                        '3' : {'port' : 's03'}, 
                    },
            '1' :   {
                        '0' : {'port' : 's10'}, 
                        '1' : {'port' : 's11'}, 
                        '2' : {'port' : 's12'}, 
                        '3' : {'port' : 's13'}, 
                    },
            '2' :   {
                        '0' : {'port' : 's20'}, 
                        '1' : {'port' : 's21'}, 
                        '2' : {'port' : 's22'}, 
                        '3' : {'port' : 's23'}, 
                    },
            '3' :   {
                        '0' : {'port' : 's30'}, 
                        '1' : {'port' : 's31'}, 
                        '2' : {'port' : 's32'}, 
                        '3' : {'port' : 's33'}, 
                    },
                    }
        p_n = port[0:3]

        # Find adc<->port.
        for tile in dac_dict.keys():
            for dac in dac_dict[tile].keys():
                if p_n == dac_dict[tile][dac]['port']:
                    return tile,dac

        # If I got here, dac not found.
        raise RuntimeError("Cannot find correspondance with any DAC for port %s" % (port))

    def configure(self, fs):
        # Channel centers.
        fc = fs/self.N

        # Channel bandwidth.
        fb = fs/(self.N/2)

        # Add data into dictionary.
        self.dict['freq'] = {'fs' : fs, 'fc' : fc, 'fb' : fb}

    def freq2ch(self,f):
        # Check if frequency is on -fs/2 .. fs/2.
        if ( -self.dict['freq']['fs']/2 < f < self.dict['freq']['fs']/2):
            k = np.round(f/self.dict['freq']['fc'])

            if k >= 0:
                return int(k)
            else:
                return int (self.N + k)

    def ch2freq(self,ch):
        if ch >= self.N/2:
            ch_ = self.N - ch
            return -(ch_*self.dict['freq']['fc'])
        else:
            return ch*self.dict['freq']['fc']

    def qout(self, value):
        self.qout_reg = value
class RFDC(xrfdc.RFdc):
    """
    Extends the xrfdc driver.
    Since operations on the RFdc tend to be slow (tens of ms), we cache the Nyquist zone and frequency.
    """
    bindto = ["xilinx.com:ip:usp_rf_data_converter:2.3",
              "xilinx.com:ip:usp_rf_data_converter:2.4",
              "xilinx.com:ip:usp_rf_data_converter:2.6"]

    def __init__(self, description):
        """
        Constructor method
        """
        super().__init__(description)
        # Dictionary for configuration.
        self.dict = {}

        # Initialize nqz and freq.
        self.dict['nqz']  = {'adc' : {}, 'dac' : {}}
        self.dict['freq'] = {'adc' : {}, 'dac' : {}}

    def configure(self, soc):
        self.dict['cfg'] = {'adc' : soc.adcs, 'dac' : soc.dacs}

    def set_mixer_freq(self, blockid, f, blocktype='dac'):
        # Get config.
        cfg = self.dict['cfg'][blocktype]

        # Check Nyquist zone.
        fs = cfg[blockid]['fs']
        if abs(f) > fs/2 and self.get_nyquist(blockid, blocktype)==2:
            fset *= -1

        # Get tile and channel from id.
        tile, channel = [int(a) for a in blockid]

        # Get Mixer Settings.
        if blocktype == 'adc':
            m_set = self.adc_tiles[tile].blocks[channel].MixerSettings
        elif blocktype == 'dac':
            m_set = self.dac_tiles[tile].blocks[channel].MixerSettings
        else:
            raise RuntimeError("Blocktype %s not recognized" & blocktype)

        # Make a copy of mixer settings.
        m_set_copy = m_set.copy()

        # Update the copy
        m_set_copy.update({
            'Freq': f,
            'PhaseOffset': 0})

        # Update settings.
        if blocktype == 'adc':
            self.adc_tiles[tile].blocks[channel].MixerSettings = m_set_copy
            self.adc_tiles[tile].blocks[channel].UpdateEvent(xrfdc.EVENT_MIXER)
            self.dict['freq'][blocktype][blockid] = f
        elif blocktype == 'dac':
            self.dac_tiles[tile].blocks[channel].MixerSettings = m_set_copy
            self.dac_tiles[tile].blocks[channel].UpdateEvent(xrfdc.EVENT_MIXER)
            self.dict['freq'][blocktype][blockid] = f
        else:
            raise RuntimeError("Blocktype %s not recognized" & blocktype)
        

    def get_mixer_freq(self, blockid, blocktype='dac'):
        try:
            return self.dict['freq'][blocktype][blockid]
        except KeyError:
            # Get tile and channel from id.
            tile, channel = [int(a) for a in blockid]

            # Fill freq dictionary.
            if blocktype == 'adc':
                self.dict['freq'][blocktype][blockid] = self.adc_tiles[tile].blocks[channel].MixerSettings['Freq']
            elif blocktype == 'dac':
                self.dict['freq'][blocktype][blockid] = self.dac_tiles[tile].blocks[channel].MixerSettings['Freq']
            else:
                raise RuntimeError("Blocktype %s not recognized" & blocktype)

            return self.dict['freq'][blocktype][blockid]

    def set_nyquist(self, blockid, nqz, blocktype='dac', force=False):
        # Check valid selection.
        if nqz not in [1,2]:
            raise RuntimeError("Nyquist zone must be 1 or 2")

        # Get tile and channel from id.
        tile, channel = [int(a) for a in blockid]

        # Need to update?
        if not force and self.get_nyquist(blockid,blocktype) == nqz:
            return

        if blocktype == 'adc':
            self.adc_tiles[tile].blocks[channel].NyquistZone = nqz
            self.dict['nqz'][blocktype][blockid] = nqz
        elif blocktype == 'dac':
            self.dac_tiles[tile].blocks[channel].NyquistZone = nqz
            self.dict['nqz'][blocktype][blockid] = nqz
        else:
            raise RuntimeError("Blocktype %s not recognized" & blocktype)

    def get_nyquist(self, blockid, blocktype='dac'):
        try:
            return self.dict['nqz'][blocktype][blockid]
        except KeyError:
            # Get tile and channel from id.
            tile, channel = [int(a) for a in blockid]

            # Fill nqz dictionary.
            if blocktype == 'adc':
                self.dict['nqz'][blocktype][blockid] = self.adc_tiles[tile].blocks[channel].NyquistZone
            elif blocktype == 'dac':
                self.dict['nqz'][blocktype][blockid] = self.dac_tiles[tile].blocks[channel].NyquistZone
            else:
                raise RuntimeError("Blocktype %s not recognized" & blocktype)

            return self.dict['nqz'][blocktype][blockid]

class AnalysisChain():
    # Event dictionary.
    event_dict = {
        'source' :
        {
            'immediate' : 0,
            'slice' : 1,
            'tile' : 2,
            'sysref' : 3,
            'marker' : 4,
            'pl' : 5,
        },
        'event' :
        {
            'mixer' : 1,
            'coarse_delay' : 2,
            'qmc' : 3,
        },
    }
    
    # Mixer dictionary.
    mixer_dict = {
        'mode' : 
        {
            'off' : 0,
            'complex2complex' : 1,
            'complex2real' : 2,
            'real2ccomplex' : 3,
            'real2real' : 4,
        },
        'type' :
        {
            'coarse' : 1,
            'fine' : 2,
            'off' : 3,
        }}
    
    # Constructor.
    def __init__(self, soc, chain):
        # Sanity check. Is soc the right type?
        if isinstance(soc, MkidsSoc) == False:
            raise RuntimeError("%s (MkidsSoc, AnalysisChain)" % __class__.__name__)
        else:
            # Soc instance.
            self.soc = soc
            
            # Sanity check. Is this a sythesis chain?
            if chain['type'] != 'analysis':
                raise RuntimeError("An \'analysis\' chain must be provided")
            else:
                # Dictionary.
                self.dict = {}

                # Analysis chain.
                self.dict['chain'] = chain

                # Update settings.
                self.update_settings()
                    
                # Disable all channels.
                self.maskall()
                
                # Default streamer samples.
                streamer = getattr(self.soc, self.dict['chain']['streamer'])
                streamer.set(10000)

                # Frequency resolution (MHz).
                dds = getattr(self.soc, self.dict['chain']['dds'])
                self.dict['fr'] = dds.DF_DDS/1e6
 
    def update_settings(self):
        tile = int(self.dict['chain']['adc']['tile'])
        ch = int(self.dict['chain']['adc']['ch'])
        m_set = self.soc.rf.adc_tiles[tile].blocks[ch].MixerSettings
        self.dict['mixer'] = {
            'mode'     : self.return_key(self.mixer_dict['mode'], m_set['MixerMode']),
            'type'     : self.return_key(self.mixer_dict['type'], m_set['MixerType']),
            'evnt_src' : self.return_key(self.event_dict['source'], m_set['EventSource']),
            'freq'     : m_set['Freq'],
        }
        
        self.dict['nqz'] = self.soc.rf.adc_tiles[tile].blocks[ch].NyquistZone        
        
    def set_mixer_frequency(self, f):
        if self.dict['mixer']['type'] != 'fine':
            raise RuntimeError("Mixer not active")
        else:            
            # Set Mixer with RFDC driver.
            self.soc.rf.set_mixer_freq(self.dict['chain']['adc']['id'], f, 'adc')
            
            # Update local copy of frequency value.
            self.update_settings()
            
    def get_mixer_frequency(self):
        return self.soc.rf.get_mixer_freq(self.dict['chain']['adc']['id'],'adc')
        
    def return_key(self,dictionary,val):
        for key, value in dictionary.items():
            if value==val:
                return key
        return('Key Not Found')
    
    def source(self, source="product"):
        # Get dds block.
        dds_b = getattr(self.soc, self.dict['chain']['dds'])
        
        if dds_b is not None:
            # Set source.
            dds_b.dds_outsel(source)
    
    def set_decimation(self, value=2, autoq=True):
        """
        Sets the decimation value of the DDS+CIC or CIC block of the chain.
        
        :param value: desired decimation value.
        :type value: int
        :param autoq: flag for automatic quantization setting.
        :type autoq: boolean
        """
        # Get block.
        cic_b   = getattr(self.soc, self.dict['chain']['cic'])

        if cic_b is not None:
            if autoq:
                cic_b.decimation(value)
            else:
                cic_b.decimate(value)
    
    def unmask(self, ch=0, single=True, verbose=False):
        """
        Un-masks the specified channel of the Channel Selection block of the chain. When single=True, only one transaction
        will be activated. If single=False, channels will be unmasked without masking previously enabled channels.
        
        :param ch: channel number.
        :type ch: int
        :param single: flag for single transaction at a time.
        :type single: boolean
        """
        # Get chsel.
        chsel = getattr(self.soc, self.dict['chain']['chsel'])
                
        # Unmask channel.
        chsel.set(ch=ch, single=single, verbose=verbose)
        
    def maskall(self):
        """
        Mask all channels of the Channel Selection block of the chain.
        """
        # Get chsel.
        chsel = getattr(self.soc, self.dict['chain']['chsel'])
        
        # Mask all channels.
        chsel.alloff()
    
    def anyenabled(self):
        # Get chsel.
        chsel = getattr(self.soc, self.dict['chain']['chsel'])
        
        if len(chsel.enabled_channels) > 0:
            return True
        else:
            return False          
          
    def get_bin(self, f=0, force_dds=False, verbose=False):
        """
        Get data from the channels nearest to the specified frequency.
        Channel bandwidth depends on the selected chain options.
        
        :param f: specified frequency in MHz.
        :type f: float
        :param force_dds: flag for forcing programming dds_dual.
        :type force_dds: boolean
        :param verbose: flag for verbose output.
        :type verbose: boolean
        :return: [i,q] data from the channel.
        :rtype:[array,array]
        """
        # Get blocks.
        pfb_b = getattr(self.soc, self.dict['chain']['pfb'])
        dds_b = getattr(self.soc, self.dict['chain']['dds'])

        # Sanity check: is frequency on allowed range?
        fmix = abs(self.dict['mixer']['freq'])
        fs = self.dict['chain']['fs']
              
        if (fmix-fs/2) < f < (fmix+fs/2):
            f_ = f - fmix
            k = pfb_b.freq2ch(f_)
            
            # Compute resulting dds frequency.
            fdds = f_ - pfb_b.ch2freq(k)
            
            # Program dds frequency.
            if self.dict['chain']['subtype'] == 'single':
                dds_b.set_ddsfreq(ch_id=k, f=fdds*1e6)
            elif self.dict['chain']['subtype'] == 'dual' and force_dds:
                dds_b.ddscfg(f = fdds*1e6, g = 0.99, ch = k)

            if verbose:
                print("{}: f = {} MHz, fd = {} MHz, k = {}, fdds = {}".format(__class__.__name__, f, f_, k, fdds))
                
            return self.get_data(k,verbose)            
                
        else:
            raise ValueError("Frequency value %f out of allowed range [%f,%f]" % (f,fmix-fs/2,fmix+fs/2))
                
    def get_data(self, ch=0, verbose=False):
        # Get blocks.
        chsel_b    = getattr(self.soc, self.dict['chain']['chsel'])
        streamer_b = getattr(self.soc, self.dict['chain']['streamer'])
        
        # Unmask channel.
        self.unmask(ch, verbose=verbose)
        
        return streamer_b.get_data(nt=1, idx = chsel_b.ch2idx(ch))
    
    def get_data_all(self, verbose=False):
        """
        Get the data from all the enabled channels.
        """
        # Get blocks.        
        streamer_b = getattr(self.soc, self.dict['chain']['streamer'])
        
        # Check if any channel is enabled.
        if self.anyenabled():
            if verbose:
                print("{}: Some channels are enabled. Retrieving data...".format(__class__.__name__))
            
            return streamer_b.get_data_all(verbose=verbose)

    def freq2ch(self, f):
        # Get blocks.
        pfb_b = getattr(self.soc, self.dict['chain']['pfb'])
        
        # Sanity check: is frequency on allowed range?
        fmix = abs(self.dict['mixer']['freq'])
        fs = self.dict['chain']['fs']
              
        if (fmix-fs/2) < f < (fmix+fs/2):
            f_ = f - fmix
            return pfb_b.freq2ch(f_)
        else:
            raise ValueError("Frequency value %f out of allowed range [%f,%f]" % (f,fmix-fs/2,fmix+fs/2))

    def ch2freq(self, ch):
        # Get blocks.
        pfb_b = getattr(self.soc, self.dict['chain']['pfb'])

        # Mixer frequency.
        fmix = abs(self.dict['mixer']['freq'])
        f = pfb_b.ch2freq(ch) 
        
        return f+fmix
    
    def qout(self,q):
        pfb = getattr(self.soc, self.dict['chain']['pfb'])
        pfb.qout(q)
        
    @property
    def fs(self):
        return self.dict['chain']['fs']
    
    @property
    def fc_ch(self):
        return self.dict['chain']['fc_ch']
    
    @property
    def fs_ch(self):
        fs_ch = self.dict['chain']['fs_ch']
        dec = self.decimation
        return fs_ch/dec

    @property
    def fr(self):
        return self.dict['fr']
    
    @property
    def decimation(self):
        cic_b   = getattr(self.soc, self.dict['chain']['cic'])

        if cic_b is not None:
            return cic_b.get_decimate()
        else:
            return 1
    
    @property
    def name(self):
        return self.dict['chain']['name']
    
    @property
    def dds(self):
        return getattr(self.soc, self.dict['chain']['ddscic'])    
        
class SynthesisChain():
    # Event dictionary.
    event_dict = {
        'source' :
        {
            'immediate' : 0,
            'slice' : 1,
            'tile' : 2,
            'sysref' : 3,
            'marker' : 4,
            'pl' : 5,
        },
        'event' :
        {
            'mixer' : 1,
            'coarse_delay' : 2,
            'qmc' : 3,
        },
    }
    
    # Mixer dictionary.
    mixer_dict = {
        'mode' : 
        {
            'off' : 0,
            'complex2complex' : 1,
            'complex2real' : 2,
            'real2ccomplex' : 3,
            'real2real' : 4,
        },
        'type' :
        {
            'coarse' : 1,
            'fine' : 2,
            'off' : 3,
        }}    

    # Constructor.
    def __init__(self, soc, chain):
        # Sanity check. Is soc the right type?
        if isinstance(soc, MkidsSoc) == False:
            raise RuntimeError("%s (MkidsSoc, SynthesisChain)" % __class__.__name__)
        else:
            # Soc instance.
            self.soc = soc
            
            # Sanity check. Is this a sythesis chain?
            if chain['type'] != 'synthesis':
                raise RuntimeError("A \'synthesis\' chain must be provided")
            else:
                # Dictionary.
                self.dict = {}

                # Synthesis chain.
                self.dict['chain'] = chain

                # Is this a PFB or Signal Generator-based chain?
                if 'pfb' in chain.keys():
                    self.dict['type'] = 'pfb'

                    # Set frequency resolution (MHz).
                    ddscic = getattr(self.soc, self.dict['chain']['dds'])
                    self.dict['fr'] = ddscic.DF_DDS/1e6
                elif 'gen' in chain.keys():
                    self.dict['type'] = 'gen'

                    # Set frequency resolution.
                    ctrl = getattr(self.soc, self.dict['chain']['ctrl'])
                    self.dict['fr'] = ctrl.dict['df']
                else:
                    raise RuntimeError("Chain must have a PFB or Signal Generator")

                # Update settings.
                self.update_settings()
 
    def update_settings(self):
        tile = int(self.dict['chain']['dac']['tile'])
        ch = int(self.dict['chain']['dac']['ch'])
        m_set = self.soc.rf.dac_tiles[tile].blocks[ch].MixerSettings
        self.dict['mixer'] = {
            'mode'     : self.return_key(self.mixer_dict['mode'], m_set['MixerMode']),
            'type'     : self.return_key(self.mixer_dict['type'], m_set['MixerType']),
            'evnt_src' : self.return_key(self.event_dict['source'], m_set['EventSource']),
            'freq'     : m_set['Freq'],
        }
        
        self.dict['nqz'] = self.soc.rf.dac_tiles[tile].blocks[ch].NyquistZone        
        
    def set_mixer_frequency(self, f):
        if self.dict['mixer']['type'] != 'fine':
            raise RuntimeError("Mixer not active")
        else:            
            # Set Mixer with RFDC driver.
            self.soc.rf.set_mixer_freq(self.dict['chain']['dac']['id'], f, 'dac')
            
            # Update local copy of frequency value.
            self.update_settings()
            
    def get_mixer_frequency(self):
        return self.soc.rf.get_mixer_freq(self.dict['chain']['dac']['id'],'dac')
        
    def return_key(self,dictionary,val):
        for key, value in dictionary.items():
            if value==val:
                return key
        return('Key Not Found')
    
    # Set all DDS channels off.
    def alloff(self):
        if self.dict['type'] == 'pfb':
            dds = getattr(self.soc, self.dict['chain']['dds'])
            dds.alloff()
        else:
            ctrl = getattr(self.soc, self.dict['chain']['ctrl'])
            ctrl.set(g=0)
        
    # Set single output.
    def set_tone(self, f=0, g=0.99, verbose=False):
        # Sanity check: is frequency on allowed range?
        fmix = self.dict['mixer']['freq']
        fs = self.dict['chain']['fs']        
                
        if (fmix-fs/2) < f < (fmix+fs/2):
            f_ = f - fmix

            if self.dict['type'] == 'pfb':
                pfb_b = getattr(self.soc, self.dict['chain']['pfb'])
                dds_b = getattr(self.soc, self.dict['chain']['dds'])
                k = pfb_b.freq2ch(f_)
            
                # Compute resulting dds frequency.
                fdds = f_ - pfb_b.ch2freq(k)
            
                # Program dds frequency.
                dds_b.ddscfg(f = fdds*1e6, g = g, ch = k)
            
                if verbose:
                    print("{}: f = {} MHz, fd = {} Mhz, k = {}, fdds = {} MHz".format(__class__.__name__, f, f_, k, fdds))
            elif self.dict['type'] == 'gen':
                ctrl = getattr(self.soc, self.dict['chain']['ctrl'])
                ctrl.set(f = f_, g = g)

                if verbose:
                    print("{}: f = {} MHz, fd = {} Mhz".format(__class__.__name__, f, f_))
            
            else:
                raise RuntimeError("{}: not a recognized chain.".format(__class__.__name__))
            
        else:
            raise ValueError("Frequency value %f out of allowed range [%f,%f]" %(f, fmix-fs/2, fmix+fs/2))          

    def freq2ch(self, f):
        # Get blocks.
        pfb_b = getattr(self.soc, self.dict['chain']['pfb'])
        
        # Sanity check: is frequency on allowed range?
        fmix = abs(self.dict['mixer']['freq'])
        fs = self.dict['chain']['fs']
                
        if (fmix-fs/2) < f < (fmix+fs/2):
            f_ = f - fmix
            return pfb_b.freq2ch(f_)

        else:
            raise ValueError("Frequency value %f out of allowed range [%f,%f]" %(f, fmix-fs/2, fmix+fs/2))          

    def ch2freq(self, ch):
        # Get blocks.
        pfb_b = getattr(self.soc, self.dict['chain']['pfb'])

        # Sanity check: is frequency on allowed range?
        fmix = abs(self.dict['mixer']['freq'])
        f = pfb_b.ch2freq(ch)
        
        return f+fmix
            
    # PFB quantization.
    def qout(self,q):
        if self.dict['type'] == 'pfb':
            pfb = getattr(self.soc, self.dict['chain']['pfb'])
            pfb.qout(q)
        
    @property
    def fs(self):
        return self.dict['chain']['fs']
    
    @property
    def fc_ch(self):
        return self.dict['chain']['fc_ch']
    
    @property
    def fs_ch(self):
        return self.dict['chain']['fs_ch']

    @property
    def fr(self):
        return self.dict['fr']
        
    @property
    def name(self):
        return self.dict['chain']['name']
    
    @property
    def dds(self):
        return getattr(self.soc, self.dict['chain']['dds'])
    
class KidsChain():
    # Constructor.
    def __init__(self, soc, analysis=None, synthesis=None, dual=None, name=""):
        # Sanity check. Is soc the right type?
        if isinstance(soc, MkidsSoc) == False:
            raise RuntimeError("%s (MkidsSoc, Analysischain, SynthesisChain)" % __class__.__name__)
        else:
            # Soc instance.
            self.soc = soc
            
            # Chain name.
            self.name = name

            # Force dds flag.
            self.force_dds = False

            # Check Chains.
            if analysis is None and synthesis is None:
                # Must be a dual chain.
                if dual is None:
                    raise RuntimeError("%s Invalid Chains Provided. Options are Analysis,Synthesis or Dual" % __class__.name__)
                else:
                    # Dual Chain flag.
                    self.IS_DUAL = True

                    self.analysis   = AnalysisChain(self.soc, dual['analysis'])
                    self.synthesis  = SynthesisChain(self.soc, dual['synthesis'])

                    # Frequency resolution should be the same!!
                    if self.analysis.fr != self.synthesis.fr:
                        raise RuntimeError("%s Analysis and Syhtiesis Chains of provided Dual Chain are not equal." %__class__.__name)

                    self.fr = self.analysis.fr

            else:
                if analysis is not None and synthesis is None:
                    raise RuntimeError("%s Synthesis Chain Missing" % __class__.name__)
                if analysis is None and syntheis is not None:
                    raise RuntimeError("%s Analysis Chain Missing" % __class__.name__)
                    
                # Dual Chain flag.
                self.IS_DUAL = False

                # Analysis chain.
                self.analysis = AnalysisChain(self.soc, analysis)
                
                # Synthesis chain.
                self.synthesis = SynthesisChain(self.soc, synthesis)

                # Flag to force dds programming.
                # If a dual analysis chain is used with a gen-based synthesis, I need to force
                # the configuration of the DDS (given that it is not programmed at generation).
                if self.analysis.dict['chain']['subtype'] == 'dual' and self.synthesis.dict['type'] == 'gen':
                    self.force_dds = True
                
                # Frequency resolution.
                fr_min = min(self.analysis.fr,self.synthesis.fr)
                fr_max = max(self.synthesis.fr,self.synthesis.fr)
                self.fr = fr_max
                
                # Check Integer Ratio.
                div=fr_max/fr_min
                div_i=int(div)
                if div != div_i:
                    print("{} WARNING: analysis/syhtnesis frequency resolutions are not Integer.".format(__class__.__name__))
                
    def fq(self, f):
        return int(np.round(f/self.fr))*self.fr

    def set_mixer_frequency(self, f):
        self.analysis.set_mixer_frequency(-f) # -fmix to get upper sideband and avoid mirroring.
        self.synthesis.set_mixer_frequency(f)

    def set_tone(self, f=0, g=0.5, verbose=False):
        # Set tone using synthesis chain.
        self.synthesis.alloff()
        self.synthesis.set_tone(f=f, g=g, verbose=verbose)
    
    def source(self, source="product"):
        # Set source using analysis chain.
        self.analysis.source(source = source)

    def set_decimation(self, value = 2, autoq = True):
        # Set decimation using analysis chain.
        self.analysis.set_decimation(value = value, autoq = autoq)

    def get_bin(self, f=0, verbose=False):
        # Get data from bin using analysis chain.
        return self.analysis.get_bin(f=f, force_dds = self.force_dds, verbose=verbose)
    
    def sweep(self, fstart, fend, N=10, g=0.5, decimation = 2, set_mixer=True, verbose=False):
        if set_mixer:
            # Set fmixer at the center of the sweep.
            fmix = (fstart + fend)/2
            fmix = self.fq(fmix)
            self.set_mixer_frequency(fmix)

        # Default settings.
        self.analysis.set_decimation(decimation)
        self.analysis.source("product")
        
        f_v = np.linspace(fstart,fend,N)

        # Check frequency resolution.
        fr = f_v[1] - f_v[0]
        if fr < self.fr:
            print("Required resolution too small. Redefining frequency vector with a resolution of {} MHz".format(self.fr))
            f_v = np.arange(self.fq(fstart), self.fq(fend), self.fr)
            N = len(f_v)
        
        fq_v = np.zeros(N)
        a_v = np.zeros(N)
        phi_v = np.zeros(N)
        i_v = np.zeros(N)
        q_v = np.zeros(N)
        
        print("Starting sweep:")
        print("  * Start      : {} MHz".format(fstart))
        print("  * End        : {} MHz".format(fend))
        print("  * Resolution : {} MHz".format(f_v[1]-f_v[0]))
        print("  * Points     : {}".format(N))
        print(" ")
        for i,f in enumerate(f_v):
            # Quantize frequency.
            fq = self.fq(f)
            
            # Set output tone.
            self.set_tone(f=fq, g=g, verbose=verbose)
            
            # Get input data.
            [xi,xq] = self.get_bin(fq, verbose=verbose)
          
            i0 = 100
            i1 = -100
            iMean = xi[i0:i1].mean()
            qMean = xq[i0:i1].mean()
            
            # Amplitude and phase.
            a = np.abs(iMean + 1j*qMean)
            phi = np.angle(iMean + 1j*qMean)            
            
            fq_v[i] = fq
            a_v[i] = a
            phi_v[i] = phi
            
            if verbose:
                print("i = {}, f = {} MHz, fq = {} MHz, a = {}, phi = {}".format(i,f,fq,a,phi))
            else:
                print("{}".format(i), end=", ")
         
        return fq_v,a_v,phi_v

    def phase_slope(self, f, phi):
        # Compute phase jumps.
        dphi = np.diff(phi)
        idx  = np.argwhere(abs(dphi) > 0.9*2*np.pi).reshape(-1)
        
        # Compute df/dt.
        df = np.diff(f[idx]).mean()
        dt = 1/df

        return df, dt

    def phase_correction(self, f, phi, DT = 20):
        # Unwrap phase.
        phi_u = np.unwrap(phi)
        phi_u = phi_u - phi_u[0]

        # Phase correction by delay DT.
        # phi_u = 2*pi*f*(DT + dt)
        # phi_u = 2*pi*f*DT + 2*pi*f*dt = phi_DT + phi_dt
        # phi_dt = phi_u - 2*pi*f*DT
        phi_dt = phi_u - 2*np.pi*f*DT
        phi_dt = phi_dt - phi_dt[0]

        return phi_u, phi_dt

    def phase_fit(self, f, phi, jumps=True, gap=5):
        # Dictionary for output data.
        data = {}
        data['fits'] = []
        
        # Delay estimation using phase jumps.
        if jumps:
            # Phase diff.
            phi_diff = np.diff(phi)
            
            # Find jumps.
            jv = 0.8*np.max(np.abs(phi_diff))                
            idx = np.argwhere(np.abs(phi_diff) > jv).reshape(-1)
            data['jump'] = {'threshold' : jv, 'index' : idx, 'value' : phi_diff[idx]}
            
            idx_start = 0
            idx_end = len(f)
            for i in range(len(idx)):
                idx_end = idx[i]
                
                # Move away from midpoint.
                idx_start = idx_start + gap
                idx_end = idx_end - gap
                
                x = f[idx_start:idx_end]
                y = phi[idx_start:idx_end]
                coef = np.polyfit(x,y,1)
                fit_fn = np.poly1d(coef)
                
                fit_ = {'slope' : coef[0], 'data' : {'x' : x, 'y': y, 'fn' : fit_fn(x)}}
                data['fits'].append(fit_)
                
                # Update start index.
                idx_start = idx_end + gap
                
            # Section after last jump.
            idx_end = len(f)
    
            # Move away from midpoint.
            idx_start = idx_start + gap
            idx_end = idx_end - gap
    
            x = f[idx_start:idx_end]
            y = phi[idx_start:idx_end]
            coef = np.polyfit(x,y,1)
            fit_fn = np.poly1d(coef)
    
            fit_ = {'slope' : coef[0], 'data' : {'x' : x, 'y': y, 'fn' : fit_fn(x)}}
            data['fits'].append(fit_)        
            
            return data
        
        # Overall delay estimation.
        else:
            coef   = np.polyfit(f,phi, 1)
            fit_fn = np.poly1d(coef)
            
            fit_ = {'slope' : coef[0], 'data' : {'x' : f, 'y' : phi, 'fn' : fit_fn(f)}}
            data['fits'].append(fit_)
            
            return data



class MkidsSoc(Overlay, QickConfig):    

    # Constructor.
    def __init__(self, bitfile=None, force_init_clks=False, ignore_version=True, clk_output=None, external_clk=None, **kwargs):
        """
        Constructor method
        """

        self.external_clk = external_clk
        self.clk_output = clk_output

        # Load bitstream.
        if bitfile is None:
            raise RuntimeError("bitfile name must be provided")
        else:
            Overlay.__init__(self, bitfile, ignore_version=ignore_version, download=False, **kwargs)
        
        # Initialize the configuration
        self._cfg = {}
        QickConfig.__init__(self)

        self['board'] = os.environ["BOARD"]

        # Read the config to get a list of enabled ADCs and DACs, and the sampling frequencies.
        self.list_rf_blocks(
            self.ip_dict['usp_rf_data_converter_0']['parameters'])

        self.config_clocks(force_init_clks)

        # RF data converter (for configuring ADCs and DACs, and setting NCOs)
        self.rf = self.usp_rf_data_converter_0
        self.rf.configure(self)

        # Extract the IP connectivity information from the HWH parser and metadata.
        self.metadata = QickMetadata(self)

        self.map_signal_paths()

    def description(self):
        """Generate a printable description of the QICK configuration.

        Parameters
        ----------

        Returns
        -------
        str
            description

        """
        lines = []
        lines.append("\n\tBoard: " + self['board'])

        lines.append("\n\tAnalysis Chains")
        for i, chain in enumerate(self['analysis']):
            name = ""
            if 'name' in chain.keys():
                name = ", " + chain['name']
            lines.append("\t%d:\t Analysis Chain: ADC Tile = %d, ADC Ch = %d, fs = %.3f MHz, Number of Channels = %d %s" %
                         (i, int(chain['adc']['tile']), int(chain['adc']['ch']), chain['fs'], chain['nch'], name))

        lines.append("\n\tSynthesis Chains")
        for i, chain in enumerate(self['synthesis']):
            name = ""
            if 'name' in chain.keys():
                name = ", " + chain['name']
            lines.append("\t%d:\t Synthesis Chain: DAC Tile = %d, DAC Ch = %d, fs = %.3f MHz, Number of Channels = %d %s" %
                         (i, int(chain['dac']['tile']), int(chain['dac']['ch']), chain['fs'], chain['nch'], name))

        # Dual Chains.
        if len(self['dual']) > 0:
            lines.append("\n\tDual Chains")
            for i, chain in enumerate(self['dual']):
                chain_a = chain['analysis']
                chain_s = chain['synthesis']
                name = ""
                if 'name' in chain.keys():
                    name = chain['name']
                lines.append("\tDual %d: %s" % (i,name))
                lines.append("\t\tAnalysis : ADC Tile = %d, ADC Ch = %d, fs = %.3f MHz, Number of Channels = %d" %
                            (int(chain_a['adc']['tile']), int(chain_a['adc']['ch']), chain_a['fs'], chain_a['nch']))
                lines.append("\t\tSynthesis: DAC Tile = %d, DAC Ch = %d, fs = %.3f MHz, Number of Channels = %d\n" %
                             (int(chain_s['dac']['tile']), int(chain_s['dac']['ch']), chain_s['fs'], chain_s['nch']))


        lines.append("\n\t%d ADCs:" % (len(self['adcs'])))
        for adc in self['adcs']:
            tile, block = [int(c) for c in adc]
            fs = self.adcs[adc]['fs']
            decimation = self.adcs[adc]['decimation']
            if self['board']=='ZCU111':
                label = "ADC%d_T%d_CH%d" % (tile + 224, tile, block)
            elif self['board']=='ZCU216':
                label = "%d_%d, on JHC%d" % (block, tile + 224, 5 + (block%2) + 2*(tile//2))
            elif self['board']=='RFSoC4x2':
                label = {'00': 'ADC_D', '01': 'ADC_C', '20': 'ADC_B', '21': 'ADC_A'}[adc]
            lines.append("\t\tADC tile %d, ch %d, fs = %.3f MHz, decimation = %d, %s" %
                         (tile, block, fs, decimation, label))

        lines.append("\n\t%d DACs:" % (len(self['dacs'])))
        for dac in self['dacs']:
            tile, block = [int(c) for c in dac]
            fs = self.dacs[dac]['fs']
            interpolation = self.dacs[dac]['interpolation']
            if self['board']=='ZCU111':
                label = "DAC%d_T%d_CH%d" % (tile + 228, tile, block)
            elif self['board']=='ZCU216':
                label = "%d_%d, on JHC%d" % (block, tile + 228, 1 + (block%2) + 2*(tile//2))
            elif self['board']=='RFSoC4x2':
                label = {'00': 'DAC_B', '20': 'DAC_A'}[dac]
            lines.append("\t\tDAC tile %d, ch %d, fs = %.3f MHz, interpolation = %d, %s" %
                         (tile, block, fs, decimation, label))

        return "\nQICK configuration:\n"+"\n".join(lines)

    def map_signal_paths(self):
        # Use the HWH parser to trace connectivity and deduce the channel numbering.
        for key, val in self.ip_dict.items():
            if hasattr(val['driver'], 'configure_connections'):
                getattr(self, key).configure_connections(self)

        # PFB for Analysis.
        self.pfbs_in = []
        pfbs_in_drivers = set([AxisPfb4x1024V1])

        # PFB for Synthesis.
        self.pfbs_out = []
        pfbs_out_drivers = set([AxisPfbSynth4x512V1, AxisPfbSynth4x1024V1])

        # SG for Synthesis.
        self.gens = []
        gens_drivers = set([AxisSgInt4V1])

        # Populate the lists with the registered IP blocks.
        for key, val in self.ip_dict.items():
            if val['driver'] in pfbs_in_drivers:
                self.pfbs_in.append(getattr(self, key))
            elif val['driver'] in pfbs_out_drivers:
                self.pfbs_out.append(getattr(self, key))
            elif val['driver'] in gens_drivers:
                self.gens.append(getattr(self, key))

        # Configure the drivers.
        for pfb in self.pfbs_in:
            adc = pfb.dict['adc']['id']
            pfb.configure(self.adcs[adc]['fs']/self.adcs[adc]['decimation'])

            # Does this pfb has a DDSCIC?
            if pfb.HAS_DDSCIC:
                block = getattr(self, pfb.dict['ddscic'])
                block.configure(pfb.dict['freq']['fb'])

            # Does this pfb has a DDS_DUAL?
            if pfb.HAS_DDS_DUAL:
                block = getattr(self, pfb.dict['dds'])
                block.configure(pfb.dict['freq']['fb'])

            # Does this pfb has a CHSEL?
            #if pfb.HAS_CHSEL:
            #    block = getattr(self, pfb.dict['chsel'])

            # Does this pfb has a STREAMER?
            if pfb.HAS_STREAMER:
                # Does this pfb has a DMA?
                if pfb.HAS_DMA:
                    dma     = getattr(self, pfb.dict['dma']) 
                    block   = getattr(self, pfb.dict['streamer'])
                    block.configure(dma)
                else:
                    raise RuntimeError("Block {} has a streamer but not a DMA." % pfb)

        for pfb in self.pfbs_out:
            dac = pfb.dict['dac']['id']
            pfb.configure(self.dacs[dac]['fs']/self.dacs[dac]['interpolation'])

            # Does this pfb has a DDSCIC?
            if pfb.HAS_DDS:
                block = getattr(self, pfb.dict['dds'])
                block.configure(pfb.dict['freq']['fb'])

        for gen in self.gens:
            dac = gen.dict['dac']['id']
            gen.configure(self.dacs[dac]['fs']/self.dacs[dac]['interpolation'])
            
            # Does this block has a CTRL?
            if gen.HAS_CTRL:
                block = getattr(self, gen.dict['ctrl'])
                block.configure(gen)

        self['adcs'] = list(self.adcs.keys())
        self['dacs'] = list(self.dacs.keys())
        self['analysis'] = []
        self['synthesis'] = []
        self['dual'] = []
        for pfb in self.pfbs_in:
            thiscfg = {}
            thiscfg['type'] = 'analysis'
            thiscfg['adc'] = pfb.dict['adc']
            thiscfg['pfb'] = pfb.fullpath
            if pfb.HAS_DDSCIC:
                thiscfg['subtype'] = 'single'
                thiscfg['dds'] = pfb.dict['ddscic']
                thiscfg['cic'] = pfb.dict['ddscic']
            elif pfb.HAS_DDS_DUAL:
                thiscfg['subtype'] = 'dual'
                thiscfg['dds'] = pfb.dict['dds']
                if pfb.HAS_CIC:
                    thiscfg['cic'] = pfb.dict['cic']
                else:
                    thiscfg['cic'] = None
            thiscfg['chsel'] = pfb.dict['chsel']
            thiscfg['streamer'] = pfb.dict['streamer']
            thiscfg['dma'] = pfb.dict['dma']
            thiscfg['fs'] = pfb.dict['freq']['fs']
            thiscfg['fs_ch'] = pfb.dict['freq']['fb']
            thiscfg['fc_ch'] = pfb.dict['freq']['fc']
            thiscfg['nch'] = pfb.dict['NCH']
            self['analysis'].append(thiscfg)

        for pfb in self.pfbs_out:
            thiscfg = {}
            thiscfg['type'] = 'synthesis'
            if pfb.HAS_DDS:
                thiscfg['subtype'] = 'single'
            if pfb.HAS_DDS_DUAL:
                thiscfg['subtype'] = 'dual'
            thiscfg['dac'] = pfb.dict['dac']
            thiscfg['pfb'] = pfb.fullpath
            thiscfg['dds'] = pfb.dict['dds']
            thiscfg['fs'] = pfb.dict['freq']['fs']
            thiscfg['fs_ch'] = pfb.dict['freq']['fb']
            thiscfg['fc_ch'] = pfb.dict['freq']['fc']
            thiscfg['nch'] = pfb.dict['NCH']
            self['synthesis'].append(thiscfg)

        for gen in self.gens:
            thiscfg = {}
            thiscfg['type'] = 'synthesis'
            thiscfg['subtype'] = 'single'
            thiscfg['dac'] = gen.dict['dac']
            thiscfg['gen'] = gen.fullpath
            thiscfg['ctrl'] = gen.dict['ctrl']
            thiscfg['fs'] = gen.dict['freq']['fs']
            thiscfg['nch'] = 1
            self['synthesis'].append(thiscfg)

        # Search for dual chains.
        for ch_a in self['analysis']:
            # Is it dual?
            if ch_a['subtype'] == 'dual':
                # Find matching chain (they share a axis_dds_dual block).
                found = False
                dds = ch_a['dds']
                for ch_s in self['synthesis']:
                    # Is it dual?
                    if ch_s['subtype'] == 'dual':
                        if dds == ch_s['dds']:
                            found = True 
                            thiscfg = {}
                            thiscfg['analysis']  = ch_a
                            thiscfg['synthesis'] = ch_s
                            self['dual'].append(thiscfg)
                    
                # If not found print an error.
                if not found:
                    raise RuntimeError("Could not find dual chain for PFB {}".format(ch_a['pfb']))

    def config_clocks(self, force_init_clks):
        """
        Configure PLLs if requested, or if any ADC/DAC is not locked.
        """
              
        # if we're changing the clock config, we must set the clocks to apply the config
        if force_init_clks or (self.external_clk is not None) or (self.clk_output is not None):
            QickSoc.set_all_clks(self)
            self.download()
        else:
            self.download()
            if not QickSoc.clocks_locked(self):
                QickSoc.set_all_clks(self)
                self.download()
        if not QickSoc.clocks_locked(self):
            print(
                "Not all DAC and ADC PLLs are locked. You may want to repeat the initialization of the QickSoc.")

    def list_rf_blocks(self, rf_config):
        """
        Lists the enabled ADCs and DACs and get the sampling frequencies.
        XRFdc_CheckBlockEnabled in xrfdc_ap.c is not accessible from the Python interface to the XRFdc driver.
        This re-implements that functionality.
        """

        self.hs_adc = rf_config['C_High_Speed_ADC'] == '1'

        self.dac_tiles = []
        self.adc_tiles = []
        dac_fabric_freqs = []
        adc_fabric_freqs = []
        refclk_freqs = []
        self.dacs = {}
        self.adcs = {}

        for iTile in range(4):
            if rf_config['C_DAC%d_Enable' % (iTile)] != '1':
                continue
            self.dac_tiles.append(iTile)
            f_fabric = float(rf_config['C_DAC%d_Fabric_Freq' % (iTile)])
            f_refclk = float(rf_config['C_DAC%d_Refclk_Freq' % (iTile)])
            dac_fabric_freqs.append(f_fabric)
            refclk_freqs.append(f_refclk)
            fs = float(rf_config['C_DAC%d_Sampling_Rate' % (iTile)])*1000
            interpolation = int(rf_config['C_DAC%d_Interpolation' % (iTile)])
            for iBlock in range(4):
                if rf_config['C_DAC_Slice%d%d_Enable' % (iTile, iBlock)] != 'true':
                    continue
                self.dacs["%d%d" % (iTile, iBlock)] = {'fs': fs,
                                                       'f_fabric': f_fabric,
                                                       'interpolation' : interpolation}

        for iTile in range(4):
            if rf_config['C_ADC%d_Enable' % (iTile)] != '1':
                continue
            self.adc_tiles.append(iTile)
            f_fabric = float(rf_config['C_ADC%d_Fabric_Freq' % (iTile)])
            f_refclk = float(rf_config['C_ADC%d_Refclk_Freq' % (iTile)])
            adc_fabric_freqs.append(f_fabric)
            refclk_freqs.append(f_refclk)
            fs = float(rf_config['C_ADC%d_Sampling_Rate' % (iTile)])*1000
            decimation = int(rf_config['C_ADC%d_Decimation' % (iTile)])
            for iBlock in range(4):
                if self.hs_adc:
                    if iBlock >= 2 or rf_config['C_ADC_Slice%d%d_Enable' % (iTile, 2*iBlock)] != 'true':
                        continue
                else:
                    if rf_config['C_ADC_Slice%d%d_Enable' % (iTile, iBlock)] != 'true':
                        continue
                self.adcs["%d%d" % (iTile, iBlock)] = {'fs': fs,
                                                       'f_fabric': f_fabric,
                                                       'decimation' : decimation}

        def get_common_freq(freqs):
            """
            Check that all elements of the list are equal, and return the common value.
            """
            if not freqs:  # input is empty list
                return None
            if len(set(freqs)) != 1:
                raise RuntimeError("Unexpected frequencies:", freqs)
            return freqs[0]

        self['refclk_freq'] = get_common_freq(refclk_freqs)

