import core_manage_types::*;

module interconnec #(parameter DEPTH =32) (
	input clk,
	input rst,
	
	axi_interface.slave s_axi [NUM_CPUS-1:0],
	
	
	//local_memory_interface.master data_bram,
	// core management
	output logic w_valid,
	output logic [31:0] wdata,
	output logic [31:0] waddr,
	
	output logic arvalid,
	input logic rvalid,
	output logic [31:0] raddr,
	input logic [31:0] rdata
	
	);
	axi_data result2_man [NUM_CPUS-1:0] = '{default: 0};
	
  logic id = '0;
	genvar i;
//////////implementation
	
	logic [2:0] idw;
	logic [2:0] idr;
generate
  for (i=0;i<NUM_CPUS; i=i+1) begin
     always_comb begin
  assign result2_man[i].w_valid = s_axi[i].wvalid;
  assign result2_man[i].waddr = s_axi[i].awaddr;
  assign result2_man[i].wdata = s_axi[i].wdata;
  assign result2_man[i].arvalid = s_axi[i].arvalid;
  if (s_axi[i].arvalid ) begin
  assign result2_man[i].raddr = s_axi[i].araddr;
  end
  
     end
     end
     endgenerate
   logic w;
   generate
     always_ff @ (posedge clk) begin
     if (rst)
     idw =0;
     else begin
      if ( result2_man[idw[0]].w_valid) begin
      if ( (|result2_man[idw[0]].wdata ||result2_man[idw[0]].wdata == 0))  begin
     w =idw[0];
     w_valid = result2_man[idw[0]].w_valid;
     waddr = result2_man[idw[0]].waddr;
     wdata = result2_man[idw[0]].wdata ;
     end   
     end 
     else begin 
     idw = idw +1;
     if ( result2_man[idw[0]].w_valid)
     if ( (|result2_man[idw[0]].wdata ||result2_man[idw[0]].wdata == 0))  begin 
     w=idw[0];
     w_valid = result2_man[idw[0]].w_valid;
     waddr = result2_man[idw[0]].waddr;
     wdata = result2_man[idw[0]].wdata ;
     end
     end
     idw = idw +1;
     end
     end
     endgenerate
     
  
     generate
     always_ff @ (posedge clk) begin
     if (rst)
     idr =0;
     
     else begin
     if ( rvalid & (id == 0)) begin
     assign  s_axi[0].rvalid = 1/*result2_man[0].rdata = rdata*/;
     assign s_axi[1].rvalid = 0;
     assign s_axi[0].rdata = rdata;      
      end
     else if (rvalid & (id == 1)) begin 
     assign s_axi[1].rvalid =1;
     assign s_axi[0].rvalid =0;
     assign s_axi[1].rdata = rdata;
      
     end
     else begin
     assign s_axi[0].rvalid = 0;
     assign s_axi[1].rvalid = 0;
     
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

     
logic begin_write_counter[NUM_CPUS-1:0];
logic [3:0] WRITE_COUNTER_MAX ;
assign WRITE_COUNTER_MAX = 4'b0000; 
logic[3:0] write_counter[NUM_CPUS-1:0];

  assign s_axi[0].wready=1;
  assign s_axi[1].wready=1;
generate
  for (i=0;i<NUM_CPUS; i=i+1) begin
     always_ff @(posedge clk) begin
        if (rst) begin
            s_axi[i].awready <= 1; //You want it to start at ready
            s_axi[i].bresp <= 0;
            write_counter[i] <= WRITE_COUNTER_MAX;
        end
        else begin
            if(s_axi[i].awready == 1 && s_axi[i].awvalid == 1) begin
                s_axi[i].awready <= 0;
                
                begin_write_counter[i] <= 1;
            end

          //  if(begin_write_counter[i]) begin
               else if(write_counter[i] == 0) begin
                    s_axi[i].awready <= 1;
                    write_counter[i] <= WRITE_COUNTER_MAX;
                    begin_write_counter[i] <= 0;
                    
                end
                else begin
                    write_counter[i] <= write_counter[i] - 1;
                    s_axi[i].wready <= 0;
                    
                end
           // end

            if(s_axi[i].bready == 1 && s_axi[i].wready) begin
                s_axi[i].bvalid <= 1;
                s_axi[i].bresp <= 0;
            end
            else begin
                s_axi[i].bvalid <= 0;
                s_axi[i].bresp <= 0;
            end

          /*  if(s_axi[i].wready & s_axi[i].wvalid) begin
                s_axi[i].wready <= 0;
            end*/
        end // else
         
         
         
    end // always
         
end // for        
            endgenerate

logic[3:0] read_counter[NUM_CPUS-1:0];
logic begin_read[NUM_CPUS-1:0];
logic[3:0] READ_COUNTER_MAX;

assign READ_COUNTER_MAX = 4'b0000;

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
                    s_axi[i].rvalid <= result2_man[i].rvalid;
                    s_axi[i].rdata <= result2_man[i].rdata; 
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
          
endmodule

