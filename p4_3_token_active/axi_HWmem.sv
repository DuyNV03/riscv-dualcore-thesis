
import taiga_config::*;
import riscv_types::*;

module axi_HWmem #(parameter preload_file = "", parameter LINES = 4096/*16384*/)
(
        input logic clk,
        input logic rst,
        axi_interface.slave axi
);

typedef struct packed{
        logic [31:0] araddr;
        logic [7:0] arlen;
        logic [2:0] arsize;
        logic [1:0] arburst;
        logic [3:0] arcache;
        logic [5:0] arid;
    } read_request;

    typedef struct packed{
        logic [31:0] awaddr;
        logic [7:0] awlen;
        logic [2:0] awsize;
        logic [1:0] awburst;
        logic [3:0] awcache;
        logic [5:0] awid;
    } write_request;
    
 logic [XLEN-1:0] data_out_a;
 logic[$clog2(LINES)-1:0] addr_a;
 logic en_a;
 logic[$clog2(LINES)-1:0] addr_b;
 //logic en_b;
 logic[XLEN/8-1:0] be_b;
 logic[XLEN-1:0] data_in_b;
 
HWmem #(preload_file , LINES, 0 ) hardwareMem
(
.clk(clk),.* );

    localparam read_data_SM = 0;
    
    localparam READ_QUEUE_DEPTH = 8;
    localparam WRITE_QUEUE_DEPTH = 4;
    localparam WRITE_DATA_QUEUE_DEPTH = 128;

    integer write_queue_size;
    integer read_data_queue_size;
    logic[47:0] write_request_count;
    logic[47:0] read_request_count; //for address 

    int read_burst_count; // for data
    int processing_read_request;
    int processing_write_request;

logic [$clog2(READ_QUEUE_DEPTH)-1:0] size2; // corresponding to the fifo size
logic [$clog2(WRITE_DATA_QUEUE_DEPTH)-1:0] size3;
logic [$clog2(WRITE_QUEUE_DEPTH )-1:0] size4;

write_request w_request;
/*(* keep= "true" *)*/ read_request  r_request ;

fifo_interface #(.DATA_WIDTH($bits(read_request))) read_queue();

taiga_fifo22 #(.DATA_WIDTH ($bits(read_request)), .FIFO_DEPTH (READ_QUEUE_DEPTH)) read_fifo(.*,.fifo(read_queue), .size(size2));

//fifo_interface #(.DATA_WIDTH(32)) write_fifos(); // wdata

//taiga_fifo2 #(.DATA_WIDTH(32), .FIFO_DEPTH(WRITE_DATA_QUEUE_DEPTH )) write_data_fifo(.*,.fifo(write_fifos), .size(size3));

fifo_interface #(.DATA_WIDTH($bits(write_request))) write_queue(); // waddr

taiga_fifo22 #(.DATA_WIDTH($bits(write_request)), .FIFO_DEPTH(WRITE_QUEUE_DEPTH )) write_fifo(.*,.fifo(write_queue), .size(size4));


assign w_request = write_queue.data_out;
assign r_request = read_queue.data_out; 
    always_comb  begin
    /*if (read_burst_count == 0) begin
     // if (|read_queue.data_out || read_queue.data_out == 0) begin
        r_request = read_queue.data_out; // infer latch
       //     end
   end
   */
 
     
    if ((read_burst_count == r_request.arlen) && (r_request.arlen > 0) )begin
        read_queue.pop = 1;
            end
        else 
       read_queue.pop = 0;  
        end

        //araddr response
assign axi.arready = size2 < READ_QUEUE_DEPTH;

    //Read request processing
    always_comb begin
        if(axi.arvalid & axi.arready) begin
        read_queue.push = 1;
        read_queue.potential_push = 1;
            
        read_queue.data_in = {axi.araddr, axi.arlen, axi.arsize, axi.arburst, axi.arcache, axi.arid}; // start from here
          
        end
        
        else begin
         read_queue.push = 0;
        read_queue.potential_push = 0;
        read_queue.data_in = 0;
        end
    end
    //Return data
    
   assign axi.rdata = data_out_a;

        always_comb begin 
            if (size2 > 0) begin
            addr_a = r_request.araddr[14:2] + read_burst_count ;
            en_a = 1;
            end
            else begin
            en_a = 0;
            addr_a = 0;
            end
        end
        
        always_ff @ (posedge clk) begin 
            if(rst) begin
            axi.rvalid <=0;
             axi.rlast <= 0;
            read_burst_count <= 0;
            end
            else begin
               if ( en_a ) begin
                 if (axi.rready) begin
               axi.rvalid <= 1;
               axi.rid <= r_request.arid;
               
                     if(r_request.arlen == read_burst_count) begin
                      axi.rlast <= 1;
                      read_burst_count <= 0;
                     end
                     else begin
                        axi.rlast <= 0;
                        read_burst_count <= read_burst_count +1;
                     end
                end
                else begin
                axi.rvalid <=0;
                axi.rlast <= 0;
                end
            
           end
           else begin 
                axi.rvalid <=0;
                axi.rlast <= 0;
           end
        end
     end
     
   /*always_ff @(posedge clk) begin
        if(rst) begin
            axi.rvalid <= 0;
            axi.rlast <= 0;
            read_burst_count <= 0;
        end
        else begin
        if (size2 > 0) begin
         if (axi.rready) begin
           addr_a <= r_request.araddr[15:2] + read_burst_count ;
            axi.rvalid <= 1;
            axi.rid <= r_request.arid;
            if( r_request.arlen == read_burst_count) begin
                    axi.rlast <= 1;
                    read_burst_count <= 0;
                end
                
                else begin
                    read_burst_count <= read_burst_count + 1;
                    axi.rlast <= 0;
                    
                end
                
                end
            else begin
                axi.rvalid <= 0;
                axi.rlast <= 0;
            end
          end
          else begin
                axi.rvalid <= 0;
                axi.rlast <= 0;
            end
        end
       end
  */
       
//Write request processing
    always_comb begin
        if(axi.awvalid & axi.awready) begin
        write_queue.push = 1;
        write_queue.potential_push = 1;
        write_queue.data_in = {axi.awaddr, axi.awlen, axi.awsize, axi.awburst, axi.awcache, axi.awid}; // infer latch
        end
          
          else begin 
          write_queue.push = 0;
          write_queue.potential_push = 0;
          write_queue.data_in = 0;
          end
        
        //write_queue_size = size4;
    end
    assign axi.awready = size4 < WRITE_QUEUE_DEPTH;

    assign axi.wready = 1;
    
    
    //bresp
    always_comb begin
        if (rst) begin
            axi.bvalid = 0;
            axi.bresp = 0;
            axi.bid = 0;
             write_queue.pop = 0;
        end
        else if(axi.wvalid & axi.wlast) begin
            axi.bresp = 0;
            axi.bvalid =1;
            axi.bid = w_request.awid;
            write_queue.pop = 1;
        end
        else if (axi.bready) begin
            axi.bvalid =0;
            axi.bresp = 0;
            axi.bid = 0;
            write_queue.pop = 0;
        end
        else begin
        axi.bvalid = 0;
        axi.bresp = 0;
        axi.bid = 0;
        write_queue.pop = 0;
        end
    end

    //Handle write data
    always_comb begin
        if(axi.wvalid) begin
            addr_b = size4 > 0 ? w_request.awaddr[14:2] : axi.awaddr[14:2] ;
            data_in_b = size4 > 0 ? 32'h00000000 : axi.wdata ;
            be_b = size4 > 0 ? (XLEN/8)'(0) : axi.wstrb;
        end
        else begin
        addr_b = 0;
        data_in_b = 0;
        be_b = 0;
        end
    end

    
endmodule