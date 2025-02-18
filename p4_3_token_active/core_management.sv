
import core_manage_types::*;


module core_management #( parameter DEPTH =32)
(
       
       input logic clk,
       input logic rst,
       
      input logic pwr,
      
     input logic w_valid,
     input logic awvalid,
	input logic [31:0] wdata,
	input logic [31:0] waddr,
	output logic w_done,
	
	input logic arvalid, 
	output logic rvalid,
	input logic [31:0] raddr,
/*(* keep = "true" *)*/	output logic [31:0] rdata,
      output logic [NUM_CPUS-1:0] halt
       );

    IO_manage_t map[DEPTH-1:0] ='{default: 0};   
    
    logic ht [1:0] ;
    assign ht[1] = map[1].halt;
    assign ht[0] = map[0].halt;
    
   generate 
      assign halt [0] = ht [0];
      assign halt [1] = ht [1];
   endgenerate
/////////////////////////////////////////////
///////AXI implementations 
 genvar i;
 generate
 always_ff @ (posedge clk or posedge rst) begin 
     if (rst) begin
            map[0].halt =0;
            w_done = 0;
            for( int j=1; j<NUM_CPUS; j=j+1) begin
                map[j].halt = 1; 
                end
               end
               
          else begin
        if (w_valid && pwr && (waddr == WADDR_MAN) && awvalid) begin
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
	    w_done = 0;
      end
      else
      w_done = 1;
       
   for (int i=1; i <NUM_CPUS ; i=i+1) begin
    if (map[i].halt == 0) begin
    map[4]=i;
    end
    else begin
    map[4]=0;
    end
   end
   end

 end
 endgenerate
  
  
   always_comb begin
    if(arvalid & pwr) begin
     rdata = map[raddr[$clog2(DEPTH)-1:0]]; 
     rvalid = 1;
     end        
     else begin
     rvalid = 0;
      rdata = 0;
      end
        end

       generate
        for( i=0;i<NUM_CPUS; i=i+1) begin
        always_ff @ (posedge clk) begin
          if (rst) begin
          if (i==0)
          map[i].worvec = 1;
          else
          map[i].worvec = 0;
          end
         else begin
           if (map[i].halt == 0) begin
           map[i].woavec = 1; // it means that the core executes a task at an address which isn't the reset vec
           if (i == 0)
           map[i].worvec = 1;
           else
           map[i].worvec = 0;
           end
           else /*if (map[i].halt == 1)*/ begin
           map[i].woavec = 0;
           map[i].worvec = 0;
           end
           
        end
      end
     end
      endgenerate

   endmodule
