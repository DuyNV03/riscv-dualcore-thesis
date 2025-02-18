
import taiga_config::*;
import taiga_types::*;

module tag_dual #(
        parameter WIDTH = 32,
        parameter LINES = 512
    )
(
	input logic clk,
	input logic rst,
	input logic en_a,
	input logic en_b, 
	input logic wen_a,
	input logic wen_b, 
	input logic [$clog2(LINES)-1:0] addr_a1,
	input logic [$clog2(LINES)-1:0] addr_b1,
	input logic [$clog2(LINES)-1:0] addr_a2, // snoopy
	input logic [WIDTH-1:0] data_in_a,
	input logic [WIDTH-1:0] data_in_b, 
	output logic [WIDTH-1:0] data_out_a1,
	output logic [WIDTH-1:0] data_out_b1,
	output logic [WIDTH-1:0] data_out_a2
	);
	
    logic [$clog2(LINES)-1:0] muxed_addr_a;
	
	logic wen_a2;
	logic en_a2;
	
	tag_bank #($bits(dtag_entry_t), DCACHE_LINES) dtag_bank1
	(.*, .addr_a(addr_a1),.addr_b(addr_b1),.data_out_a(data_out_a1),.data_out_b(data_out_b1));
	
	tag_bank #($bits(dtag_entry_t), DCACHE_LINES) dtag_bank2
	(.*, .en_a(en_a2),.wen_a(wen_a2), .addr_a(muxed_addr_a),
	.addr_b(addr_b1),.data_out_a(data_out_a2),.data_out_b());
	

	always_comb begin
	if (!(en_a & wen_a)) begin
	   muxed_addr_a = addr_a2;
	   wen_a2 = 0;
	   en_a2 = 1;
	   end
	else begin
	muxed_addr_a = addr_a1;
	wen_a2 = wen_a;
	en_a2 = en_a;
	end
	
     end
	
  endmodule
