import taiga_config::*;
import riscv_types::*;
import taiga_types::*;
import l2_config_and_types::*;
module snoopy_protocol (
input logic clk,
input logic rst,

c2snoopy_request.slave receiver [L1_CONNECTIONS-1:0],
c2snoopy_request.master sender [L1_CONNECTIONS-1:0],

c2snoopy_request.slave receiver_1 [L1_CONNECTIONS-1:0],
c2snoopy_request.master sender_1 [L1_CONNECTIONS-1:0]

);


   
   genvar i;

   /* generate
        for (i=0; i <L1_CONNECTIONS; i++) begin
            assign valid[i] = receiver[i].valid;
            assign wnr[i] = receiver[i].wnr;
            assign valid_1[i] = receiver_1[i].valid;
            assign wnr_1[i] = receiver_1[i].wnr;
        end
    endgenerate*/
   
   
   always_ff  @ ( posedge clk) begin
   if (receiver[L1_DCACHE_ID].valid ) begin 
   sender_1[L1_DCACHE_ID].wnr <=1;
   sender_1[L1_DCACHE_ID].addr <=receiver[L1_DCACHE_ID].addr;
   sender_1[L1_DCACHE_ID].valid <=1;
   end
   else 
   sender_1[L1_DCACHE_ID].valid <= 0;
   
   if (receiver_1[L1_DCACHE_ID].valid ) begin 
   sender[L1_DCACHE_ID].wnr <=1;
   sender[L1_DCACHE_ID].addr <=receiver_1[L1_DCACHE_ID].addr;
   sender[L1_DCACHE_ID].valid <=1;
   end
   else
   sender[L1_DCACHE_ID].valid <=0;
   /*else if (wnr[L1_ICACHE_ID]) begin
   
   sender_1[L1_ICACHE_ID].wnr=receiver[L1_ICACHE_ID].wnr;
   sender_1[L1_ICACHE_ID].addr=receiver[L1_ICACHE_ID].addr;
   sender_1[L1_ICACHE_ID].valid=1;
      end*/
      
   end
   
   endmodule 

