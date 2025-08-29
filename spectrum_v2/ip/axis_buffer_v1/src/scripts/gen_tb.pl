#!/usr/bin/perl

# Hash for storing structure.
%hash = ();

#################
### Parse DUT ###
#################
my $file = $ARGV[0];
open(FD, "<", $file) or die "Can't open $file: $!";
@lines = <FD>;
close(FD);

&parse_entity(\%hash, \@lines);


#################
### Parse VIP ###
#################
@dirs = `find . -maxdepth 1 -name "axi*" -type d`;
foreach (@dirs)
{
	chomp ($_);

	# AXI Slave.
	if ($_ =~ m/(axi_slv_\d+)/)
	{
		$name = $1;
		$file = $_ . "/" . $name . ".vho";

		open(FD, "<", $file) or die "Can't open $file: $!";
		@lines = <FD>;
		close(FD);

		&parse_component(\%hash, \@lines);
	}

	# AXI Master.
	if ($_ =~ m/(axi_mst_\d+)/)
	{
		$name = $1;
		$file = $_ . "/" . $name . ".vho";

		open(FD, "<", $file) or die "Can't open $file: $!";
		@lines = <FD>;
		close(FD);

		&parse_component(\%hash, \@lines);
	}

	# AXIS Slave.
	if ($_ =~ m/(axis_slv_\d+)/)
	{
		$name = $1;
		$file = $_ . "/" . $name . ".vho";

		open(FD, "<", $file) or die "Can't open $file: $!";
		@lines = <FD>;
		close(FD);

		&parse_component(\%hash, \@lines);
	}

	# AXIS Master.
	if ($_ =~ m/(axis_mst_\d+)/)
	{
		$name = $1;
		$file = $_ . "/" . $name . ".vho";

		open(FD, "<", $file) or die "Can't open $file: $!";
		@lines = <FD>;
		close(FD);

		&parse_component(\%hash, \@lines);
	}
}

# Get DUT and VIPs.
my $dut;
my @vips;
foreach (sort keys %hash)
{
	$b = $_;
	$type = $hash{$b}{type};
	
	if ($type eq "dut")
	{
		$dut = $b;
	}

	if ($type eq "vip")
	{
		push(@vips,$b);
	}
}

# Attempt auto assign IFs to VIPs.
foreach (sort keys %hash)
{
	$b = $_;
	$type = $hash{$b}{type};
	
	if ($type eq "dut")
	{
		@ifs = sort keys %{$hash{$b}{ifs}};
		foreach (@ifs)
		{
			# AXI Master.
			if ($_ =~ m/m(\d*)_axi$/)
			{
				# AXI Master->AXI Slave.
				if ($1 eq "")
				{
					$vip = axi_slv_0;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
				else
				{
					$vip = "axi_slv_" . $1;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
			}

			# AXI Slave.
			if ($_ =~ m/s(\d*)_axi$/)
			{
				# AXI Slave->AXI Master.
				if ($1 eq "")
				{
					$vip = axi_mst_0;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
				else
				{
					$vip = "axi_mst_" . $1;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
			}

			# AXIS Master.
			if ($_ =~ m/m(\d*)_axis$/)
			{
				# AXIS Master->AXIS Slave.
				if ($1 eq "")
				{
					$vip = axis_slv_0;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
				else
				{
					$vip = "axis_slv_" . $1;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
			}

			# AXIS Slave.
			if ($_ =~ m/s(\d*)_axis$/)
			{
				# AXIS Slave->AXIS Master.
				if ($1 eq "")
				{
					$vip = axis_mst_0;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
				else
				{
					$vip = "axis_mst_" . $1;
					$if = $_;
					foreach (@vips)
					{
						if ($_ eq $vip)
						{
							$hash{$b}{ifs}{$if}{assign} = $_;
							$hash{$vip}{assign} = $if;
						}
					}
				}
			}
		}
	}
}

####################
### Print blocks ###
####################
foreach (sort keys %hash)
{
	$b = $_;

	$type = $hash{$b}{type};
	
	if ($type eq "dut")
	{
		print "// DUT: $b\n";
	}

	if ($type eq "vip")
	{
		print "// VIP: $b\n";
	}


	@ifs = sort keys %{$hash{$b}{ifs}};
	foreach (@ifs)
	{
		$assign = $hash{$b}{ifs}{$_}{assign};
		print "// \tIF: $_ -> $assign\n";
	}
}
print "\n";

########################
### Build test bench ###
########################
# Packages.
print "import axi_vip_pkg::*;\n";
print "import axi4stream_vip_pkg::*;\n";
foreach (@vips)
{
	print "import $_\_pkg::*;\n";
}

print "\n";
print "module tb();\n";
print "\n";

# Constant parameters.
@a = sort keys %{$hash{$dut}{generic}};
if (@a)
{
	print "// DUT generics.\n";
	foreach (@a)
	{
		$val = $hash{$dut}{generic}{$_}{value};
		$_ =~ s/\s+//g;
		$_ =~ s/;+//g;
		$val =~ s/\s+//g;
		$val =~ s/;+//g;
		print "parameter $_ = $val;\n";
	}
}
print "\n";

# Signals.
# DUT Ports.
@a = sort keys %{$hash{$dut}{port}};

if (@a)
{
	print "// DUT ports.\n";
	foreach (@a)
	{
		$name = $_;
		$type = $hash{$dut}{port}{$_}{type};
		$type =~ s/\s+//g;

		# std_logic;
		if ($type =~ m/std_logic;{0,1}/)
		{
			$name =~ s/\s+//g;
			print "wire\t\t$name;\n";
		}

		# std_logic_vector(#downto#);
		if ($type =~ m/std_logic_vector\((\d+)downto(\d+)\);/)
		{
			$from = $1;
			$to = $2;
			$name =~ s/\s+//g;
			print "wire [$from:$to]\t$name;\n";
		}

		# std_logic_vector(VARdownto#);
		elsif ($type =~ m/std_logic_vector\((.+)downto(\d+)\);/)
		{
			$from = $1;
			$to = $2;
			$name =~ s/\s+//g;
			print "wire [$from:$to]\t$name;\n";
		}
	}
	print "\n";
}

# DUT Interfases.
@ifs = sort keys %{$hash{$dut}{ifs}};
my @clocks;
my @resets;
foreach (@ifs)
{
	$if = $_;

	print "// $if interfase.\n";

	@p = sort keys %{$hash{$dut}{ifs}{$if}{ports}};
	foreach (@p)
	{
		$name = $_;
		$type = $hash{$dut}{ifs}{$if}{ports}{$name}{type};
		$type =~ s/\s+//g;

		# std_logic;
		if ($type =~ m/std_logic;/)
		{
			if ($name =~ m/aclk/)
			{
				$name =~ s/\s+//g;
				print "reg\t\t$name;\n";

				# Add to array.
				push(@clocks,$name);
			}
			elsif ($name =~ m/aresetn/)
			{
				$name =~ s/\s+//g;
				print "reg\t\t$name;\n";

				# Add to array.
				push(@resets,$name);
			}
			else
			{
				$name =~ s/\s+//g;
				print "wire\t\t$name;\n";
			}
		}

		# std_logic_vector(#downto#);
		if ($type =~ m/std_logic_vector\((\d+)downto(\d+)\);/)
		{
			$from = $1;
			$to = $2;
			$name =~ s/\s+//g;
			print "wire [$from:$to]\t$name;\n";
		}

		# std_logic_vector(VARdownto#);
		elsif ($type =~ m/std_logic_vector\((.+)downto(\d+)\);/)
		{
			$from = $1;
			$to = $2;
			$name =~ s/\s+//g;
			print "wire [$from:$to]\t$name;\n";
		}
	}

	print "\n";
}

# Instantiate blocks.
foreach (sort keys %hash)
{
	$b = $_;

	$inst = $b . "_i";

	$hash{$b}{instance} = $inst;

	
	# Generics.
	@a = sort keys %{$hash{$b}{generic}};	
	if (@a)
	{
		print "$b\n";
		print "\t#(\n";
		foreach (@a)
		{
			$_ =~ s/\s*//g;
			print "\t\t.$_($_),\n";	
		}
		print "\t)\n";
		print "\t$inst\n";
	}
	else
	{
		print "$b $inst\n";
	}


	print "\t(\n";

	# IFs.
	@a = sort keys %{$hash{$b}{ifs}};	
	if (@a)
	{
		foreach (@a)
		{
			print "\t\t// $_ interfase.\n";
			@p = sort keys%{$hash{$b}{ifs}{$_}{ports}};
			foreach (@p)
			{
				$_ =~ s/\s*//g;
				print "\t\t.$_($_),\n";	
			}
			print "\n";
		}
	}

	# Ports.
	@a = sort keys %{$hash{$b}{port}};	
	if (@a)
	{
		$_ =~ s/\s*//g;
		foreach (@a)
		{
			if ($hash{$b}{type} eq "vip")
			{
				my $port = $_;
				my $name = $_;
				my $if = $hash{$b}{assign};
				my @if_ports = sort keys %{$hash{$dut}{ifs}{$if}{ports}};
				$name =~ s/m_axi_//g;	
				$name =~ s/s_axi_//g;	
				$name =~ s/m_axis_//g;	
				$name =~ s/s_axis_//g;	

				# Search port.
				my $found = 0;
				foreach (@if_ports)
				{	
					if ($_ =~ m/_$name/)
					{
						$found = 1;
						$_ =~ s/\s*//g;
						print "\t\t.$port($_),\n";	
					}
				}

				# If port is not found in IF, leave it unconnected.
				if (!$found)
				{
					print "\t\t.$port(),\n";
				}

			}
			else
			{
				$_ =~ s/\s*//g;
				print "\t\t.$_($_),\n";	
			}
		}
	}

	print "\t);\n";
	print "\n";
}

# VIP Agents.
print "// VIP Agents\n";
foreach (@vips)
{
	if ($_ =~ m/axi_mst/)
	{
		$t = $_ . "_mst_t";
		$n = $_ . "_agent";
		print "$t $n;\n";

		# Add agent to hash for later use.
		$hash{$_}{agent} = $n;
	}
	if ($_ =~ m/axi_slv/)
	{
		$t1 = $_ . "_slv_t";
		$t2 = $_ . "_slv_mem_t";
		$n = $_ . "_agent";
		#print "//$t1 $n;\n";
		print "$t2 $n;\n";

		# Add agent to hash for later use.
		$hash{$_}{agent} = $n;
	}
	if ($_ =~ m/axis_mst/)
	{
		$t = $_ . "_mst_t";
		$n = $_ . "_agent";
		print "$t $n;\n";

		# Add agent to hash for later use.
		$hash{$_}{agent} = $n;
	}
	if ($_ =~ m/axis_slv/)
	{
		$t = $_ . "_slv_t";
		$n = $_ . "_agent";
		print "$t $n;\n";

		# Add agent to hash for later use.
		$hash{$_}{agent} = $n;
	}
}
print "\n";

# Main test bench.
print "initial begin\n";
print "\t// Create agents.\n";
foreach (@vips)
{
	$agent = $hash{$_}{agent};
	$inst = $hash{$_}{instance};
	$tb = "tb." . $inst . ".inst.IF";
	print "\t$agent = new(\"$_ VIP Agent\",$tb);\n";	
}
print "\n";

print "\t// Set tag for agents.\n";
foreach (@vips)
{
	$agent = $hash{$_}{agent};
	print "\t$agent.set_agent_tag(\"$_ VIP\");\n";	
}
print "\n";

print "\t// Drive everything to 0 to avoid assertion from axi_protocol_checker.\n";
foreach (@vips)
{
	$agent = $hash{$_}{agent};
	if ($_ =~ m/axis/)
	{
		print "\t$agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);\n";	
	}
}
print "\n";

print "\t// Start agents.\n";
foreach (@vips)
{
	$agent = $hash{$_}{agent};
	if ($_ =~ m/mst/)
	{
		print "\t$agent.start_master();\n";	
	}
	if ($_ =~ m/slv/)
	{
		print "\t$agent.start_slave();\n";	
	}
}
print "\n";

# Resets.
print "\t// Reset sequence.\n";
foreach (@resets)
{
	print "\t$_ <= 0;\n";
}
print "\t#500;\n";
foreach (@resets)
{
	print "\t$_ <= 1;\n";
}
print "\n";
print "end\n";
print "\n";

# Clocks.
foreach (@clocks)
{
	print "always begin\n";
	print "\t$_ <= 0;\n";
	print "\t#10;\n";
	print "\t$_ <= 1;\n";
	print "\t#10;\n";
	print "end\n";
	print "\n";
}

print "endmodule\n";
print "\n";

####################
### Sub Routines ###
####################
sub parse_entity
{
	my ($hash_ref, $array_ref) = @_;
	my @lines = @$array_ref;

	my $entity = "";
	my $generic_flag = 0;
	my $port_flag = 0;
	foreach (@lines)
	{
		chomp ($_);
	
		# Start entity.
		if ($_ =~ m/^\s*entity\s+(.+)\s+is/)
		{
			$entity = $1;
			$$hash_ref{$entity}{type} = "dut";
		}
	
		# Start generic.
		if ($_ =~ m/^\s*generic/i)
		{
			$generic_flag = 1;	
		}
	
		# Start port.
		if ($_ =~ m/^\s*port/i)
		{
			$port_flag = 1;	
		}
	
		# Generic is first.
		if ($generic_flag)
		{
			if ($_ =~ m/^\s*\(/)
			{
				# The "(" on a single line.
			}
			elsif ($_ =~ m/^\s*-+/)
			{
				# Comment "--" line.
			}
			elsif ($_ =~ m/^\s*(.+)\s:(.+)\s+:=(.+);{0,1}/)
			{
				$$hash_ref{$entity}{generic}{$1}{type} = $2;
				$$hash_ref{$entity}{generic}{$1}{value} = $3;
			}	
			elsif ($_ =~ m/^\s*\);/)
			{
				$generic_flag = 0;
			}
		}
	
		# Port is second.
		if ($port_flag)
		{
			if ($_ =~ m/^\s*\(/)
			{
				# The "(" on a single line.
			}
			elsif ($_ =~ m/^\s*-+/)
			{
				# Comment "--" line.
			}
			elsif ($_ =~ m/^\s*(.+)\s:\s+(in|out)\s+(.+);{0,1}/i)
			{
				$name = $1;
				$dir = $2;
				$type = $3;
				
				# AXI Slave I/F.
				if ($name =~ /(s\d*_axi)_/)
				{
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{dir} = $dir;	
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{type} = $type;	
					$$hash_ref{$entity}{ifs}{$1}{assign} = "empty";
				}
	
				# AXI Master I/F.
				elsif ($name =~ /(m\d*_axi)_/)
				{
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{dir} = $dir;	
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{type} = $type;	
					$$hash_ref{$entity}{ifs}{$1}{assign} = "empty";
				}
	
				# AXIS Slave I/F.
				elsif ($name =~ /(s\d*_axis)_/)
				{
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{dir} = $dir;	
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{type} = $type;	
					$$hash_ref{$entity}{ifs}{$1}{assign} = "empty";
				}
	
				# AXIS Master I/F.
				elsif ($name =~ /(m\d*_axis)_/)
				{
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{dir} = $dir;	
					$$hash_ref{$entity}{ifs}{$1}{ports}{$name}{type} = $type;	
					$$hash_ref{$entity}{ifs}{$1}{assign} = "empty";
				}
	
				# Generic port.
				else
				{
					$$hash_ref{$entity}{port}{$name}{direction} = $dir;
					$$hash_ref{$entity}{port}{$name}{type} = $type;
				}
			}	
			elsif ($_ =~ m/^\s*\);/)
			{
				$port_flag = 0;
			}
		}
	
		if ($_ =~ m/^\s*end\s+$entity/i)
		{
			last;
		}
	}
}

sub parse_component
{
	my ($hash_ref, $array_ref) = @_;
	my @lines = @$array_ref;

	my $entity = "";
	my $generic_flag = 0;
	my $port_flag = 0;
	foreach (@lines)
	{
		chomp ($_);
	
		# Start entity.
		if ($_ =~ m/^\s*component\s+(.+)/i)
		{
			$entity = $1;
			$$hash_ref{$entity}{type} = "vip";
		}
	
		# Start generic.
		if ($_ =~ m/^\s*generic/i)
		{
			$generic_flag = 1;	
		}
	
		# Start port.
		if ($_ =~ m/^\s*port/i)
		{
			$port_flag = 1;	
		}
	
		# Generic is first.
		if ($generic_flag)
		{
			if ($_ =~ m/^\s*\(/)
			{
				# The "(" on a single line.
			}
			elsif ($_ =~ m/^\s*-+/)
			{
				# Comment "--" line.
			}
			elsif ($_ =~ m/^\s*(.+)\s:(.+)\s+:=(.+);{0,1}/)
			{
				$$hash_ref{$entity}{generic}{$1}{type} = $2;
				$$hash_ref{$entity}{generic}{$1}{value} = $3;
			}	
			elsif ($_ =~ m/^\s*\);/)
			{
				$generic_flag = 0;
			}
		}
	
		# Port is second.
		if ($port_flag)
		{
			if ($_ =~ m/^\s*\(/)
			{
				# The "(" on a single line.
			}
			elsif ($_ =~ m/^\s*-+/)
			{
				# Comment "--" line.
			}
			elsif ($_ =~ m/^\s*(.+)\s:\s+(in|out)\s+(.+);{0,1}/i)
			{
				$name = $1;
				$dir = $2;
				$type = $3;
				
				# Generic port.
				$$hash_ref{$entity}{port}{$name}{direction} = $dir;
				$$hash_ref{$entity}{port}{$name}{type} = $type;
			}	
			elsif ($_ =~ m/^\s*\);/)
			{
				$port_flag = 0;
			}
		}
	
		if ($_ =~ m/^\s*end\s+component/i)
		{
			last;
		}
	}
}
