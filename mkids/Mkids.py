import sys
import MkidsSoc
import numpy as np

class Mkids():
    def __init__(self, soc, decimation=2, streamLength=10000):
        self.soc = soc

        # Point to useful parts of the soc
        self.stream = self.soc._soc.stream
        self.pfb_in = self.soc._soc.pfb_in
        self.fsIn = self.soc.fsIn
        self.pfb_out = self.soc._soc.pfb_out
        self.fsOut = self.pfb_out.fs
        self.ddscic = self.soc._soc.ddscic
        self.chsel = self.soc._soc.chsel
        self.board = self.soc.board

        # Setup useful constants
        self.nInCh = self.pfb_in.N
        self.fcIn = self.pfb_in.get_fc()
        self.fbIn = self.pfb_in.get_fb()

        self.nOutCh = self.pfb_out.N
        self.fcOut = self.pfb_out.get_fc()
        self.fbOut = self.pfb_out.get_fb()
        #self.fcOut = self.fsOut/self.pfb_out.N
        #self.fbOut = self.fsOut/(self.pfb_out.N/2) # output channel bandwidth
        # Start streamer and set default transfer length.
        self.streamLength = streamLength
        self.stream.set_nsamp(streamLength)

        self.pfb_in.qout(8)
        self.setDecimate(decimation)
        
        # First Dummy transfer for DMA.
        self.chsel.set_single(0)
        self.stream.transfer_raw(first=True)
        self.chsel.alloff()

    def setDecimate(self, decimate):
        """
        Set the decimation value pfbcic values 
        
        Parameters
        ---------- 
        decimate : int
            decimation value, in the range [2,250]
            
        """
        self.ddscic.decimation(decimate)
        #self.setSwitchSrc(self.switchSrc)
        self.fb = self.fsIn/((self.pfb_in.N/2)*self.ddscic.get_decimate())
        self.time = self.streamLength/(self.fb*1e6) # In Seconds
        self.msecs = np.arange(self.streamLength)/(self.fb*1e3) # For plotting, in milli seconds

    def info(self, stream=sys.stdout):
        print("Board model: %s"%self.board, file=stream)
        print("Input:", file=stream)
        print("         number of input channels: %7d"%self.nInCh)
        print("         input sampling frequency: %7.2f MHz"%self.fsIn)
        print("  bandwidth of each input channel: %7.2f MHz"%self.fbIn)
        print("   spacing between input channels: %7.2f MHz"%self.fcIn)
        print("            total input bandwidth: %7.2f MHz"%(self.nInCh*self.fcIn))
        print("Output:", file=stream)
        print("        number of output channels: %7d"%self.nOutCh)
        print("        output sampling frequency: %7.2f MHz"%self.fsOut)
        print(" bandwidth of each output channel: %7.2f MHz"%self.fbOut)
        print("  spacing between output channels: %7.2f MHz"%self.fcOut)
        print("           total output bandwidth: %7.2f MHz"%(self.nOutCh*self.fcOut))
