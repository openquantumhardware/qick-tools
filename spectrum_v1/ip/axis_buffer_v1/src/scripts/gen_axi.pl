#!/usr/bin/perl

# Hash for storing all interfases.
%hash = ();

# Block name.
$top_name = "axis_averager";

# AXI-Lite Master.
#$name = "s0_axi";
#$hash{$name}{type} = "axi_lite_master";
#$hash{$name}{params}{ADDR_WIDTH}{type}	= "Integer";
#$hash{$name}{params}{ADDR_WIDTH}{value} = 32;
#$hash{$name}{params}{DATA_WIDTH}{type}	= "Integer";
#$hash{$name}{params}{DATA_WIDTH}{value} = 32;

# AXI-Lite Slave.
$name = "s_axi";
$hash{$name}{type} = "axi_lite_slave";
$hash{$name}{params}{ADDR_WIDTH}{type}	= "Integer";
$hash{$name}{params}{ADDR_WIDTH}{value} = 64;
$hash{$name}{params}{DATA_WIDTH}{type}	= "Integer";
$hash{$name}{params}{DATA_WIDTH}{value} = 64;

# AXI Master.
#$name = "m_axi";
#$hash{$name}{type} = "axi_master";
#$hash{$name}{params}{TARGET_SLAVE_BASE_ADDR}{type}	= "std_logic_vector";
#$hash{$name}{params}{TARGET_SLAVE_BASE_ADDR}{value} = "x\"40000000\"";
#$hash{$name}{params}{ADDR_WIDTH}{type}				= "Integer";
#$hash{$name}{params}{ADDR_WIDTH}{value} 			= 64;
#$hash{$name}{params}{DATA_WIDTH}{type}				= "Integer";
#$hash{$name}{params}{DATA_WIDTH}{value} 			= 64;
#$hash{$name}{params}{ID_WIDTH}{type}				= "Integer";
#$hash{$name}{params}{ID_WIDTH}{value} 				= 1;

# AXIS Master.
$name = "m_axis";
$hash{$name}{type} = "axis_master";
$hash{$name}{params}{DATA_WIDTH}{type}	= "Integer";
$hash{$name}{params}{DATA_WIDTH}{value} = 16;

# AXIS Slave.
$name = "s_axis";
$hash{$name}{type} = "axis_slave";
$hash{$name}{params}{DATA_WIDTH}{type}	= "Integer";
$hash{$name}{params}{DATA_WIDTH}{value} = 32;

#################
### Libraries ###
#################
print "library IEEE;\n";
print "use IEEE.STD_LOGIC_1164.ALL;\n";
print "use IEEE.NUMERIC_STD.ALL;\n";
print "\n";

##############
### Entity ###
##############
print "entity $top_name is\n";

################
### Generics ###
################
print "\tGeneric\n";
print "\t(\n";
@ifs = sort keys %hash;
if (@ifs)
{
	foreach (@ifs)
	{
		$if = $_;
		
		print "\t\t-- Parameters of $if I/F.\n";
		# Generics.
		@params = sort keys %{$hash{$if}{params}};
		if (@params)
		{
			foreach (@params)
			{
				$name = uc($if) . "_" . $_;
				$type = $hash{$if}{params}{$_}{type};
				$val = $hash{$if}{params}{$_}{value};
				print "\t\t$name : Integer := $val;\n";				
			}
			print "\n";
		}
	}
}
print "\t);\n";

#############
### Ports ###
#############
print "\tPort\n";
print "\t(\n";
@ifs = sort keys %hash;
if (@ifs)
{
	foreach (@ifs)
	{
		$if = $_;
		$type = $hash{$if}{type};
		
		#######################
		### AXI-Lite Master ###
		#######################
		if ($type eq "axi_lite_master")
		{
			# Ports.
			print "\t\t-- AXI-Lite Master I/F.\n";

			print"\t\t$if\_aclk\t : in std_logic;\n";
			print"\t\t$if\_aresetn\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"ADDR_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ADDR_WIDTH";
				print"\t\t$if\_awaddr\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_awaddr\t : out std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_awprot\t : out std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_awvalid\t : out std_logic;\n";
			print"\t\t$if\_awready\t : in std_logic;\n";

			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_wdata\t : out std_logic_vector($name-1 downto 0);\n";
				print"\t\t$if\_wstrb\t : out std_logic_vector($name/8-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_wdata\t : out std_logic_vector(31 downto 0);\n";
				print"\t\t$if\_wstrb\t : out std_logic_vector(3 downto 0);\n";
			}
			print"\t\t$if\_wvalid\t : out std_logic;\n";
			print"\t\t$if\_wready\t : in std_logic;\n";
			print "\n";

			print"\t\t$if\_bresp\t : in std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_bvalid\t : in std_logic;\n";
			print"\t\t$if\_bready\t : out std_logic;\n";
			print "\n";

			$p = &param_find($if,"ADDR_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ADDR_WIDTH";
				print"\t\t$if\_araddr\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_araddr\t : out std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_arprot\t : out std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_arvalid\t : out std_logic;\n";
			print"\t\t$if\_arready\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_rdata\t : in std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_rdata\t : in std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_rresp\t : in std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_rvalid\t : in std_logic;\n";
			print"\t\t$if\_rready\t : out std_logic;\n";
			print "\n";
		}

		######################
		### AXI-Lite Slave ###
		######################
		if ($type eq "axi_lite_slave")
		{
			# Ports.
			print "\t\t-- AXI-Lite Slave I/F.\n";

			print"\t\t$if\_aclk\t : in std_logic;\n";
			print"\t\t$if\_aresetn\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"ADDR_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ADDR_WIDTH";
				print"\t\t$if\_awaddr\t : in std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_awaddr\t : in std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_awprot\t : in std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_awvalid\t : in std_logic;\n";
			print"\t\t$if\_awready\t : out std_logic;\n";

			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_wdata\t : in std_logic_vector($name-1 downto 0);\n";
				print"\t\t$if\_wstrb\t : in std_logic_vector($name/8-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_wdata\t : in std_logic_vector(31 downto 0);\n";
				print"\t\t$if\_wstrb\t : in std_logic_vector(3 downto 0);\n";
			}
			print"\t\t$if\_wvalid\t : in std_logic;\n";
			print"\t\t$if\_wready\t : out std_logic;\n";
			print "\n";

			print"\t\t$if\_bresp\t : out std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_bvalid\t : out std_logic;\n";
			print"\t\t$if\_bready\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"ADDR_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ADDR_WIDTH";
				print"\t\t$if\_araddr\t : in std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_araddr\t : in std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_arprot\t : in std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_arvalid\t : in std_logic;\n";
			print"\t\t$if\_arready\t : out std_logic;\n";
			print "\n";

			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_rdata\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_rdata\t : out std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_rresp\t : out std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_rvalid\t : out std_logic;\n";
			print"\t\t$if\_rready\t : in std_logic;\n";
			print "\n";
		}


		##################
		### AXI Master ###
		##################
		if ($type eq "axi_master")
		{
			# Ports.
			print "\t\t-- AXI Master I/F.\n";

			print"\t\t$if\_aclk\t : in std_logic;\n";
			print"\t\t$if\_aresetn\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"ID_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ID_WIDTH";
				print"\t\t$if\_awid\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_awid\t : out std_logic_vector(0 downto 0);\n";
			}
			$p = &param_find($if,"ADDR_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ADDR_WIDTH";
				print"\t\t$if\_awaddr\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_awaddr\t : out std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_awlen\t : out std_logic_vector(7 downto 0);\n";
			print"\t\t$if\_awsize\t : out std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_awburst\t : out std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_awlock\t : out std_logic;\n";
			print"\t\t$if\_awcache\t : out std_logic_vector(3 downto 0);\n";
			print"\t\t$if\_awprot\t : out std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_awregion\t : out std_logic_vector(3 downto 0);\n";
			print"\t\t$if\_awqos\t : out std_logic_vector(3 downto 0);\n";
			print"\t\t$if\_awvalid\t : out std_logic;\n";
			print"\t\t$if\_awready\t : in std_logic;\n";

			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_wdata\t : out std_logic_vector($name-1 downto 0);\n";
				print"\t\t$if\_wstrb\t : out std_logic_vector($name/8-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_wdata\t : out std_logic_vector(31 downto 0);\n";
				print"\t\t$if\_wstrb\t : out std_logic_vector(3 downto 0);\n";
			}
			print"\t\t$if\_wvalid\t : out std_logic;\n";
			print"\t\t$if\_wready\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"ID_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ID_WIDTH";
				print"\t\t$if\_bid\t : in std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_bid\t : in std_logic_vector(0 downto 0);\n";
			}
			print"\t\t$if\_bresp\t : in std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_bvalid\t : in std_logic;\n";
			print"\t\t$if\_bready\t : out std_logic;\n";
			print "\n";

			$p = &param_find($if,"ID_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ID_WIDTH";
				print"\t\t$if\_arid\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_arid\t : out std_logic_vector(0 downto 0);\n";
			}
			$p = &param_find($if,"ADDR_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ADDR_WIDTH";
				print"\t\t$if\_araddr\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_araddr\t : out std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_arlen\t : out std_logic_vector(7 downto 0);\n";
			print"\t\t$if\_arsize\t : out std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_arburst\t : out std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_arlock\t : out std_logic;\n";
			print"\t\t$if\_arcache\t : out std_logic_vector(3 downto 0);\n";
			print"\t\t$if\_arprot\t : out std_logic_vector(2 downto 0);\n";
			print"\t\t$if\_arregion\t : out std_logic_vector(3 downto 0);\n";
			print"\t\t$if\_arqos\t : out std_logic_vector(3 downto 0);\n";
			print"\t\t$if\_arvalid\t : out std_logic;\n";
			print"\t\t$if\_arready\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"ID_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_ID_WIDTH";
				print"\t\t$if\_rid\t : out std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_rid\t : out std_logic_vector(0 downto 0);\n";
			}
			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_rdata\t : in std_logic_vector($name-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_rdata\t : in std_logic_vector(31 downto 0);\n";
			}
			print"\t\t$if\_rresp\t : in std_logic_vector(1 downto 0);\n";
			print"\t\t$if\_rlast\t : in std_logic;\n";
			print"\t\t$if\_rvalid\t : in std_logic;\n";
			print"\t\t$if\_rready\t : out std_logic;\n";
			print "\n";
		}


		###################
		### AXIS Master ###
		###################
		if ($type eq "axis_master")
		{
			# Ports.
			print "\t\t-- AXIS Master I/F.\n";

			print"\t\t$if\_aclk\t : in std_logic;\n";
			print"\t\t$if\_aresetn\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_tdata\t : out std_logic_vector($name-1 downto 0);\n";
				print"\t\t$if\_tstrb\t : out std_logic_vector($name/8-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_tdata\t : out std_logic_vector(31 downto 0);\n";
				print"\t\t$if\_tstrb\t : out std_logic_vector(3 downto 0);\n";
			}
			print"\t\t$if\_tlast\t : out std_logic;\n";
			print"\t\t$if\_tvalid\t : out std_logic;\n";
			print"\t\t$if\_tready\t : in std_logic;\n";
			print "\n";
		}

		##################
		### AXIS Slave ###
		##################
		if ($type eq "axis_slave")
		{
			# Ports.
			print "\t\t-- AXIS Slave I/F.\n";

			print"\t\t$if\_aclk\t : in std_logic;\n";
			print"\t\t$if\_aresetn\t : in std_logic;\n";
			print "\n";

			$p = &param_find($if,"DATA_WIDTH",@params);
			if ($p)
			{
				$name = uc($if) . "_DATA_WIDTH";
				print"\t\t$if\_tdata\t : in std_logic_vector($name-1 downto 0);\n";
				print"\t\t$if\_tstrb\t : in std_logic_vector($name/8-1 downto 0);\n";
			}
			else
			{
				print"\t\t$if\_tdata\t : in std_logic_vector(31 downto 0);\n";
				print"\t\t$if\_tstrb\t : in std_logic_vector(3 downto 0);\n";
			}
			print"\t\t$if\_tlast\t : in std_logic;\n";
			print"\t\t$if\_tvalid\t : in std_logic;\n";
			print"\t\t$if\_tready\t : out std_logic;\n";
			print "\n";
		}
	}
}
print "\t);\n";
print "end $top_name;\n";
print "\n";

####################
### Architecture ###
####################
print "architecture rtl of $top_name is\n";
print "\n";
print "begin\n";
print "\n";
print "end rtl;\n";
print "\n";

####################
### Sub-routines ###
####################
sub param_find
{
	my ($if, $p, @a) = @_;

	foreach (@a)
	{
		if ($_ eq $p)
		{
			return $hash{$if}{params}{$p};
		}
	}

	return 0;
}
