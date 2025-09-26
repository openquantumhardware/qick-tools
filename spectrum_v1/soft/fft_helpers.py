import numpy as np

def findPeak(x,y,xmin=-1,xmax=-1):
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
        #if not isinstance(soc, SpectrumSoc):
        #    raise RuntimeError("%s (SpectrumSoc, SynthesisChain)" % __class__.__name__)

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
        #if not isinstance(soc, SpectrumSoc):
        #    raise RuntimeError("%s (SpectrumSoc, Analysischain, SynthesisChain)" % __class__.__name__)

        # Analsis and Synthesis chains.
        self.analysis   = AnalysisChain(soc, analysis)
        self.synthesis  = SynthesisChain(soc, synthesis)

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

