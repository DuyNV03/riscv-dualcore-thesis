`timescale 1ns/1ns


import core_manage_types::*;


module core_man_tb ( );
    logic clk;
    logic rst;
    
   
    
    logic pwr;
      
    axi_interface  s_axi[NUM_CPUS-1:0]();
    logic [NUM_CPUS-1:0] halt;
    
    core_management #(.WIDTH($bits(IO_manage_t))) uut (.*);
    
    always
    #1 clk = ~clk;
    
    logic [31:0] addr;
    logic [31:0] halt_data;
     always_ff @(posedge clk) begin
       if (rst) begin
       s_axi[0].rready <= 0;
       s_axi[0].arvalid <= 1; //You want it to start at ready
      end     
      else begin
      if (s_axi[0].arvalid ==1 && s_axi[0].arready ==1) begin
      s_axi[0].araddr <= addr;
      s_axi[0].arvalid <= 0;
      s_axi[0].rready <=1;
       end
       
       if (s_axi[0].rvalid == 1) begin
       halt_data <= s_axi[0].rdata;
       s_axi[0].arvalid <= 1;
       s_axi[0].rready <=0;
       end
        
     end     
      
       
end  
logic [31:0] data;

     always_ff @(posedge clk) begin
       if (rst) begin
        s_axi[0].wvalid <= 0;
        s_axi[0].awvalid <= 1;
       end
       else begin
        if(s_axi[0].awready == 1 && s_axi[0].awvalid == 1) begin
           s_axi[0].awvalid <= 0;
           s_axi[0].wdata <= data;
           s_axi[0].wvalid <= 1;
         end
         if (s_axi[0].awvalid == 0) begin
              s_axi[0].wvalid <= 0;
              s_axi[0].awvalid <=1;
              s_axi[0].bready <=1;
             end
             end
             
     end
     
     initial begin
     clk = 1'b0; 
     do_reset();
     
     pwr = 1'b1;
     #4 data = 32'h00000000;
     
     #10 data = 32'h00000001;
     
     #20 addr = 32'h00000001;
     
     #20 data =32'h00000006;
     
     #20 addr = 32'h00000000;
   
    
     end
    
    task do_reset;
    begin
        rst = 1'b0;
        #4 rst = 1'b1;
        #6 rst =1'b0;
    end
    endtask 
     
     endmodule
     
    
