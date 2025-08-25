# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXIS_IN_DW" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "AXIS_OUT_DW" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "IQ_FORMAT" -parent ${Page_0}
  #Adding Group
  set Memory [ipgui::add_group $IPINST -name "Memory" -parent ${Page_0}]
  set MEM_DW [ipgui::add_param $IPINST -name "MEM_DW" -parent ${Memory}]
  set_property tooltip {URAM Memory Data Width} ${MEM_DW}
  set MEM_PIPE [ipgui::add_param $IPINST -name "MEM_PIPE" -parent ${Memory}]
  set_property tooltip {Stages of Pipeline in URAM} ${MEM_PIPE}
  set BANK_ARRAY_AW [ipgui::add_param $IPINST -name "BANK_ARRAY_AW" -parent ${Memory}]
  set_property tooltip {Bits used to Address BANKS (Number of Inputs)} ${BANK_ARRAY_AW}
  ipgui::add_static_text $IPINST -name "MEM_TEXT" -parent ${Memory} -text {The Number of Memory Banks is equal to the number of paralel inputs in the AXI-Stream}

  #Adding Group
  set FFT [ipgui::add_group $IPINST -name "FFT" -parent ${Page_0}]
  ipgui::add_static_text $IPINST -name "FFT_TEXT" -parent ${FFT} -text {The FFT ADDR_WIDTH is used to calculate the amount of BINS}
  ipgui::add_param $IPINST -name "FFT_AW" -parent ${FFT}
  ipgui::add_static_text $IPINST -name "FFTAWTEXT" -parent ${FFT} -text {16 = 65536
15 = 32768
10 = 1024
 4 = 16  
}
  set FFT_STORE [ipgui::add_param $IPINST -name "FFT_STORE" -parent ${FFT} -widget checkBox]
  set_property tooltip {Store Half Bins> If checked only the centered bins will be stored in memory.} ${FFT_STORE}



}

proc update_PARAM_VALUE.AXIS_IN_DW { PARAM_VALUE.AXIS_IN_DW } {
	# Procedure called to update AXIS_IN_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_IN_DW { PARAM_VALUE.AXIS_IN_DW } {
	# Procedure called to validate AXIS_IN_DW
	return true
}

proc update_PARAM_VALUE.AXIS_OUT_DW { PARAM_VALUE.AXIS_OUT_DW } {
	# Procedure called to update AXIS_OUT_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_OUT_DW { PARAM_VALUE.AXIS_OUT_DW } {
	# Procedure called to validate AXIS_OUT_DW
	return true
}

proc update_PARAM_VALUE.BANK_ARRAY_AW { PARAM_VALUE.BANK_ARRAY_AW } {
	# Procedure called to update BANK_ARRAY_AW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BANK_ARRAY_AW { PARAM_VALUE.BANK_ARRAY_AW } {
	# Procedure called to validate BANK_ARRAY_AW
	return true
}

proc update_PARAM_VALUE.FFT_AW { PARAM_VALUE.FFT_AW } {
	# Procedure called to update FFT_AW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FFT_AW { PARAM_VALUE.FFT_AW } {
	# Procedure called to validate FFT_AW
	return true
}

proc update_PARAM_VALUE.FFT_STORE { PARAM_VALUE.FFT_STORE } {
	# Procedure called to update FFT_STORE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FFT_STORE { PARAM_VALUE.FFT_STORE } {
	# Procedure called to validate FFT_STORE
	return true
}

proc update_PARAM_VALUE.IQ_FORMAT { PARAM_VALUE.IQ_FORMAT } {
	# Procedure called to update IQ_FORMAT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IQ_FORMAT { PARAM_VALUE.IQ_FORMAT } {
	# Procedure called to validate IQ_FORMAT
	return true
}

proc update_PARAM_VALUE.MEM_DW { PARAM_VALUE.MEM_DW } {
	# Procedure called to update MEM_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_DW { PARAM_VALUE.MEM_DW } {
	# Procedure called to validate MEM_DW
	return true
}

proc update_PARAM_VALUE.MEM_PIPE { PARAM_VALUE.MEM_PIPE } {
	# Procedure called to update MEM_PIPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_PIPE { PARAM_VALUE.MEM_PIPE } {
	# Procedure called to validate MEM_PIPE
	return true
}


proc update_MODELPARAM_VALUE.AXIS_IN_DW { MODELPARAM_VALUE.AXIS_IN_DW PARAM_VALUE.AXIS_IN_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_IN_DW}] ${MODELPARAM_VALUE.AXIS_IN_DW}
}

proc update_MODELPARAM_VALUE.AXIS_OUT_DW { MODELPARAM_VALUE.AXIS_OUT_DW PARAM_VALUE.AXIS_OUT_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_OUT_DW}] ${MODELPARAM_VALUE.AXIS_OUT_DW}
}

proc update_MODELPARAM_VALUE.FFT_AW { MODELPARAM_VALUE.FFT_AW PARAM_VALUE.FFT_AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FFT_AW}] ${MODELPARAM_VALUE.FFT_AW}
}

proc update_MODELPARAM_VALUE.BANK_ARRAY_AW { MODELPARAM_VALUE.BANK_ARRAY_AW PARAM_VALUE.BANK_ARRAY_AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BANK_ARRAY_AW}] ${MODELPARAM_VALUE.BANK_ARRAY_AW}
}

proc update_MODELPARAM_VALUE.MEM_DW { MODELPARAM_VALUE.MEM_DW PARAM_VALUE.MEM_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_DW}] ${MODELPARAM_VALUE.MEM_DW}
}

proc update_MODELPARAM_VALUE.MEM_PIPE { MODELPARAM_VALUE.MEM_PIPE PARAM_VALUE.MEM_PIPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_PIPE}] ${MODELPARAM_VALUE.MEM_PIPE}
}

proc update_MODELPARAM_VALUE.FFT_STORE { MODELPARAM_VALUE.FFT_STORE PARAM_VALUE.FFT_STORE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FFT_STORE}] ${MODELPARAM_VALUE.FFT_STORE}
}

proc update_MODELPARAM_VALUE.IQ_FORMAT { MODELPARAM_VALUE.IQ_FORMAT PARAM_VALUE.IQ_FORMAT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IQ_FORMAT}] ${MODELPARAM_VALUE.IQ_FORMAT}
}

