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


    
  /* logic [L1_CONNECTIONS-1:0] valid;
   logic [L1_CONNECTIONS-1:0] wnr;
   logic [L1_CONNECTIONS-1:0] valid_1;
   logic [L1_CONNECTIONS-1:0] wnr_1;*/
   
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
    
 /* 
    
    generate 
    for (int i =0; i < L1_CONNECTIONS ; i++) begin 
    if (i == L1_DCACHE_ID) begin
    if (receiver[i].wnr && receiver[i].valid) begin // core_0 wants to write to its dcache
   assign recevier[i].ack[0] = 1;
   assign sender_1[i].wnr = receiver[i].wnr;
   assign sender_1[i].addr = receiver[i].addr;
   assign sender_1[i].valid = valid;

          end
    else if (~(receiver[i].wnr) && receiver[i].valid) begin // core_0 wants to read from the other dcache
      assign recevier[i].ack[0] = 1;
      assign sender_1[i].wnr = receiver[i].wnr;
      assign sender_1[i].addr = receiver[i].addr;
      assign sender_1[i].valid = valid;
       end
       
       else if (receiver_1[i].wnr && receiver_1[i].valid) begin // core_1 wants to write to its dcache
   assign recevier_1[i].ack[0] = 1;
   assign sender[i].wnr = receiver_1[i].wnr;
   assign sender[i].addr = receiver_1[i].addr;
   assign sender[i].valid = valid;

          end
    else if (~(receiver_1[i].wnr) && receiver_1[i].valid) begin // core_1 wants to read from the other dcache
      assign recevier_1[i].ack[0] = 1;
      assign sender[i].wnr = receiver_1[i].wnr;
      assign sender[i].addr = receiver_1[i].addr;
      assign sender[i].valid = valid;
       end
       
    if (sender_1[i].ack[0] == 1) begin  // updata data from c0 to c1
    if (sender_1[i].ack[1] == 1) begin
      assign arb2c[i].addr = sender_1[i].addr;
      assign c2c_1[i].addr = arb2c[i].data;
      end   
    end
       
   end
    else if (i == L1_ICACHE_ID) begin 
    
    if (receiver[i].wnr && receiver[i].valid) begin // core_0 wants to write to its Icache
   assign recevier[i].ack[0] = 1;
   assign sender_1[i].wnr = receiver[i].wnr;
   assign sender_1[i].addr = receiver[i].addr;
   assign sender_1[i].valid = valid;

          end
    else if (~(receiver[i].wnr) && receiver[i].valid) begin // core_0 wants to read from the other Icache
      assign recevier[i].ack[0] = 1;
      assign sender_1[i].wnr = receiver[i].wnr;
      assign sender_1[i].addr = receiver[i].addr;
      assign sender_1[i].valid = valid;
       end
       
       else if (receiver_1[i].wnr && receiver_1[i].valid) begin // core_1 wants to write to its Icache
   assign recevier_1[i].ack[0] = 1;
   assign sender[i].wnr = receiver_1[i].wnr;
   assign sender[i].addr = receiver_1[i].addr;
   assign sender[i].valid = valid;

          end
    else if (~(receiver_1[i].wnr) && receiver_1[i].valid) begin // core_1 wants to read from the other Icache
      assign recevier_1[i].ack[0] = 1;
      assign sender[i].wnr = receiver_1[i].wnr;
      assign sender[i].addr = receiver_1[i].addr;
      assign sender[i].valid = valid;
       end
       
    end
   
    
   
    
    
    end
    endgenerate
always_comb begin
                for (int i = 0; i < L2_NUM_PORTS; i++) begin
                    if (d_write[i]) begin 
                    for (int j=0; j < L2_NUM_PORTS; j++) begin 
                    if (j != i) begin 
                    tag_bank #($bits(dtag_entry, DCACHE_LINES) dtag_bank (.*,
                    .en_a('1), .wen_a('0),
                    .addr_a(getAddr(d_addr[i])),
                    .data_in_a('0), .data_out_a(tag_line[i]),

                    .en_b('0), .wen_b(update_tag_way[i]),
                    .addr_b(update_port_addr),
                    .data_in_b(new_tagline), .data_out_b(inv_tag_line[i])
                );
                    d_valid_line[j]= 1'b0; 
                    d_inv_tag [j]= getTag_s(d_addr[i]);
                      
                       end
                    end
                end
            end
            */
      
