from pathlib import Path
from mkids import *
import os
class Scan():
    def __init__(self, firmwareName):
        """
        Load and initialize the names firmware
        """
        board = getBoard()
        full_path = os.path.realpath(__file__)
        path, filename = os.path.split(full_path)
        bitpath = str(Path(path).parent.joinpath(Path(board), firmwareName+'.bit'))
        self.soc = MkidsSoc(bitpath)
    
def availableBitfiles():
    """
    Return a list of firmware names available. 
    """
    board = getBoard()
    full_path = os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    bitpath = Path(path).parent.joinpath(Path(board))
    retval = []
    for bitfile in bitpath.glob('*.bit'):
        retval.append(bitfile.stem)
    retval.sort()
    return retval

def getBoard():
    """
    Get the name of the board in use.  Note that this is 
    converted to all lowercase, and to work around the
    pynq3 feature that reports zcu208, replace this string
    to report zcu216.  
    """
    board = os.environ["BOARD"].lower().replace("208","216")
    return board
    
    