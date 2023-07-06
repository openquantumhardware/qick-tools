# qick-tools

Use the qick library to build various tools.

Look inside the zcu111 for some generic instruments for spectrum analysis.

mkids_v2 uses a modular approach to mkids firmware and software.  Once loaded,
firmware can report the availability of:

* Synthesis chains: the DAC channel(s) available to generate tones

* Analysis chains:  the ADC channel(s) available to read signals 

* Dual chain:  A DAC&ADC pair that share a common digital mixer.  This is a combination of a "Synthesis chain" and an "Analyis chain", with additional logic that allows control and read out MKIDs detectors.

* Sim chain:  A DAC&ADC pair that share a common digital mixer.  This is a combination of a "Synthesis chain" and an "Analyis chain", with additional logic that simulates resonators.

