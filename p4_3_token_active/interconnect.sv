import core_manage_types::*;

module interconnect_ #(parameter DEPTH =32) (
	input clk,
	input rst,
	
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
	//UART interface
	input o_Tx_Active,
	input o_Tx_Done,
	output logic i_Tx_DV,
	output logic [7:0] i_Tx_Byte,
	output logic [31:0] i_tx_word,
	output logic [3:0] wstrb
	
	);
	axi_data result2_man [NUM_CPUS-1:0] = '{default: 0};
	logic [$clog2(NUM_CPUS)-1:0] core_count ;
	logic [$clog2(NUM_CPUS)-1:0] core_count2 ;
	
	logic [NUM_CPUS-1:0] rvalidFman;
	logic [NUM_CPUS-1:0] rdataFman;
	
	logic [$clog2(NUM_CPUS)-1:0] core_id;
	
	/*parameter start_cmu = 2'b00;
	parameter end_cmu = 2'b01;
	parameter start_uart = 2'b10;
	parameter end_uart = 2'b11;
	
	logic [1:0] rtransaction;
    logic [1:0] wtransaction;
    	*/
  function void Wdata2man ();
  
	wdata = w2man_pkt[core_count].wdata;
	 waddr = w2man_pkt[core_count].waddr;
	 w_valid = w2man_pkt[core_count].w_valid;
	 awvalid = w2man_pkt[core_count].awvalid;
	 case (core_count)
	 0: w2man[0].pop = 1;
	 1: w2man[1].pop = 1;
	 endcase
	 
       // core_count = core_count + 1;
        endfunction
        
  function void rFman_data ();
	 
	 raddr = rFman_pkt[core_count2].raddr;
	 arvalid = rFman_pkt[core_count2].arvalid;
	 rvalidFman[core_count2] = rvalid;
	 rdataFman[core_count2] = rdata;
	 
	 case (core_count2)
	 0: rFman[0].pop = 1;
	 1: rFman[1].pop = 1;
	 
	 endcase 
    endfunction
    
   function void w2U ();
   if (o_Tx_Active == 0) begin
        i_Tx_DV = 1;
        
        if (w2uart_pkt[core_id].wstrb[0]) begin
        i_tx_word = w2uart_pkt[core_id].wdata [7:0];
        i_Tx_Byte = w2uart_pkt[core_id].wdata [7:0];
        end
        if (w2uart_pkt[core_id].wstrb[1])
        i_tx_word = w2uart_pkt[core_id].wdata [15:8];
        if (w2uart_pkt[core_id].wstrb[2])
        i_tx_word = w2uart_pkt[core_id].wdata [23:16];
        if (w2uart_pkt[core_id].wstrb[3])
        i_tx_word = w2uart_pkt[core_id].wdata [31:24]; 
        
        wstrb = w2uart_pkt[core_id].wstrb;
        case (core_id)
        0: w2uart[0].pop = 0;
        1: w2uart[1].pop = 0;
        endcase
        end
        if (o_Tx_Active == 0 && o_Tx_Done) begin 
        case (core_id)
        0: w2uart[0].pop = 1;
        1: w2uart[1].pop = 1;
        endcase
        i_Tx_DV = 0;
        core_id = core_id + 1;
       end 
       
   endfunction    
   
	r_axi_data rFman_pkt [NUM_CPUS-1:0];
	w_axi_data w2man_pkt [NUM_CPUS-1:0];
	r_axi_data rFuart_pkt [NUM_CPUS-1:0];
	w_axi_data w2uart_pkt [NUM_CPUS-1:0];
	
	localparam READ_QUEUE_DEPTH_MAN = 4;
	localparam WRITE_QUEUE_DEPTH_MAN = 4;
	localparam READ_QUEUE_DEPTH_UART = 8;
	localparam WRITE_QUEUE_DEPTH_UART = 64;
	
	logic [$clog2(READ_QUEUE_DEPTH_MAN)-1:0] size1 [NUM_CPUS-1:0]; 
	logic [$clog2(WRITE_QUEUE_DEPTH_MAN)-1:0] size2 [NUM_CPUS-1:0];
	logic [$clog2(READ_QUEUE_DEPTH_UART)-1:0] size3 [NUM_CPUS-1:0]; 
	logic [$clog2(WRITE_QUEUE_DEPTH_UART)-1:0] size4 [NUM_CPUS-1:0];
	
	fifo_interface #(.DATA_WIDTH($bits(r_axi_data))) rFman[NUM_CPUS-1:0]();  // fifo to read data from the CMU
	fifo_interface #(.DATA_WIDTH($bits(w_axi_data))) w2man [NUM_CPUS-1:0]();  // fifo to write data to the CMU
	fifo_interface #(.DATA_WIDTH($bits(r_axi_data))) rFuart [NUM_CPUS-1:0]();  // fifo to read data from the UART
	fifo_interface #(.DATA_WIDTH($bits(w_axi_data))) w2uart [NUM_CPUS-1:0]();  // fifo to write data to the UART
	
	
  logic id = '0;
	genvar i;
//////////implementation
generate 
	for (i=0;i<NUM_CPUS; i=i+1) begin 
	assign rFman_pkt[i] = rFman[i].data_out;
	assign w2man_pkt[i] = w2man[i].data_out;
	assign rFuart_pkt[i] = rFuart[i].data_out;
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
	       w2man[i].data_in = {s_axi[i].awvalid, s_axi[i].wvalid ,s_axi[i].wdata, s_axi[i].awaddr, s_axi[i].wstrb};
	       end
	       else begin
	       w2man[i].push = 0;
	       w2man[i].potential_push = 0;
	         end
	       end
	   else if (s_axi[i].awaddr > 32'h600000ff && s_axi[i].awaddr <= 32'h60000fff) begin
	       if (s_axi[i].awvalid) begin
	       w2uart[i].push = 1;
	       w2uart[i].potential_push = 1;
	       w2man[i].push = 0;
	       w2man[i].potential_push = 0;
	      
	       w2uart[i].data_in = {s_axi[i].awvalid, s_axi[i].wvalid, s_axi[i].wdata, s_axi[i].awaddr, s_axi[i].wstrb};
	       end
	       else begin
	       w2uart[i].push = 0;
	       w2uart[i].potential_push = 0;
	         end
	       end
	  else begin
	       w2man[i].push = 0;
	       w2man[i].potential_push = 0;
	       w2uart[i].push = 0;
	       w2uart[i].potential_push = 0;
	       end
	       
	   if (s_axi[i].araddr <= 32'h6000001d && s_axi[i].araddr >= 32'h60000000) begin
	       if (s_axi[i].arvalid) begin
	       rFman[i].push = 1;
	       rFman[i].potential_push = 1;
	       rFuart[i].push = 0;
	       rFuart[i].potential_push= 0;
	       rFman[i].data_in = {s_axi[i].araddr, s_axi[i].arvalid};
	       end
	       else begin
	       rFman[i].push = 0;
	       rFman[i].potential_push = 0;
	         end
	       end
	       else if (s_axi[i].araddr > 32'h600000ff && s_axi[i].araddr <= 32'h60000fff) begin
	       if (s_axi[i].arvalid) begin
	       rFman[i].push = 0;
	       rFman[i].potential_push = 0;
	       rFuart[i].push = 1;
	       rFuart[i].potential_push = 1;
	       rFuart[i].data_in =  {s_axi[i].araddr, s_axi[i].arvalid};
	       end 
	       else begin
	       rFuart[i].push = 0;
	       rFuart[i].potential_push = 0; 
	       end
	       end
	  else begin
	       rFman[i].push = 0;
	       rFman[i].potential_push = 0;
	       rFuart[i].push = 0;
	       rFuart[i].potential_push = 0;
	       end     
	    end
   taiga_fifo2 #(.DATA_WIDTH($bits(r_axi_data)), .FIFO_DEPTH(READ_QUEUE_DEPTH_MAN)) rFman_ (.*, .fifo(rFman[i]), .size(size1[i]));
   taiga_fifo2 #(.DATA_WIDTH($bits(w_axi_data)), .FIFO_DEPTH(WRITE_QUEUE_DEPTH_MAN)) w2man_ (.*, .fifo(w2man[i]), .size(size2[i]));
   taiga_fifo2 #(.DATA_WIDTH($bits(r_axi_data)), .FIFO_DEPTH(READ_QUEUE_DEPTH_UART)) rFuart_ (.*, .fifo(rFuart[i]), .size(size3[i]));
   taiga_fifo2 #(.DATA_WIDTH($bits(w_axi_data)), .FIFO_DEPTH(WRITE_QUEUE_DEPTH_UART)) w2uart_ (.*, .fifo(w2uart[i]),.size(size4[i]));   
	  end
    endgenerate
  
   // write to the core management unit
   always_comb begin
	if (rst) begin
	core_count = 0;
	end 
	else begin  
	if (size2[core_count] > 0 ) begin
	 Wdata2man();
        end
     
      else begin
      case (core_count)
	 0: w2man[0].pop = 0;
	 1: w2man[1].pop = 0;
	 endcase
      core_count = core_count + 1;
      if (size2[core_count] > 0 ) begin
     Wdata2man();        
     end
     core_count = core_count + 1;
     end
     	
   // else
   // w2man[i].pop = 0;  
     end
     end
 // read operation from the core management unit
 /*
 generate 
	for (i=0;i<NUM_CPUS; i=i+1) begin
	assign s_axi[i].rvalid = rvalidFman[i];
	assign s_axi[i].rdata = rdataFman[i];
	end
  endgenerate
   
   generate 
    for (i=0; i <NUM_CPUS; i++) begin
    always_ff @ (posedge clk) begin
    if (rst) begin 
    s_axi[i].arready =1;
    end 
    else begin 
   if (size1[i] < READ_QUEUE_DEPTH_MAN -1)
    s_axi[i].arready = 1;
    else
    s_axi[i].arready =0;
            end
        end
    end
    endgenerate
    
    always_comb begin
	if (rst) begin
	core_count2 = 0;
	end 
	else begin  
	if (size1[core_count2] > 0 ) begin
	 case (core_count2)
	 0: if (s_axi[0].rready) rFman_data();
	 1: if (s_axi[1].rready) rFman_data();
	 endcase
        end
     
      else begin
      
      case (core_count2)
	 0: rFman[0].pop = 0;
	 1: rFman[1].pop = 0;
	 endcase
     
      core_count2 = core_count2 + 1;
     if (size1[core_count2] > 0 ) begin
       case (core_count2)
	    0: if (s_axi[0].rready) rFman_data();
	    1: if (s_axi[1].rready) rFman_data();
	   endcase
	   end        
     core_count2 = core_count2 + 1;
     end
     	
         end
     end
    */ 
    logic [2:0] idw;
	logic [2:0] idr;
	
	logic [31:1] temp_raddr;
	
generate
  for (i=0;i<NUM_CPUS; i=i+1) begin
  assign result2_man[i].arvalid = s_axi[i].arvalid;
  assign result2_man[i].raddr = temp_raddr;
  
     end
     endgenerate
     
     
   genvar ii;
    generate
  for (ii=0;ii<NUM_CPUS; ii=ii+1) begin 
     always_comb begin
     if (s_axi[ii].arvalid ) begin
  temp_raddr = s_axi[ii].araddr;
  
     end
     end
     end
     endgenerate

  logic [NUM_CPUS-1:0] rvalid_m;
  logic [31:0] rdata_m [NUM_CPUS-1:0];
  
  
  generate
  for (i=0; i< NUM_CPUS;i++) begin
  assign s_axi[i].rvalid = rvalid_m[i];
  assign s_axi[i].rvalid = rvalid_m[i];
  assign s_axi[i].rdata = rdata_m[i];
  assign s_axi[1].rdata = rdata_m[i];
  end
  endgenerate
 
     generate
     always_comb begin
     if (rst) begin
     idr =0;
     //rtransaction =0;
     end
     else begin 
     
     if ( rvalid & (id == 0)) begin
     rvalid_m[0] = 1;
     rvalid_m[1] = 0;
     rdata_m[0] = rdata;      
      end
     else if (rvalid & (id == 1)) begin 
     rvalid_m[1] =1;
     rvalid_m[0] =0;
     rdata_m[1] = rdata;
      
     end
     else begin
     rvalid_m[0]  = 0;
     rvalid_m[1]  = 0;
     
     end
     
      if (result2_man[idr[0]].arvalid ) begin
      arvalid =  result2_man[idr[0]].arvalid;
      raddr = result2_man[idr[0]].raddr;
      id = idr[0];
      
     end
     
     else begin 
     idr = idr +1;
     if (result2_man[idr[0]].arvalid) begin
     arvalid =  result2_man[idr[0]].arvalid;
     raddr = result2_man[idr[0]].raddr;
     id = idr[0];
     end
     else 
     arvalid = 0;
     end
     
     idr = idr +1;
     end
     end
     
     endgenerate
   

  assign s_axi[0].wready=1;
  assign s_axi[1].wready=1;

logic[3:0] read_counter[NUM_CPUS-1:0];
logic begin_read[NUM_CPUS-1:0];
logic[3:0] READ_COUNTER_MAX;

assign READ_COUNTER_MAX = 4'b0000;

    generate
        for (i=0;i<NUM_CPUS;i=i+1) begin
          always_comb begin
           if (rst)
           s_axi[i].awready = 1;
           else
          if (s_axi[i].araddr <= 32'h6000001d && s_axi[i].araddr >= 32'h60000000) begin
            if (size1[i] < (READ_QUEUE_DEPTH_MAN-1))
            s_axi[i].arready =  1 ;
            else
            s_axi[i].arready =  0;
            end
           else if (s_axi[i].araddr > 32'h600000ff && s_axi[i].araddr <= 32'h60000fff) begin
            if (size3[i] < (READ_QUEUE_DEPTH_UART-1)) 
             s_axi[i].arready =  1 ;
            else
            s_axi[i].arready =  0;
            end
            
            if (s_axi[i].awaddr == WADDR_MAN) begin
              if (size2[i] < WRITE_QUEUE_DEPTH_MAN-1)
               s_axi[i].awready =  1 ;
              else
              s_axi[i].awready =  0;
            end   
            else if (s_axi[i].awaddr > 32'h600000ff && s_axi[i].awaddr <= 32'h60000fff) begin
             if (size4[i] < WRITE_QUEUE_DEPTH_UART-1)
             s_axi[i].awready =  1 ;
              else
              s_axi[i].awready =  0;
            end
           end
          end
         
    endgenerate
  
generate
 for (i=0;i<NUM_CPUS;i=i+1) begin
     always_ff @(posedge clk) begin
        if (rst) begin
            s_axi[i].arready <= 1; //You want it to start at ready
            s_axi[i].rresp <= 0;
            read_counter[i] <= READ_COUNTER_MAX;
            
        end
        else begin
            if(s_axi[i].arready == 1 && s_axi[i].arvalid == 1) begin
                s_axi[i].arready <= 0;
                begin_read[i] <=1;
            
            end

        //    if(begin_read[i]) begin
      else  begin     s_axi[i].arready <=  1;
                if(read_counter[i] == 0) begin
                    //s_axi[i].rvalid <= result2_man[i].rvalid;
                    //s_axi[i].rdata <= result2_man[i].rdata; 
                  //  result2_man[i].rdata <= rdata;//map[s_axi[i].araddr[$clog2(DEPTH)-1:0]]; //set the data
                    read_counter[i] <= READ_COUNTER_MAX;
                    begin_read[i] <= 0;
                end
                else begin
                    read_counter[i] <= read_counter[i] - 1;
                    s_axi[i].rvalid <= 0;
                
            end
            end

          //  if(s_axi[i].rvalid &&  s_axi[i].rready) begin
            //    s_axi[i].rvalid <= 0;
           // end

        end
        
    end
           
        end // for
            endgenerate 
           
            
  // write to the UART
 logic core_id_next; 
 assign core_id_next = core_id +1;
 
    always_ff @ (posedge clk) begin
        if (rst) begin
         core_id = 0; 
        end
       else begin 
       case (core_id_next)
        0: w2uart[0].pop = 0;
        1: w2uart[1].pop = 0;
        endcase
        
        if (size4[core_id] > 0) begin
        w2U ();
       end
     else begin
     if (o_Tx_Active == 0) 
      core_id = core_id + 1;
      
      if (size4[core_id] > 0) begin
           w2U ();
         end
      end
   end
 end
 
          
endmodule
