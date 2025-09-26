from qick import QickSoc

from pfb import *
from misc import *

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
