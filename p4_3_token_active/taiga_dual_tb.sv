

`timescale 1ns/1ns


import taiga_config::*;
import taiga_types::*;
import l2_config_and_types::*;

`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/taiga-example-c-project/hello_world.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/sum/sum.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/sum/sum11.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/taiga/examples/zedboard/dhrystone.riscv.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/example-pointer-c/pointer.sim_init"
//`define MEMORY_FILE "/home/demy/taiga-project/benchmarks/dual-coremark/coremark.sim_init"
`define MEMORY_FILE2  "/home/demy/taiga-project/benchmarks/taiga-example-c-project/hello_world.hw_init"
`define  UART_LOG  "/home/demy/taiga-project/uart.log"

module taiga_dual_tb();

    //logic clk;
    logic clk_pll;
    logic rst_pll;
   // logic rst;
    logic  o_Tx_Serial;
    wire [7:0] o_byte_w;
    // Testbench uses a 500 MHz clock
  // Want to interface to 125*10^6 baud UART
  // 500000000 / 125000000 = 4 Clocks Per Bit.
  taiga_wrapper_xilinx tb(.*);
    always
       // #15 clk = ~clk;
       #5 clk_pll = ~clk_pll;

    initial begin
       // clk = 0;
        clk_pll = 0;
       // interrupt = 0;
        //timer_interrupt = 0;
        rst_pll = 0;
       // rst = 0;

       // simulation_mem.load_program(`MEMORY_FILE, RESET_VEC); //local memory
       // simulation_mem_1.load_program(`MEMORY_FILE, RESET_VEC);

     do_reset();
      
        #1800000;

    end

    task do_reset;
    begin
        
        #1000 rst_pll = 1'b1;
        #1000 rst_pll = 1'b0;
      //  #5000 rst = 1'b1;
       // #5000 rst = 1'b0;
    end
    endtask

    

endmodule