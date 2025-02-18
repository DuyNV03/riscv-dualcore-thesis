
module IO_man (
	input clk,
	input rst,
	
	input data_access_shared_inputs_t ls_inputs,
        ls_sub_unit_interface.sub_unit ls,
        output logic[31:0] data_out,
        
 	    output logic raddr_en,
        output logic [31:0] s_axi_araddr,
        input logic [31:0] s_axi_rdata,
        input logic s_axi_rvalid
        
);
assign ls.ready = 1;

assign s_axi_araddr = ls_inputs.addr;
assign raddr_en = ls.new_request;
assign data_out = s_axi_rdata;

always_ff @ (posedge clk) begin
        if (rst)
            ls.data_valid <= 0;
        else
            ls.data_valid <= s_axi_rvalid;
    end


endmodule
