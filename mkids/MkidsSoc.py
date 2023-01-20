import os, sys
from pathlib import Path

class MkidsSoc():
    def __init__(self, bitFileName=None, ignore_version=True, force_init_clks=True):
        self.board = os.environ["BOARD"]
        if self.board == 'ZCU111':
            temp = str(Path(Path(__file__).parent.parent,"mkids_111_4x4096"))
            sys.path.append(temp)
            import mkids_4x4096_v4
            sys.path.remove(temp)
            if bitFileName is None:
                bitFileName = temp+'/mkids_4x4096_v4.bit'
            self._soc = mkids_4x4096_v4.TopSoc(bitFileName, 
                                              ignore_version=ignore_version, 
                                              force_init_clks=force_init_clks)
            
            self.multiTile = self._soc.dacs['12']['tile']
            self.multiBlock  = self._soc.dacs['12']['block']
            self.multiFc = (self._soc.dacs['12']['fs']/4)/self._soc.pfb_out.N
            self.fs_adc = self._soc.adcs['00']['fs']
            self.fsIn = self.fs_adc/2 # Hardwired x2 decimation in ADC
        elif self.board == 'ZCU216':
            temp = str(Path(Path(__file__).parent.parent,"mkids_216_4x1024"))
            sys.path.append(temp)
            import mkids_4x1024
            sys.path.remove(temp)
            if bitFileName is None:
                bitFileName = temp+'/mkids_4x1024.bit'
            self._soc = mkids_4x1024.TopSoc(bitFileName, 
                                              ignore_version=ignore_version, 
                                              force_init_clks=force_init_clks)
            
            self.multiTile = self._soc.dacs['20']['tile']
            self.multiBlock  = self._soc.dacs['20']['block']
            self.multiFc = (self._soc.dacs['20']['fs']/4)/self._soc.pfb_out.N
            self.fs_adc = self._soc.adcs['20']['fs']
            self.fsIn = self.fs_adc/2 # Hardwired x2 decimation in ADC
        else:
            raise Exception("%s is not (yet) supported"%self.board)

