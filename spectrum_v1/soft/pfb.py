import numpy as np
from qick.ip import SocIP

class AbsPfbAnalysis(SocIP):
    # Trace parameters.
    STREAM_IN_PORT  = 's_axis'
    STREAM_OUT_PORT = 'm_axis'

    # Flags.
    HAS_ADC         = False
    HAS_DMA         = False
    HAS_XFFT        = False
    HAS_ACC_XFFT = False
    HAS_BUFF_ADC    = False
    HAS_BUFF_PFB    = False
    HAS_BUFF_XFFT   = False
    HAS_WXFFT       = False
    HAS_ACC_ZOOM   = False
    HAS_DDSCIC      = False

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
                block, port, blocktype = soc.metadata.trace_back(block, 'S_AXIS', ["usp_rf_data_converter", "axis_combiner"])
            else:
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
                pfbch_outputs = soc.metadata.list_outputs(block, 'm_axis', ["axis_buffer_v1", "axis_buffer", "axis_ddscic_v3"])
                for block, port, blocktype in pfbch_outputs:
                    if blocktype == "axis_ddscic_v3":
                        self.HAS_DDSCIC = True
                        self.dict['ddscic'] = block

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axis_wxfft_65536"])
                        self.HAS_WXFFT = True
                        self.dict['wxfft'] = block

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis_data', ["axis_accumulator_v1", "axis_accumulator"])
                        self.HAS_ACC_ZOOM = True
                        self.dict['acc_zoom'] = block

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                        self.dict['buff_wxfft_dma'] = block
                    else:
                        self.HAS_BUFF_PFB = True
                        self.dict['buff_pfb'] = block

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                        self.dict['buff_pfb_dma'] = block
            else: # xfft
                self.HAS_XFFT = True
                self.dict['xfft'] = block

                xfft_outputs = soc.metadata.list_outputs(block, 'm_axis', ["axis_accumulator_v1", "axis_accumulator", "axis_chsel_pfb_x1"])
                for block, port, blocktype in xfft_outputs:
                    if blocktype == "axis_chsel_pfb_x1":
                        self.dict['buff_xfft_chsel'] = block

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axis_buffer_uram_v1"])
                        self.HAS_BUFF_XFFT = True
                        self.dict['buff_xfft'] = block

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                        self.dict['buff_xfft_dma'] = block
                    else:
                        self.HAS_ACC_XFFT = True
                        self.dict['acc_xfft'] = block

                        block, _, _ = soc.metadata.trace_forward(block, 'm_axis', ["axi_dma"])
                        self.HAS_DMA = True
                        self.dict['dma'] = block

    def ports2adc(self, port0, port1):
        # This function cheks the given ports correspond to the same ADC.
        # The correspondance is (IQ mode):
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

        # Find adc<->port.
        # IQ on same port.
        if port1 is None:
            tile = p0_n[1]
            adc  = p0_n[2]
            return tile,adc

        # IQ on different ports.
        else:
            p1_n = port1[0:3]

            # IQ on different ports.
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
    
    def __init__(self, description):
        # Initialize ip
        super().__init__(description)

        self.REGISTERS = {  'scale_reg' : 0,
                            'qout_reg'  : 1 }
        
        # Default registers.
        self.scale_reg  = 0
        self.qout_reg   = 0

        # Dictionary.
        self.dict = {}
        #self.dict['N'] = int(description['parameters']['N'])
        self.dict['N'] = 16 #int(description['parameters']['N'])

