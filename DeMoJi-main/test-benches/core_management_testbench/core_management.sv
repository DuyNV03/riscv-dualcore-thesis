
import core_manage_types::*;


module core_management #( parameter WIDTH = 32, parameter DEPTH =32)
(
       
       input logic clk,
       input logic rst,
       
       input logic pwr,
      
      axi_interface.slave s_axi[NUM_CPUS-1:0],
      output logic [NUM_CPUS-1:0] halt
       );

    IO_manage_t map[DEPTH-1:0] ='{default: 0};   
    
    assign halt[1] = map[1].halt;
    assign halt[0] = map[0].halt;
    logic arready;
    logic arvalid;
    logic [C_M_AXI_ADDR_WIDTH -1:0] araddr;
 /*   logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic [3:0] arcache;
    logic [5:0] arid;*/

    //read data
    logic rready;
    logic rvalid;
    logic [32-1:0] rdata;
    logic [1:0] rresp;
    logic rlast;
 //   logic [5:0] rid;

    //Write channel
    //write address
    logic awready;
    logic awvalid;
    logic [32-1:0] awaddr;
 

    //write data
    logic wready;
    logic wvalid;
    logic [32-1:0] wdata;
    logic [(32/8)-1:0] wstrb;
    logic wlast;

    //write response
    logic bready;
    logic bvalid;
    logic [1:0] bresp;
    
/////////////////////////////////////////////
///////AXI implementations 
   
genvar i;
generate
for(i=0; i< NUM_CPUS; i=i+1) begin
always_ff @(posedge clk) begin
if (rst) begin
map[0].halt <=0;
map[0].worvec <= 1;

for( int j=1; j<NUM_CPUS; j=j+1) begin
map[j].halt <= 1; end
end

else begin 
if (s_axi[i].wvalid & pwr) begin
            case(s_axi[i].wdata) 
            HALTC1:  map[1].halt <= 1;
            NHALTC1: map[1].halt <= 0;
            HALTC2:  map[2].halt <= 1;
	    NHALTC2: map[2].halt <= 0;
	    HALTC3:  map[3].halt <=1;
	    NHALTC3: map[3].halt <= 0; 
	    HALTC0:  map[0].halt <= 1;
	    NHALTC0: map[0].halt <=0;
	    default: ;// map[s_axi[i].awaddr[$clog2(DEPTH)-1:0]] <= s_axi[i].wdata ; 
	    endcase
      end
end // else
end
end //for
endgenerate

logic begin_write_counter;
logic [3:0] WRITE_COUNTER_MAX ;
assign WRITE_COUNTER_MAX = 4'b0010; 
logic[3:0] write_counter;
generate
  for(i=0; i< NUM_CPUS; i=i+1) begin
     always_ff @(posedge clk) begin
        if (rst) begin
            s_axi[i].wready <= 0;
            s_axi[i].awready <= 1; //You want it to start at ready
            s_axi[i].bresp <= 0;
            write_counter <= WRITE_COUNTER_MAX;
        end
        else begin
            if(s_axi[i].awready == 1 && s_axi[i].awvalid == 1) begin
                s_axi[i].awready <= 0;
                begin_write_counter <= 1;
            end

            if(begin_write_counter) begin
                if(write_counter == 0) begin
                    s_axi[i].awready <= 1;
                    s_axi[i].wready <= 1;
                    write_counter <= WRITE_COUNTER_MAX;
                    begin_write_counter <= 0;
                end
                else begin
                    write_counter <= write_counter - 1;
                    s_axi[i].wready <= 0;
                    
                end
            end

            if(s_axi[i].bready == 1 && s_axi[i].wready) begin
                s_axi[i].bvalid <= 1;
                s_axi[i].bresp <= 0;
            end
            else begin
                s_axi[i].bvalid <= 0;
                s_axi[i].bresp <= 0;
            end

            if(s_axi[i].wready & s_axi[i].wvalid) begin
                s_axi[i].wready <= 0;
            end
        end // else
    end // always
          
            end // for
            endgenerate
            
logic[3:0] read_counter;
logic begin_read;
logic[3:0] READ_COUNTER_MAX;

assign READ_COUNTER_MAX = 4'b0010;
int k=0;
generate
  for(i=0; i< NUM_CPUS; i=i+1) begin
     always_ff @(posedge clk) begin
        if (rst) begin
            s_axi[i].rvalid <= 0;
            s_axi[i].arready <= 1; //You want it to start at ready
            s_axi[i].rresp <= 0;
            read_counter <= READ_COUNTER_MAX;
            
        end
        else begin
            if(s_axi[i].arready == 1 && s_axi[i].arvalid == 1) begin
                s_axi[i].arready <= 0;
                s_axi[i].rdata <= map[s_axi[i].araddr[$clog2(DEPTH)-1:0]]; //set the data
                begin_read <=1;
                k=k+1;
            end

            if(begin_read) begin
                if(read_counter == 0) begin
                    s_axi[i].rvalid <= 1;
                    s_axi[i].arready <= 1;
                    read_counter <= READ_COUNTER_MAX;
                    begin_read <= 0;
                end
                else begin
                    read_counter <= read_counter - 1;
                    s_axi[i].rvalid <= 0;
                end
            end

            if(s_axi[i].rvalid &&  s_axi[i].rready) begin
                s_axi[i].rvalid <= 0;
            end

        end
    end
            end // for
            endgenerate 
          
       generate
        for( i=0;i<NUM_CPUS; i=i+1) begin
        always_comb begin
           if (map[i].halt == 0)
           map[i].woavec = 1; // it means that the core executes a task
           else if (map[i].halt == 1) begin
           map[i].woavec = 0;
           map[i].worvec = 0;
           end
        end
        end
      endgenerate

   
   endmodule
