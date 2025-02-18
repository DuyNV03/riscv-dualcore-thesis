
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2022 07:17:52 PM
// Design Name: 
// Module Name: sp_inter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


import core_manage_types::*;

module sp_inter #(parameter DEPTH =32) (
	input logic clk,
	input logic rst,
	
	axi_interface.slave s_axi [NUM_CPUS-1:0],
	
	
	//local_memory_interface.master data_bram,
	// core management
	output logic awvalid,
	output logic w_valid,
	output logic [31:0] wdata,
	output logic [31:0] waddr,
	input logic w_done,
	
	output logic arvalid,
	input logic rvalid,
	output logic [31:0] raddr,
	input logic [31:0] rdata,
	output logic pwr,
	//UART interface
	input o_Tx_Active,
	input o_Tx_Done,
	output logic i_Tx_DV,
	output logic [7:0] i_Tx_Byte,
	output logic [31:0] i_tx_word,
	output logic [3:0] wstrb,
	input logic [2:0] s_machine,
	output logic [7:0] CLKS_PER_BIT
	
	);
	
	logic [NUM_CPUS-1:0] taken = '{default:0};
	logic [2:0] tok [NUM_CPUS-1:0] = '{default:0}; 
	
		logic [(AXI_DATA_WIDTH/8)-1:0] wstrb_man;
	//axi_data result2_man [NUM_CPUS-1:0] = '{default: 0};
	logic [$clog2(NUM_CPUS)-1:0] core_count ;
	logic [$clog2(NUM_CPUS)-1:0] core_count2 ;
	
	logic [NUM_CPUS-1:0] rvalidFman;
	logic [NUM_CPUS-1:0] rdataFman;
	
	logic [$clog2(NUM_CPUS)-1:0] core_id;
	
	assign CLKS_PER_BIT = 87;
	assign pwr = 1;  
   
	//r_axi_data rFman_pkt [NUM_CPUS-1:0];
	w_axi_data w2man_pkt [NUM_CPUS-1:0];
	//r_axi_data rFuart_pkt [NUM_CPUS-1:0];
	w_axi_data w2uart_pkt [NUM_CPUS-1:0];
	
	//localparam READ_QUEUE_DEPTH_MAN = 4;
	localparam WRITE_QUEUE_DEPTH_MAN = 4;
	localparam READ_QUEUE_DEPTH_ADDR = 4;
	localparam WRITE_QUEUE_DEPTH_UART = 64;
	
	//logic [$clog2(READ_QUEUE_DEPTH_MAN)-1:0] size1 [NUM_CPUS-1:0]; 
	logic [$clog2(WRITE_QUEUE_DEPTH_MAN)-1:0] size2 [NUM_CPUS-1:0];
	logic [$clog2(READ_QUEUE_DEPTH_ADDR)-1:0] size3 [NUM_CPUS-1:0]; 
	logic [$clog2(WRITE_QUEUE_DEPTH_UART)-1:0] size4 [NUM_CPUS-1:0];
	
	//fifo_interface #(.DATA_WIDTH($bits(r_axi_data))) rFman[NUM_CPUS-1:0]();  // fifo to read data from the CMU
	fifo_interface #(.DATA_WIDTH($bits(w_axi_data))) w2man [NUM_CPUS-1:0]();  // fifo to write data to the CMU
	fifo_interface #(.DATA_WIDTH(32)) axi_raddr [NUM_CPUS-1:0]();  // fifo to read araddr of the two cores read address channel
	fifo_interface #(.DATA_WIDTH($bits(w_axi_data))) w2uart [NUM_CPUS-1:0]();  // fifo to write data to the UART
	
	
  
	genvar i,j;
//////////implementation
generate 
	for (i=0;i<NUM_CPUS; i=i+1) begin 
//	assign rFman_pkt[i] = rFman[i].data_out;
	assign w2man_pkt[i] = w2man[i].data_out;
//	assign rFuart_pkt[i] = rFuart[i].data_out;
	assign w2uart_pkt[i] = w2uart[i].data_out;
    end
  endgenerate
  
generate 
	for (i=0;i<NUM_CPUS; i=i+1) begin 
	always_comb begin 
	   if (s_axi[i].awaddr == WADDR_MAN) begin // WADDR_MAN is 0x60000000
	       if (s_axi[i].awvalid) begin
	       w2man[i].push = 1;
	       w2man[i].potential_push = 1;
	       w2uart[i].push = 0;
	       w2uart[i].potential_push = 0;
	       w2man[i].data_in = {s_axi[i].awvalid, s_axi[i].wvalid ,tok[i] ,s_axi[i].wdata, s_axi[i].awaddr, s_axi[i].wstrb};
	       w2uart[i].data_in = 0;
	       end
	       else begin
	       w2man[i].push = 0;
	       w2man[i].potential_push = 0;
	       w2uart[i].push = 0;
	       w2uart[i].potential_push = 0;
	       w2man[i].data_in = 0;
	       w2uart[i].data_in = 0;
	         end
	       end
	   else if (s_axi[i].awaddr > 32'h600000ff && s_axi[i].awaddr <= 32'h60000fff) begin
	       if (s_axi[i].awvalid) begin
	       w2uart[i].push = 1;
	       w2uart[i].potential_push = 1;
	       w2man[i].push = 0;
	       w2man[i].potential_push = 0;
	       w2man[i].data_in = 0;
	       w2uart[i].data_in = {s_axi[i].awvalid, s_axi[i].wvalid, tok[i],s_axi[i].wdata, s_axi[i].awaddr, s_axi[i].wstrb};
	       end
	       else begin
	       w2uart[i].push = 0;
	       w2uart[i].potential_push = 0;
	        w2man[i].push = 0;
	       w2man[i].potential_push = 0;
	       w2man[i].data_in = 0;
	       w2uart[i].data_in = 0;
	         end
	       end
	  else begin
	       w2man[i].push = 0;
	       w2man[i].potential_push = 0;
	       w2uart[i].push = 0;
	       w2uart[i].potential_push = 0;
	       w2man[i].data_in = 0;
	       w2uart[i].data_in = 0;
	       end
	    
	    end
  // taiga_fifo2 #(.DATA_WIDTH($bits(r_axi_data)), .FIFO_DEPTH(READ_QUEUE_DEPTH_MAN)) rFman_ (.*, .fifo(rFman[i]), .size(size1[i]));
   taiga_fifo23 #(.DATA_WIDTH($bits(w_axi_data)), .FIFO_DEPTH(WRITE_QUEUE_DEPTH_MAN)) w2man_ (.*, .fifo(w2man[i]), .size(size2[i]));
   //taiga_fifo2 #(.DATA_WIDTH($bits(r_axi_data)), .FIFO_DEPTH(READ_QUEUE_DEPTH_UART)) rFuart_ (.*, .fifo(rFuart[i]), .size(size3[i]));
   taiga_fifo23 #(.DATA_WIDTH($bits(w_axi_data)), .FIFO_DEPTH(WRITE_QUEUE_DEPTH_UART)) w2uart_ (.*, .fifo(w2uart[i]),.size(size4[i]));   
   taiga_fifo23 #(.DATA_WIDTH(32), .FIFO_DEPTH(READ_QUEUE_DEPTH_ADDR)) axi_raddr_ (.*, .fifo(axi_raddr[i]), .size(size3[i]));
	  end
    endgenerate
  
   // write to the core management unit
   always_ff @ (posedge clk or posedge rst) begin
	if (rst) begin
	core_count = 0;
	w_valid = 0;
     awvalid = 0;
     wdata = 0;
     waddr = 0;
     wstrb_man = 0;
	end 
	else begin
	 Wdata2man();
	 end
   end
 // read operation from the core management unit
	logic id ;
	logic [NUM_CPUS-1:0] rvalid_m;
    logic [31:0] rdata_m [NUM_CPUS-1:0];
    logic [1:0] CMUnUART [NUM_CPUS];
    //logic [1:0] CMUnUART_2 [NUM_CPUS];  // it was a cause of bug
    
 generate 
  for (i= 0; i< NUM_CPUS; i=i+1) 
  begin
    always_comb begin
    if ((axi_raddr[i].data_out >= 32'h6000000 && axi_raddr[i].data_out <= 32'h6000001d) && (size3[i] > 0) )
        CMUnUART[i]= 2'b00; // cmu read command
    else if ((axi_raddr[i].data_out == RADDR_UART || axi_raddr[i].data_out == RADDR_UART_T) && (size3[i] > 0)) // UART read command
        CMUnUART[i] = 2'b01;
    else
     CMUnUART[i] = 2'b10; // none 
  end
 end   
 endgenerate
  /* 
  always_ff @ (posedge clk ) begin 
  CMUnUART_2 <= CMUnUART;
  end
  
  */
  generate 
	for (i=0; i<NUM_CPUS; i=i+1) begin
	 assign axi_raddr[i].push = s_axi[i].arvalid;
	 assign axi_raddr[i].potential_push = s_axi[i].arvalid;
	 assign axi_raddr[i].data_in = s_axi[i].araddr;
	end
	assign axi_raddr[0].pop = (CMUnUART[0] == 0) || (CMUnUART[0] == 1);
	assign axi_raddr[1].pop =  (CMUnUART[1] == 1) ? 1 : (CMUnUART[1] == 0) ? ((CMUnUART[0] == 0) ? 0 : 1) : 0; 
  endgenerate
  
  always_comb begin
     if (CMUnUART[0] == 0) begin
     raddr = axi_raddr[0].data_out;
     arvalid =1;
     end
     else if (CMUnUART[1] == 0) 
     begin
     raddr = axi_raddr[1].data_out;
     arvalid =1;
     end
     else begin
     arvalid = 0;
     raddr = 0;
     end
     end
 
 always_comb begin
    if (CMUnUART[0] == 0) begin
    rdata_m [0] = rdata;
    rvalid_m [0] = rvalid;
    end
    else if (CMUnUART[0] == 1) begin
      if (axi_raddr[0].data_out == RADDR_UART ) begin
       rdata_m[0] = (size4[0] < (WRITE_QUEUE_DEPTH_UART-1)) ;
       rvalid_m [0] = 1;
      end
      else if (axi_raddr[0].data_out == RADDR_UART_T) begin
        rdata_m[0] = (size4[0] == (WRITE_QUEUE_DEPTH_UART-1)) ;
        rvalid_m [0] = 1;
      end
      else begin
      rdata_m[0] = 0;
      rvalid_m [0] = 0;
      end
      end
     else begin 
     rdata_m[0] = 0;
     rvalid_m [0] = 0;
     end
    
   // rdata_m [0] = (CMUnUART[0] == 0) ? rdata : (CMUnUART[0] == 1) ? size4[0] < WRITE_QUEUE_DEPTH_UART-1 : 0 ;
   // rvalid_m [0] = (CMUnUART[0] == 0) ? rvalid : (CMUnUART[0] == 1) ? 1 : 0;
    end
    
    always_comb begin
    if (CMUnUART[1] == 1) begin
      if (axi_raddr[1].data_out == RADDR_UART ) begin
       rdata_m [1] = (size4[1] < (WRITE_QUEUE_DEPTH_UART-1)) ;
       rvalid_m[1] = 1 ;
      end
      else if (axi_raddr[1].data_out == RADDR_UART_T ) begin
       rdata_m [1] = (size4[1] == (WRITE_QUEUE_DEPTH_UART-1)) ;
       rvalid_m[1] = 1 ;
      end
      else begin
      rdata_m [1] = 0;
      rvalid_m[1] = 0;
      end
    end
    else if (CMUnUART[1] == 0) begin
    if (CMUnUART[0] != 0) begin 
    rdata_m [1] = rdata;
    rvalid_m [1] = 1;
    end
    else begin
    rvalid_m[1] = 0;
    rdata_m [1] = 0;
    end
   end
   else begin
   rvalid_m[1] = 0;
   rdata_m [1] = 0;
    //rdata_m [1] = (CMUnUART[1] == 1) ? size4[1] < WRITE_QUEUE_DEPTH_UART-1 : (CMUnUART[1] == 0) ? ((CMUnUART[0] == 0) ? 0 : rdata) : 0;
   // rvalid_m [1] = (CMUnUART[1] == 1) ? 1: (CMUnUART[1] == 0) ? ((CMUnUART[0] == 0) ? 0 : 1) : 0;
    end
  end
  
  generate
    for (i=0; i< NUM_CPUS; i=i+1) begin
       assign s_axi[i].rvalid = rvalid_m [i];
       assign s_axi[i].rdata = rdata_m[i];
    end
  endgenerate
  /*
  generate
  for (i=0;i<NUM_CPUS; i=i+1) begin
    assign result2_man[i].arvalid = s_axi[i].arvalid;
    assign result2_man[i].raddr = s_axi[i].araddr;
  
     end
  endgenerate
*/

 // assign s_axi[0].wready=1;
 // assign s_axi[1].wready=1;


    generate
        for (i=0;i<NUM_CPUS;i=i+1) begin
          always_ff @ (posedge clk /*or posedge rst*/) begin
           if (rst) begin
           s_axi[i].awready = 1;
           end
         /*  else begin
           
           if (size2[i] < WRITE_QUEUE_DEPTH_MAN-1)
               s_axi[i].awready =  1 ;
              else
              s_axi[i].awready =  0;
        
           if (size4[i] < WRITE_QUEUE_DEPTH_UART-1)
              s_axi[i].awready =  1 ;
              else
              s_axi[i].awready =  0;
           
            end  */
          end
        end
         
    endgenerate
   
   logic i_Tx_DV_1 ;
   
   always_ff @ (posedge clk)
   i_Tx_DV <= i_Tx_DV_1;
   
  // write to the UART
 logic core_id_next; 
 assign core_id_next = core_id + 1'b1;
 
    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
         core_id <= 0; 
        end
       else begin 
       case (core_id_next)
        0: w2uart[0].pop = 0;
        default: w2uart[1].pop = 0;
        endcase
        
        if (size4[core_id] > 0) begin
        w2U ();
       end
     else begin
     if (o_Tx_Active == 0) 
      core_id <= core_id + 1'b1;
      
     /* if (size4[core_id] > 0) begin
           w2U ();
         end
         else*/
         i_Tx_DV_1 <= 0;
      end
      
      if (s_machine == 4) // clean_up
      begin 
       case (core_id)
        0: begin w2uart[0].pop = 1;
        end
        1: begin w2uart[1].pop = 1;
        end
        endcase
        if (w2uart_pkt[core_id].tok == 0)
        core_id <= core_id +1;
        i_Tx_DV_1 <= 0;
      end
      
   end
 end
    /*
   generate
       for ( j= 0; j < NUM_CPUS; j++) begin
        always_comb begin  
            if ((s_axi[i].araddr == 32'h60001000) && s_axi[i].arvalid) begin
                  if (size4[i] < 40)
                  s_axi[i].rdata = 1; 
                  s_axi[i].rvalid = 1;
                  end
                  else
                  begin
                  s_axi[i].rdata = 0;
                  s_axi[i].rvalid = 1;
              
              end
        end
        
    end
  
  endgenerate
    */
    logic [2:0] taken_id [NUM_CPUS-1:0] = '{default:0};
    
  generate 
  for (i = 0; i< NUM_CPUS ; i++) 
    always_ff @ (posedge clk) begin
        if (s_axi[i].awaddr == 32'h60001000 && s_axi[i].awvalid) begin
        if (s_axi[i].wdata[0] == 1) begin
          taken_id[i] = taken_id[i] + 1;
          if (taken_id[i] == 0)  // as when taken_id  equals zero, it means that it isn't taken 
           taken_id[i] = taken_id[i] + 1;
        tok[i] = taken_id[i];
        end
        else
        tok[i] = 0;
        /*if (s_axi[i].wvalid) begin
           taken [i] = s_axi[i].wdata[0];
           tok[i] = taken_id[i];
           end*/
          
        end
       
    end  
  endgenerate
  
   function void Wdata2man ();
  
  if (size2[core_count] > 0 ) begin
	 wdata = w2man_pkt[core_count].wdata;
	 waddr = w2man_pkt[core_count].waddr;
	 w_valid = w2man_pkt[core_count].w_valid;
	 awvalid = w2man_pkt[core_count].awvalid;
	 wstrb_man = w2man_pkt[core_count].wstrb;
	 case (core_count)
	 0: w2man[0].pop = 1;
	 default: w2man[1].pop = 1;
	 endcase
    end
    
    else begin
    case (core_count)
	 0: w2man[0].pop = 0;
	 default: w2man[1].pop = 0;
     endcase
    /* w_valid = 0;
     awvalid = 0;
     wdata = 0;
     waddr = 0;
     wstrb_man = 0;*/
     core_count = core_count + 1'b1;
     end
   endfunction
  
     function void w2U ();
   if (o_Tx_Active == 0) begin
    if (s_machine == 0)
        i_Tx_DV_1 <= 1;
        
        if (w2uart_pkt[core_id].wstrb[0]) begin
        i_tx_word[7:0] = w2uart_pkt[core_id].wdata [7:0];
        i_Tx_Byte = w2uart_pkt[core_id].wdata [7:0];
        end
        else begin
        i_tx_word[7:0] = 0;
        i_Tx_Byte = 0;
        end
        if (w2uart_pkt[core_id].wstrb[1])
        i_tx_word[15:8] = w2uart_pkt[core_id].wdata [15:8];
        else
        i_tx_word[15:8] = 0;
        if (w2uart_pkt[core_id].wstrb[2])
        i_tx_word[23:16] = w2uart_pkt[core_id].wdata [23:16];
        else
        i_tx_word[23:16] =0;
        if (w2uart_pkt[core_id].wstrb[3])
        i_tx_word[31:24] = w2uart_pkt[core_id].wdata [31:24]; 
        else
        i_tx_word[31:24] =0;
        
        wstrb = w2uart_pkt[core_id].wstrb;
        case (core_id)
        0: w2uart[0].pop = 0;
        default: w2uart[1].pop = 0;
        endcase  
      
      end
      
      else
      i_Tx_DV_1 <= 0;
      
      /*
      if (o_Tx_Active == 0 && o_Tx_Done) begin 
        case (core_id)
        0: w2uart[0].pop = 1;
        default: w2uart[1].pop = 1;
        endcase
       // i_Tx_DV = 0;
        core_id = core_id + 1;
       
      end */   
   endfunction  
          
endmodule