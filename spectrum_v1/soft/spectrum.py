from qick.qick import *

from pfb import *
from misc import *
from fft_helpers import *
import numpy as np


class AnalysisChain():
    # Constructor.
    def __init__(self, soc, chain):
        # Sanity check. Is soc the right type?
        #if not isinstance(soc, SpectrumSoc):
        #    raise RuntimeError("%s (SpectrumSoc, AnalysisChain)" % __class__.__name__)

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

            self.ch = chain['ch']

    def set_mixer_frequency(self, f):
        self.soc.ana_set_mixer_freq(self.ch, f)

    def get_mixer_frequency(self):
        return self.soc.ana_get_mixer_freq(self.ch)

    def get_data_adc(self, verbose=False):
        return self.soc.ana_get_data_adc(self.ch, verbose)

    def get_bin_pfb(self, f=0, verbose=False):
        """
        Get data from the channels nearest to the specified frequency.
        Channel bandwidth depends on the selected chain options.
        
        :param f: specified frequency in MHz.
        :type f: float
        :param verbose: flag for verbose output.
        :type verbose: boolean
        :return: [i,q] data from the channel.
        :rtype:[array,array]
        """
        return self.soc.ana_get_bin_pfb(self.ch, f, verbose)

    def get_bin_xfft(self, f=0, verbose=False):
        """
        Get data from the channel nearest to the specified frequency.

        :param f: specified frequency in MHz.
        :type f: float
        :param verbose: flag for verbose output.
        :type verbose: boolean
        :return: [i,q] data from the channel.
        :rtype:[array,array]
        """
        return self.soc.ana_get_bin_xfft(self.ch, f, verbose)

    def get_data_acc(self, N=1, verbose=False):
        return self.soc.ana_get_data_acc(self.ch, N, verbose)

    def get_data_acc_zoom(self, N=1, verbose=False):
        return self.soc.ana_get_data_zoom(self.ch, N, verbose)

    def freq2ch(self, f):
        return self.soc.ana_freq2ch(self.ch, f)

    def ch2freq(self, ch):
        return self.soc.ana_ch2freq(self.ch, ch)
    
    def qout(self,q):
        self.soc.ana_qout(self.ch, q)
        
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
    def nch(self):
        return self.dict['chain']['nch']

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
        if not isinstance(soc, SpectrumSoc):
            raise RuntimeError("%s (SpectrumSoc, SynthesisChain)" % __class__.__name__)

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

    """
    def update_settings(self):
        m_set = self.soc.get_mixer_state(self.dict['chain']['dac']['id'], 'dac')
        self.dict['mixer'] = {
            #'mode'     : self.return_key(self.mixer_dict['mode'], m_set['MixerMode']),
            'type'     : self.return_key(self.mixer_dict['type'], m_set['MixerType']),
            #'evnt_src' : self.return_key(self.event_dict['source'], m_set['EventSource']),
        }
        
        self.dict['mixer']['freq'] = self.soc.get_mixer_freq_direct(self.dict['chain']['dac'], 'dac')
        self.dict['nqz'] = self.soc.get_nyquist(self.dict['chain']['dac'], 'dac')
        
    def set_mixer_frequency(self, f):
        self.soc.set_mixer_freq_direct(self.dict['chain']['dac'], f, 'dac')
        # Update local copy of frequency value.
        self.dict['mixer']['freq'] = self.soc.get_mixer_freq_direct(self.dict['chain']['dac'], 'dac')
            
    def get_mixer_frequency(self):
        return self.soc.rf.get_mixer_freq(self.dict['chain']['dac'],'dac')

    def return_key(self,dictionary,val):
        for key, value in dictionary.items():
            if value==val:
                return key
        return('Key Not Found')
    """

    # Set single output.
    def set_tone(self, f=0, g=0.99, verbose=False):
        self.soc.set_iq(ch=self.dict['chain']['iq'], f=f, i=g, q=g)

class DualChain():
    # Constructor.
    def __init__(self, soc, analysis, synthesis):
        # Sanity check. Is soc the right type?
        if not isinstance(soc, SpectrumSoc):
            raise RuntimeError("%s (SpectrumSoc, Analysischain, SynthesisChain)" % __class__.__name__)
        else:
            # Soc instance.
            self.soc = soc

            # Analsis and Synthesis chains.
            self.analysis   = AnalysisChain(self.soc, analysis)
            self.synthesis  = SynthesisChain(self.soc, synthesis)

    def set_tone(self, f=0, g=0.5, verbose=False):
        # Set tone using synthesis chain.
        self.synthesis.set_tone(f=f, g=g, verbose=verbose)

    def get_data_adc(self, verbose=False):
        return self.analysis.get_data_adc(verbose=verbose)

    def get_bin_pfb(self, f=0, verbose=False):
        return self.analysis.get_bin_pfb(f=f, verbose=verbose)

    def get_bin_xfft(self, f=0, verbose=False):
        return self.analysis.get_bin_xfft(f=f, verbose=verbose)

    def get_data_acc(self, N=1, verbose=False):
        return self.analysis.get_data_acc(N=N, verbose=verbose)

    def get_data_acc_zoom(self, N=1, verbose=False):
        return self.analysis.get_data_acc_zoom(N=N, verbose=verbose)

    @property
    def fs(self):
        return self.analysis.fs

    @property
    def fc_ch(self):
        return self.analysis.fc_ch

    @property
    def fs_ch(self):
        return self.analysis.fs_ch

    @property
    def nch(self):
        return self.analysis.nch

class SpectrumSoc(QickSoc):

    def __init__(self, bitfile=None, **kwargs):
        super().__init__(bitfile=bitfile, **kwargs)

        lines = []
        lines = ["\nSPECTRUM configuration:\n"]
        lines.append("\n\tBoard: " + self['board'])

        # Analysis Chains.
        if len(self['analysis']) > 0:
            for i, chain in enumerate(self['analysis']):
                adc_ = self['rf']['adcs'][chain['adc']['id']]
                lines.append("\tAnalysis %d:" % (i))
                lines.append("\t\t%s" % (self._describe_adc(chain['adc']['id'])))
                lines.append("\t\tfs = %.1f MHz, Decimation    = %d" %
                             (adc_['fs'], adc_['decimation']))
                lines.append("\t\tPFB: fs = %.1f MHz, fc = %.1f MHz, %d channels" %
                             (chain['fs_ch'], chain['fc_ch'], chain['nch']))
                #lines.append("\t\tXFFT
        self['extra_description'].extend(lines)

    def map_signal_paths(self, no_tproc):
        super().map_signal_paths(no_tproc)

        # PFB for Analysis.
        self.pfbs_in = []
        pfbs_in_drivers = set([AxisPfbAnalysis])
        for key, val in self.ip_dict.items():
            if val['driver'] in pfbs_in_drivers:
                self.pfbs_in.append(getattr(self, key))

        #self.pfb    = self.axis_pfb_8x16_v1_0

        # Configure the drivers.
        for pfb in self.pfbs_in:
            adc = pfb.dict['adc']['id']
            adccfg = self['rf']['adcs'][adc]
            pfb.configure(adccfg['fs']/adccfg['decimation'])

            # BUFF_PFB: axis_buffer_v1.
            if pfb.HAS_BUFF_PFB:
                block = getattr(self, pfb.dict['buff_pfb'])
                dma = getattr(self, pfb.dict['buff_pfb_dma'])
                block.configure(dma)

            # WXFFT: axis_wxfft_65536_v1.
            if pfb.HAS_WXFFT:
                block = getattr(self, pfb.dict['wxfft'])
                dma = getattr(self, pfb.dict['buff_wxfft_dma'])
                block.configure(dma)
                block.window(wtype="hanning")
                self.fft = self.axis_wxfft_65536_0
                self.chsel  = self.axis_chsel_pfb_x1_0
                self.ddscic = self.axis_ddscic_v3_0
                self.ddscic.configure(pfb.dict['freq']['fb'])

            # ACC_ZOOM: axis_accumulator_v1.
            if pfb.HAS_ACC_ZOOM:
                block = getattr(self, pfb.dict['acc_zoom'])
                dma = getattr(self, pfb.dict['buff_wxfft_dma'])
                block.configure(dma)
                self.WFFT_N = int(block.FFT_N)
                self.acc_zoom = self.axis_accumulator_1

            # BUFF_XFFT: axis_buffer_uram.
            if pfb.HAS_BUFF_XFFT:
                block = getattr(self, pfb.dict['buff_xfft'])
                dma = getattr(self, pfb.dict['buff_xfft_dma'])
                block.configure(dma, sync="yes")

            # ACC_XFFT: axis_accumulator_v1.
            if pfb.HAS_ACC_XFFT:
                block = getattr(self, pfb.dict['acc_xfft'])
                dma = getattr(self, pfb.dict['dma'])
                block.configure(dma)
                self.FFT_N = int(block.FFT_N)
                self.acc_full = self.axis_accumulator_0


        self['analysis'] = []
        self['synthesis'] = []
        for i, pfb in enumerate(self.pfbs_in):
            thiscfg = {}
            thiscfg['ch']     = i
            thiscfg['type']     = 'analysis'
            thiscfg['pfb']      = pfb['fullpath']
            thiscfg['fs']       = pfb.dict['freq']['fs']
            thiscfg['fs_ch']    = pfb.dict['freq']['fb']
            thiscfg['fc_ch']    = pfb.dict['freq']['fc']
            thiscfg['nch']      = pfb.dict['N']
            if pfb.HAS_ADC:
                thiscfg['adc'] = pfb.dict['adc']
            if pfb.HAS_XFFT:
                thiscfg['xfft'] = pfb.dict['xfft']
            if pfb.HAS_ACC_XFFT:
                thiscfg['acc_xfft'] = pfb.dict['acc_xfft']
            if pfb.HAS_BUFF_ADC:
                thiscfg['buff_adc'] = pfb.dict['buff_adc']
            if pfb.HAS_BUFF_PFB:
                thiscfg['buff_pfb'] = pfb.dict['buff_pfb']
            if pfb.HAS_BUFF_XFFT:
                thiscfg['buff_xfft'] = pfb.dict['buff_xfft']
            if pfb.HAS_DDSCIC:
                thiscfg['ddscic'] = pfb.dict['ddscic']
            if pfb.HAS_WXFFT:
                thiscfg['wxfft'] = pfb.dict['wxfft']
            if pfb.HAS_ACC_ZOOM:
                thiscfg['acc_zoom'] = pfb.dict['acc_zoom']

            self['analysis'].append(thiscfg)

        # IQ Constant based synthesis.
        for i, iq in enumerate(self.iqs):
            thiscfg = {}
            thiscfg['type'] = 'synthesis'
            thiscfg['iq']   = i
            thiscfg['dac']  = iq['dac']

            self['synthesis'].append(thiscfg)


    def ana_set_mixer_freq(self, ana_ch, f):
        self.pfbs_in[ana_ch].set_mixer_freq(f)

    def ana_get_mixer_freq(self, ana_ch):
        return self.pfbs_in[ana_ch].get_mixer_freq()

    def ana_get_data_adc(self, ana_ch, verbose=False):
        return self.pfbs_in[ana_ch].get_data_adc(verbose)

    def ana_get_bin_pfb(self, ana_ch, f, verbose=False):
        return self.pfbs_in[ana_ch].get_bin_pfb(f, verbose)

    def ana_get_bin_xfft(self, ana_ch, f, verbose=False):
        return self.pfbs_in[ana_ch].get_bin_xfft(f, verbose)

    def ana_get_data_acc(self, ana_ch, N=1, verbose=False):
        return self.pfbs_in[ana_ch].get_data_acc(N, verbose)

    def ana_get_data_acc_zoom(self, ana_ch, N=1, verbose=False):
        return self.pfbs_in[ana_ch].get_data_acc_zoom(N, verbose)

    def ana_freq2ch(self, ana_ch, f):
        # Sanity check: is frequency on allowed range?
        pfb = self.pfbs_in[ana_ch]
        fmix = abs(pfb.get_mixer_freq())
        fs = pfb.dict['freq']['fs']

        if abs(f-fmix) > fs/2:
            raise ValueError("Frequency value %f out of allowed range [%f,%f]" % (f,fmix-fs/2,fmix+fs/2))
        f_ = f - fmix
        return self.pfbs_in[ana_ch].freq2ch(f_)

    def ana_ch2freq(self, ana_ch, ch):
        # Mixer frequency.
        pfb = self.pfbs_in[ana_ch]
        fmix = abs(pfb.get_mixer_freq())
        f = pfb.ch2freq(ch)

        return f+fmix

    def ana_qout(self, ana_ch, q):
        self.pfbs_in[ana_ch].qout(q)
