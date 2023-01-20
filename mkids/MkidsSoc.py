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
