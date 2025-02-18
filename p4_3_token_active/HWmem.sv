

import taiga_config::*;
import taiga_types::*;
import riscv_types::*;

        module HWmem #(parameter preload_file = "", parameter LINES = 4096/*16384*/, parameter RESET_VECT= 32'h40000000) (
        input logic clk,

        input logic[$clog2(LINES)-1:0] addr_a, // portA is a read port
        input logic en_a,
    
        //input logic[XLEN-1:0] data_in_a,
        output logic[XLEN-1:0] data_out_a,

        input logic[$clog2(LINES)-1:0] addr_b,
       // input logic en_b,
        input logic[XLEN/8-1:0] be_b,
        input logic[XLEN-1:0] data_in_b
        //output logic[XLEN-1:0] data_out_b
        );

/*(* ram_decomp = "power" *)*/ logic [31:0] ram [LINES-1:0];
 
  initial
    begin
            $readmemh(preload_file,ram, 0, LINES-1);
    end
    
    always_ff @ (posedge clk) begin
            if (en_a) begin
                    data_out_a = ram[addr_a];
                end
        end
        
    generate
    genvar i;
    for (i=0; i < 4; i++) begin
    always_ff @ (posedge clk) begin
           // if (en_b) begin
                if (be_b[i]) begin
                    ram[addr_b][8*i+:8] = data_in_b[8*i+:8];
                    //data_out_b[8*i+:8] <= data_in_b[8*i+:8];
                    end
            //end
        end
    end
    endgenerate

endmodule
