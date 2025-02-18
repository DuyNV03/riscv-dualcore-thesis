
module IO_man (
	input clk,
	input rst,
	
	input data_access_shared_inputs_t ls_inputs,
        ls_sub_unit_interface.sub_unit ls,
        output logic[31:0] data_out,
        
 	    output logic addr_en,
        output logic [31:0] s_axi_addr,
        output logic [31:0] s_axi_wdata,
        output logic w_nrr,
        output logic [3:0] wstrb,
        input logic [31:0] s_axi_rdata,
        input logic s_axi_rvalid
        
);
assign ls.ready = 1;

assign s_axi_addr = ls_inputs.addr;
assign s_axi_wdata = ls_inputs.data_in;
assign w_nrr = ls_inputs.store;
assign addr_en = ls.new_request;
//assign data_out = s_axi_rdata;
assign wstrb = ls_inputs.be;

always_ff @ (posedge clk) begin
        if (rst)
            ls.data_valid <= 0;
        else
        begin
            ls.data_valid <= s_axi_rvalid;
            data_out <= s_axi_rdata;
            end
    end


endmodule
