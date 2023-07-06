# mkids_v2

Software to use mkids firmware on all platforms.  Each instance of the firmware has different hardwired bandwidths, yet all are accessed with the same top level APIs.

Once loaded, firmware can report the availability of:

* Synthesis chains: the DAC channel(s) available to send signals

* Analysis chains:  the ADC channel(s) available to read signals 

* Dual chains:  A DAC&ADC pair that share a common digital mixer.  This is a combination of a "Synthesis chain" and an "Analysis chain", with additional logic that allows control and read out MKIDs detectors.

* Sim chains:  A DAC&ADC pair that share a common digital mixer.  This is a combination of a "Synthesis chain" and an "Analysis chain", with additional logic that simulates resonators.

Directories include:

# demos

Notebooks that demonstrate the use and functionality

# soft

Drivers and classes

# zcu216

Firmware (.bit and .hwh files) and a notebooke for each version of the firmware.
