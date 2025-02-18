
import core_manage_types::*;


module core_management #( parameter DEPTH =32)
(
       
       input logic clk,
       input logic rst,
       
      input logic pwr,
      
     // input logic [31:0] wb_rd,
      //input logic [31:0] wb_rd_data,
     // axi_interface.slave s_axi,
     input w_valid,
	input logic [31:0] wdata,
	input logic [31:0] waddr,
	
	input logic arvalid, 
	output logic rvalid,
	input logic [31:0] raddr,
	output logic [31:0] rdata,
      output logic [NUM_CPUS-1:0] halt
       );

    IO_manage_t map[DEPTH-1:0] ='{default: 0};   
    
    
    assign halt[1] = map[1].halt;
    assign halt[0] = map[0].halt;
    
   
      
/////////////////////////////////////////////
///////AXI implementations 
 logic [4:0] j;
genvar i;
generate
always_comb begin
if (rst) begin
map[0].halt =0;
map[0].worvec = 1;

for( int j=1; j<NUM_CPUS; j=j+1) begin
map[j].halt = 1; end
end

else begin 

if (w_valid & pwr && (waddr == ADDR)) begin
            case(wdata) 
            HALTC1:  map[1].halt = 1;
            NHALTC1: map[1].halt = 0;
            HALTC2:  map[2].halt = 1;
	        NHALTC2: map[2].halt = 0;
	        HALTC3:  map[3].halt =1;
	        NHALTC3: map[3].halt = 0; 
	        HALTC0:  map[0].halt = 1;
	        NHALTC0: map[0].halt =0;
	        default: ;// map[s_axi[i].awaddr[$clog2(DEPTH)-1:0]] <= s_axi[i].wdata ; 
	    endcase
      end
      
       
   for (int i=1; i <NUM_CPUS ; i=i+1) begin
    if (map[i].halt == 0) begin
    map[4]=i;
    end
    else begin
    map[4]=0;
    end
 end
  if(arvalid & pwr) begin
     rdata = map[raddr[$clog2(DEPTH)-1:0]]; 
     rvalid = 1;
     end        
     else
     rvalid = 0;
end // else

end
endgenerate

       generate
        for( i=0;i<NUM_CPUS; i=i+1) begin
        always_comb begin
           if (map[i].halt == 0)
           map[i].woavec = 1; // it means that the core executes a task at an address which isn't the reset vec
           else if (map[i].halt == 1) begin
           map[i].woavec = 0;
           map[i].worvec = 0;
           end
        end
        end
      endgenerate
 /*
  generate 
  
  for (i=1; i <NUM_CPUS ; i=i+1) begin
  always_comb begin
   if (map[i].halt == 0) begin
    map[4]=i;
    map[0].halt =1;
    end
    else begin
    map[4]=0;
    map[0].halt =0;
    end
 
   end
   end
   
   endgenerate*/
   endmodule
