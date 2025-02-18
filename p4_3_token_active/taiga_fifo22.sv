/*
 * Copyright © 2017-2020 Eric Matthews,  Lesley Shannon
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Initial code developed under the supervision of Dr. Lesley Shannon,
 * Reconfigurable Computing Lab, Simon Fraser University.
 *
 * Author(s):
 *             Eric Matthews <ematthew@sfu.ca>
               Demyana Emil <dem11@fayoum.edu.eg>
 */

/*
 *  FIFOs Not underflow/overflow safe.
 *  Intended for small FIFO depths.
 *  For continuous operation when full, enqueing side must inspect pop signal
 */
module taiga_fifo22
    import taiga_config::*;
    import riscv_types::*;
    import taiga_types::*;
    #(
        parameter DATA_WIDTH = 70, 
        parameter FIFO_DEPTH = 4
    )
    (
        input logic clk,
        input logic rst,
        fifo_interface.structure fifo,
        output logic [$clog2(FIFO_DEPTH)-1:0] size
    );

   localparam LOG2_FIFO_DEPTH = $clog2(FIFO_DEPTH);
    ////////////////////////////////////////////////////
    //Implementation
    //If depth is one, the FIFO can be implemented with a single register
    generate if (FIFO_DEPTH == 1) begin
        always_ff @ (posedge clk) begin
            if (rst)
                fifo.valid <= 0;
            else
                fifo.valid <= fifo.push | (fifo.valid & ~fifo.pop);
        end
        assign fifo.full = fifo.valid;

        always_ff @ (posedge clk) begin
            if (fifo.potential_push)
                fifo.data_out <= fifo.data_in;
        end
       assign size = fifo.valid;
    end
    //If depth is two, the FIFO can be implemented with two registers
    //connected as a shift reg for the same resources as a LUTRAM FIFO
    //but with better timing
    else if (FIFO_DEPTH == 2) begin
        logic [DATA_WIDTH-1:0] shift_reg [FIFO_DEPTH];
        logic [LOG2_FIFO_DEPTH:0] inflight_count;
        ////////////////////////////////////////////////////
        //Occupancy Tracking
        always_ff @ (posedge clk) begin
            if (rst)
                inflight_count <= 0;
            else if (fifo.pop == 0 || fifo.pop == 1)
            if (fifo.push ==0 || fifo.push==1)
                inflight_count <= inflight_count + (LOG2_FIFO_DEPTH+1)'(fifo.pop) - (LOG2_FIFO_DEPTH+1)'(fifo.push);
        end

        assign fifo.valid = inflight_count[LOG2_FIFO_DEPTH];
        assign fifo.full = fifo.valid & ~|inflight_count[LOG2_FIFO_DEPTH-1:0];

        always_ff @ (posedge clk) begin
            if (fifo.push) begin
                shift_reg[0] <= fifo.data_in;
                shift_reg[1] <= shift_reg[0];
            end
        end
           
        assign fifo.data_out = shift_reg[~inflight_count[0]];
        
        always_comb begin
       if (fifo.full)
       size = 2;
       else if  (fifo.valid)
       size = 1;
       else
       size = 0;
       end
    end
    else begin
        //Force FIFO depth to next power of 2
        (* ramstyle = "MLAB, no_rw_check" *) logic [DATA_WIDTH-1:0] lut_ram [(2**LOG2_FIFO_DEPTH)];
        logic [LOG2_FIFO_DEPTH-1:0] write_index;
        logic [LOG2_FIFO_DEPTH-1:0] read_index;
        logic [LOG2_FIFO_DEPTH:0] inflight_count;
        ////////////////////////////////////////////////////
        //Occupancy Tracking
        always_ff @ (posedge clk) begin
            if (rst)
                inflight_count <= 0;
            else if (fifo.pop ==0 || fifo.pop == 1)
            if (fifo.push ==0 || fifo.push==1)
                inflight_count <= inflight_count + (LOG2_FIFO_DEPTH+1)'(fifo.pop) - (LOG2_FIFO_DEPTH+1)'(fifo.push);
        end

        assign fifo.valid = inflight_count[LOG2_FIFO_DEPTH];
        assign fifo.full = fifo.valid & ~|inflight_count[LOG2_FIFO_DEPTH-1:0];
        logic empty ;
        logic push_f;
        logic pop_f;
        
        always_ff @ (posedge clk) begin
            push_f <= fifo.push;
            pop_f <= fifo.pop;
        end
        assign empty =(read_index == write_index && (push_f==0 && pop_f == 1));
        always_ff @ (posedge clk) begin
            if (rst) begin
                read_index <= '0;
                write_index <= '0;
            end
            else begin
            if (fifo.pop == 1 || fifo.pop == 0) begin
               if (~empty)
                read_index <= read_index + LOG2_FIFO_DEPTH'(fifo.pop);
             
                end
             if ((fifo.push == 1 || fifo.push ==0))
                write_index <= write_index + LOG2_FIFO_DEPTH'(fifo.push);
            end
            
        end
     

        always_ff @ (posedge clk) begin // it was always_ff
            if (fifo.potential_push)
                lut_ram[write_index] = fifo.data_in;
          //  else
            //lut_ram[write_index] = 0;
            
        end
        
        assign fifo.data_out = lut_ram[read_index];
      
        assign size = (fifo.full == 1) ? '1 : ((LOG2_FIFO_DEPTH)'(write_index) - (LOG2_FIFO_DEPTH)'(read_index)) ;
    end
    
    endgenerate
    
    

    ////////////////////////////////////////////////////
  
endmodule
