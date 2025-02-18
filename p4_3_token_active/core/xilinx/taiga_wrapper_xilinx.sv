/*
 * Copyright © 2017 Eric Matthews,  Lesley Shannon
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
 */



module taiga_wrapper_xilinx

`define MEMORY_FILE2  "D:/1_master/taigal_processor_pdf/HW_init_files/coremark.hw_init" //hello_world_103_ ,hello_world_100,Token, Taken_active,coremark,ten_num_sum, hello_world_2_9_1, hello_world_0, onehundred_num_sum, hello_world_dual_sin_tk
`define MEMORY_FILE3  "/home/demy/taiga-project/benchmarks/taiga-example-c-project/hello_world.sim_init"
import taiga_config::*;
import taiga_types::*;
import l2_config_and_types::*;
import core_manage_types::*;
 (
        input logic clk_pll,
   //    input logic clk,
       input logic rst_pll,
       // input logic rst,
        
        //l2_requester_interface.slave request [L2_NUM_PORTS-1:0],
        //output logic [31:0] if_pc,
        //output logic [31:0] decode_pc,
       output logic  o_Tx_Serial,
       output wire [7:0] o_byte_w
      //  local_memory_interface.master instruction_bram,
      //  local_memory_interface.master data_bram,
    );
     
     logic clk;   
     logic rst;
//////////////////////////////////////  
    clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk),     // output clk_out = 10 MHz
    .clk_out2(clk2),     // output clk_out2 = 90 MHz
    // Status and control signals
    .reset(rst_pll), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_pll));      // input clk_in1


///////////////////////////////////////////////////////////////
  count_clk ck (.*);

     //AXI memory ddr
    logic r_Tx_DV;
  logic o_Tx_Active;
  logic [7:0] i_Tx_Byte;
  logic [31:0] i_tx_word;
  logic o_Tx_Done;
  logic [3:0] wstrb;
  //reg o_Tx_Serial;

   
    //AXI memory ddr
    logic [31:0]axi_araddr;
    logic [1:0]axi_arburst;
    logic [3:0]axi_arcache;
    logic [5:0]axi_arid;
    logic [7:0]axi_arlen;
    logic [0:0]axi_arlock;
    logic [2:0]axi_arprot;
    logic [3:0]axi_arqos;
    logic axi_arready;
    logic [3:0]axi_arregion;
    logic [2:0]axi_arsize;
    logic axi_arvalid;
    logic [31:0]axi_awaddr;
    logic [1:0]axi_awburst;
    logic [3:0]axi_awcache;
    logic [5:0]axi_awid;
    logic [7:0]axi_awlen;
    logic [0:0]axi_awlock;
    logic [2:0]axi_awprot;
    logic [3:0]axi_awqos;
    logic axi_awready;
    logic [3:0]axi_awregion;
    logic [2:0]axi_awsize;
    logic axi_awvalid;
    logic [5:0]axi_bid;
    logic axi_bready;
    logic [1:0]axi_bresp;
    logic axi_bvalid;
    logic [31:0]axi_rdata;
    logic [5:0]axi_rid;
    logic axi_rlast;
    logic axi_rready;
    logic [1:0]axi_rresp;
    logic axi_rvalid;
    logic [31:0]axi_wdata;
    logic axi_wlast;
    logic axi_wready;
    logic [3:0]axi_wstrb;
    logic axi_wvalid;
    logic [5:0]axi_wid;
    
    logic w_done;
    logic awvalid;
    axi_interface ddr_axi();
   // axi_interface ddr_axi1();
    axi_interface manage_axi[NUM_CPUS-1:0]();
    
/*
    //AXI bus
    logic ACLK;
    logic [12:0]bus_axi_araddr;
    logic bus_axi_arready;
    logic bus_axi_arvalid;
    logic [12:0]bus_axi_awaddr;
    logic bus_axi_awready;
    logic bus_axi_awvalid;
    logic bus_axi_bready;
    logic [1:0]bus_axi_bresp;
    logic bus_axi_bvalid;
    logic [31:0]bus_axi_rdata;
    logic bus_axi_rready;
    logic [1:0]bus_axi_rresp;
    logic bus_axi_rvalid;
    logic [31:0]bus_axi_wdata;
    logic bus_axi_wready;
    logic [3:0]bus_axi_wstrb;
    logic bus_axi_wvalid;
*/
    

    
   // axi_interface m_axi();
   // avalon_interface m_avalon();
   // wishbone_interface m_wishbone();

    l2_requester_interface l2[L2_NUM_PORTS-1:0]();
    l2_memory_interface mem();
   

    logic interrupt;
    logic timer_interrupt;
    
    logic pwr;
    logic [NUM_CPUS-1:0] halt;

    
    //RAM Block
    /*always_ff @(posedge processor_clk) begin
      if (instruction_bram.en) begin
        instruction_bram.data_out <= simulation_mem.readw(instruction_bram.addr);
        simulation_mem.writew(instruction_bram.addr,instruction_bram.data_in, instruction_bram.be);
      end
      
      if (instruction_bram_1.en) begin
        instruction_bram_1.data_out <= simulation_mem_1.readw(instruction_bram_1.addr);
        simulation_mem_1.writew(instruction_bram_1.addr,instruction_bram_1.data_in, instruction_bram_1.be);
      end
    end

    always_ff @(posedge processor_clk) begin
      if (data_bram.en) begin
        data_bram.data_out <= simulation_mem.readw(data_bram.addr);
        simulation_mem.writew(data_bram.addr,data_bram.data_in, data_bram.be);
      end
      
      if (data_bram_1.en) begin
        data_bram_1.data_out <= simulation_mem_1.readw(data_bram_1.addr);
        simulation_mem_1.writew(data_bram_1.addr,data_bram_1.data_in, data_bram_1.be);
      end
    end
   */
    logic w_valid;
    logic [31:0] wdata;
    logic [31:0] waddr;
    logic rvalid;
    logic [31:0] raddr;
    logic [31:0] rdata;
    logic arvalid;
    logic [7:0] CLKS_PER_BIT;
    logic i_Tx_DV;
    logic [2:0] s_machine;
  

    l2_arbiter l2_arb (.*, .request(l2));

    axi_to_arb l2_to_mem (.*, .l2(mem));
    
  //  interconnect__ c(.*, .s_axi(manage_axi), .i_Tx_DV(i_Tx_DV));
   sp_inter ss (.*, .s_axi(manage_axi),.i_Tx_DV(i_Tx_DV));
    core_management c_man(.*);
    
    uart_tx  UART_TX_INST
    (.i_Clock(clk),
     .i_Tx_DV(i_Tx_DV),
     .i_Tx_Byte(i_Tx_Byte),
     .o_Tx_Active(o_Tx_Active),
     .i_tx_word(i_tx_word),
     .o_Tx_Serial(o_Tx_Serial),
     .o_Tx_Done(o_Tx_Done),
     .CLKS_PER_BIT(CLKS_PER_BIT),
     .byte_w(o_byte_w),
     .s_machine(s_machine),
     .wstrb(wstrb)
     );
    
    taiga uut (.* ,.l2(l2[0]), .halt(halt[0]), .s_axi(manage_axi[0]));
    taiga uut_1 (.*, .l2(l2[1]), .halt(halt[1]), .s_axi(manage_axi[1]));
   

  // axi_mem_sim #(`MEMORY_FILE3) ddr_interface1 (.*, .axi(ddr_axi1), .if_pc(), .dec_pc());
   axi_HWmem #(`MEMORY_FILE2, /*4096*/8192) ddr_interface (.*, .axi(ddr_axi));
   
    assign ddr_axi.araddr = axi_araddr;
    assign ddr_axi.arburst = axi_arburst;
    assign ddr_axi.arcache = axi_arcache;
    assign ddr_axi.arid = axi_arid;
    assign ddr_axi.arlen = axi_arlen;
    assign axi_arready = ddr_axi.arready;
    assign ddr_axi.arsize = axi_arsize;
    assign ddr_axi.arvalid = axi_arvalid;
   /* 
    assign ddr_axi1.araddr = axi_araddr;
    assign ddr_axi1.arburst = axi_arburst;
    assign ddr_axi1.arcache = axi_arcache;
    assign ddr_axi1.arid = axi_arid;
    assign ddr_axi1.arlen = axi_arlen;
   // assign axi_arready = ddr_axi1.arready; // canceled when hwMem works
    assign ddr_axi1.arsize = axi_arsize;
    assign ddr_axi1.arvalid = axi_arvalid;
*/
    assign ddr_axi.awaddr = axi_awaddr;
    assign ddr_axi.awburst = axi_awburst;
    assign ddr_axi.awcache = axi_awcache;
    assign ddr_axi.awid = axi_awid;
    assign ddr_axi.awlen = axi_awlen;
    assign axi_awready = ddr_axi.awready; 
    assign ddr_axi.awvalid = axi_awvalid;
/*
    assign ddr_axi1.awaddr = axi_awaddr;
    assign ddr_axi1.awburst = axi_awburst;
    assign ddr_axi1.awcache = axi_awcache;
    assign ddr_axi1.awid = axi_awid;
    assign ddr_axi1.awlen = axi_awlen;
//    assign axi_awready = ddr_axi1.awready; // canceled when hwMem works
    assign ddr_axi1.awvalid = axi_awvalid;
  */ 
    assign axi_bid = ddr_axi.bid;
    assign ddr_axi.bready = axi_bready;
    assign axi_bresp = ddr_axi.bresp;
    assign axi_bvalid = ddr_axi.bvalid;
/*    
    // assign axi_bid = ddr_axi1.bid; // canceled when hwMem works
     assign ddr_axi1.bready = axi_bready;
   //  assign axi_bresp = ddr_axi.bresp; // canceled when hwMem works
   // assign axi_bvalid = ddr_axi.bvalid; // canceled when hwMem works
  */  
   assign axi_rdata = ddr_axi.rdata;
    assign axi_rid = ddr_axi.rid;
    assign axi_rlast = ddr_axi.rlast;
    assign ddr_axi.rready = axi_rready;
    assign axi_rresp = ddr_axi.rresp;
    assign axi_rvalid = ddr_axi.rvalid;
    /*
    // assign axi_rdata = ddr_axi1.rdata;// canceled when hwMem works
  //  assign axi_rid = ddr_axi1.rid;// canceled when hwMem works
  //  assign axi_rlast = ddr_axi1.rlast;// canceled when hwMem works
    assign ddr_axi.rready = axi_rready;
   // assign axi_rresp = ddr_axi1.rresp;// canceled when hwMem works
   // assign axi_rvalid = ddr_axi1.rvalid;// canceled when hwMem works
*/
   assign ddr_axi.wdata = axi_wdata;
    assign ddr_axi.wlast = axi_wlast;
    assign axi_wready = ddr_axi.wready;
    assign ddr_axi.wstrb = axi_wstrb;
    assign ddr_axi.wvalid = axi_wvalid;
/*
    assign ddr_axi1.wdata = axi_wdata;
    assign ddr_axi1.wlast = axi_wlast;
   // assign axi_wready = ddr_axi1.wready; // canceled when hwMem works
    assign ddr_axi1.wstrb = axi_wstrb;
    assign ddr_axi1.wvalid = axi_wvalid;
*/
     
endmodule
