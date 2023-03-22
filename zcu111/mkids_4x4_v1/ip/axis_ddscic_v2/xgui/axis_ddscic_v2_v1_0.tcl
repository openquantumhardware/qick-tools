# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "L"
  ipgui::add_param $IPINST -name "NCH"
  ipgui::add_param $IPINST -name "NPIPE_CIC"

}

proc update_PARAM_VALUE.L { PARAM_VALUE.L } {
	# Procedure called to update L when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.L { PARAM_VALUE.L } {
	# Procedure called to validate L
	return true
}

proc update_PARAM_VALUE.NCH { PARAM_VALUE.NCH } {
	# Procedure called to update NCH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NCH { PARAM_VALUE.NCH } {
	# Procedure called to validate NCH
	return true
}

proc update_PARAM_VALUE.NPIPE_CIC { PARAM_VALUE.NPIPE_CIC } {
	# Procedure called to update NPIPE_CIC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NPIPE_CIC { PARAM_VALUE.NPIPE_CIC } {
	# Procedure called to validate NPIPE_CIC
	return true
}


proc update_MODELPARAM_VALUE.L { MODELPARAM_VALUE.L PARAM_VALUE.L } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.L}] ${MODELPARAM_VALUE.L}
}

proc update_MODELPARAM_VALUE.NCH { MODELPARAM_VALUE.NCH PARAM_VALUE.NCH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NCH}] ${MODELPARAM_VALUE.NCH}
}

proc update_MODELPARAM_VALUE.NPIPE_CIC { MODELPARAM_VALUE.NPIPE_CIC PARAM_VALUE.NPIPE_CIC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NPIPE_CIC}] ${MODELPARAM_VALUE.NPIPE_CIC}
}

