module bram_dp
	#(
		parameter N = 16	,
		parameter B = 16
	)
	(
		input wire 			clka	,
		input wire 			ena		,
		input wire 			wea		,
		input wire [N-1:0]	addra	,
		input wire [B-1:0]	dia		,
		output wire [B-1:0]	doa		,

		input wire 			clkb	,
		input wire 			enb		,
		input wire 			web		,
		input wire [N-1:0]	addrb	,
		input wire [B-1:0]	dib		,
		output wire [B-1:0]	dob
	);

// Ram type.
reg [B-1:0] RAM [0:2**N-1];
reg [B-1:0]	doa_r;
reg [B-1:0]	dob_r;

always @(posedge clka)
begin
	if (ena) begin
    	if (wea) begin
    	    RAM[addra] <= dia;
		end
		doa_r <= RAM[addra];
	end
end

always @(posedge clkb)
begin
	if (enb) begin
    	if (web) begin
    	    RAM[addrb] <= dib;
		end
		dob_r <= RAM[addrb];
	end
end

assign doa = doa_r;
assign dob = dob_r;

endmodule

