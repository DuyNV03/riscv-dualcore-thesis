

`timescale 1ns/1ns

import tb_tools::*;
import taiga_config::*;
import taiga_types::*;
import l2_config_and_types::*;

//`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/taiga-example-c-project/hello_world.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/sum/sum.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/sum/sum11.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/taiga/examples/zedboard/dhrystone.riscv.sim_init"
//`define  MEMORY_FILE  "/home/demy/taiga-project/benchmarks/example-pointer-c/pointer.sim_init"
`define MEMORY_FILE "/home/demy/taiga-project/benchmarks/dual-coremark/coremark.sim_init"
`define  UART_LOG  "/home/demy/taiga-project/uart.log"

module taiga_dual_tb();

    logic simulator_clk;
    logic simulator_resetn;

   
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

    axi_interface ddr_axi();
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
    //axi block diagram outputs
    logic processor_reset;
    logic processor_clk;
    

    logic clk;
    logic rst;

    assign rst = resetn;
    assign processor_clk= clk;
    //*****************************

    
    assign resetn = simulator_resetn;

    assign clk = simulator_clk;
    assign processor_reset = rst;

    local_memory_interface instruction_bram();
    local_memory_interface data_bram();
    
    local_memory_interface instruction_bram_1();
    local_memory_interface data_bram_1();
    
    axi_interface m_axi();
    avalon_interface m_avalon();
    wishbone_interface m_wishbone();

    l2_requester_interface l2[L2_NUM_PORTS-1:0]();
    l2_memory_interface mem();
    
    c2snoopy_request request_snoop_1 [L1_CONNECTIONS-1:0]();
    c2snoopy_request opey_1[L1_CONNECTIONS-1:0]();
    c2snoopy_request request_snoop_2 [L1_CONNECTIONS-1:0]();
    c2snoopy_request opey_2 [L1_CONNECTIONS-1:0]();

    logic interrupt;
    logic timer_interrupt;
    
    logic pwr;
    logic [NUM_CPUS-1:0] halt;

    logic[31:0] dec_pc_debug= 32'h00000000;
    logic[31:0] if2_pc_debug= 32'h00000000;

    integer output_file;

    //assign l2[1].request = 0;
  /*  assign l2[1].request_push = 0;
    assign l2[1].wr_data_push = 0;
    assign l2[1].inv_ack = l2[1].inv_valid;
    assign l2[1].rd_data_ack = l2[1].rd_data_valid;*/

    sim_mem simulation_mem = new();
    sim_mem simulation_mem_1 = new ();


    //RAM Block
    always_ff @(posedge processor_clk) begin
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
   
    logic [31:0] wb_rd;
    logic [31:0] wb_rd_data;
    logic w_valid;
    logic [31:0] wdata;
    logic [31:0] waddr;
    logic rvalid;
    logic [31:0] raddr;
    logic [31:0] rdata;
    logic arvalid;
    
   // design_2 infra(.*);

    l2_arbiter l2_arb (.*, .request(l2));

    axi_to_arb l2_to_mem (.*, .l2(mem));
    
    interconnec c(.*, .s_axi(manage_axi));
    core_management c_man(.*);
    
    taiga uut (.* ,.request(request_snoop_1), .opey(opey_1),.if_pc(), .decode_pc() , .tr(),.l2(l2[0]), .halt(halt[0]), .s_axi(manage_axi[0]));
    taiga uut_1 (.*,.request(request_snoop_2),.opey(opey_2),.instruction_bram(instruction_bram_1), .data_bram(data_bram_1),.if_pc(),.decode_pc() , .tr(),.l2(l2[1]), .halt(halt[1]), .s_axi(manage_axi[1]));
   
    snoopy_protocol sn(.*, .receiver(request_snoop_1), .sender(opey_1), .sender_1(opey_2), .receiver_1(request_snoop_2));

    axi_mem_sim #(`MEMORY_FILE) ddr_interface (.*, .axi(ddr_axi), .if_pc(if2_pc_debug), .dec_pc(dec_pc_debug));

    always
        #1 simulator_clk = ~simulator_clk;

    initial begin
        simulator_clk = 0;
        interrupt = 0;
        timer_interrupt = 0;
        simulator_resetn = 0;
        pwr = 1;

        simulation_mem.load_program(`MEMORY_FILE, RESET_VEC); //local memory
        simulation_mem_1.load_program(`MEMORY_FILE, RESET_VEC);

        output_file = $fopen(`UART_LOG, "w");
      /*  if (output_file == 0) begin
            $error ("couldn't open log file");
            $finish;
        end*/

        do_reset();
      
        #1800000;

        $fclose(output_file);
        $finish;
    end

    task do_reset;
    begin
        simulator_resetn = 1'b0;
        #50 simulator_resetn = 1'b1;
        #100 simulator_resetn = 1'b0;
    end
    endtask

   /*
    assign m_axi.arready = bus_axi_arready;
    assign bus_axi_arvalid = m_axi.arvalid;
    assign bus_axi_araddr = m_axi.araddr[12:0];


    //read data
    assign bus_axi_rready = m_axi.rready;
    assign m_axi.rvalid = bus_axi_rvalid;
    assign m_axi.rdata = bus_axi_rdata;
    assign m_axi.rresp = bus_axi_rresp;

    //Write channel
    //write address
    assign m_axi.awready = bus_axi_awready;
    assign bus_axi_awaddr = m_axi.awaddr[12:0];
    assign bus_axi_awvalid = m_axi.awvalid;


    //write data
    assign m_axi.wready = bus_axi_wready;
    assign bus_axi_wvalid = m_axi. wvalid;
    assign bus_axi_wdata = m_axi.wdata;
    assign bus_axi_wstrb = m_axi.wstrb;

    //write response
    assign bus_axi_bready = m_axi.bready;
    assign m_axi.bvalid = bus_axi_bvalid;
    assign m_axi.bresp = bus_axi_bresp;
*/



    assign ddr_axi.araddr = axi_araddr;
    assign ddr_axi.arburst = axi_arburst;
    assign ddr_axi.arcache = axi_arcache;
    assign ddr_axi.arid = axi_arid;
    assign ddr_axi.arlen = axi_arlen;
    assign axi_arready = ddr_axi.arready;
    assign ddr_axi.arsize = axi_arsize;
    assign ddr_axi.arvalid = axi_arvalid;

    assign ddr_axi.awaddr = axi_awaddr;
    assign ddr_axi.awburst = axi_awburst;
    assign ddr_axi.awcache = axi_awcache;
    assign ddr_axi.awid = axi_awid;
    assign ddr_axi.awlen = axi_awlen;
    assign axi_awready = ddr_axi.awready;
    assign ddr_axi.awvalid = axi_awvalid;

    assign axi_bid = ddr_axi.bid;
    assign ddr_axi.bready = axi_bready;
    assign axi_bresp = ddr_axi.bresp;
    assign axi_bvalid = ddr_axi.bvalid;

    assign axi_rdata = ddr_axi.rdata;
    assign axi_rid = ddr_axi.rid;
    assign axi_rlast = ddr_axi.rlast;
    assign ddr_axi.rready = axi_rready;
    assign axi_rresp = ddr_axi.rresp;
    assign axi_rvalid = ddr_axi.rvalid;

    assign ddr_axi.wdata = axi_wdata;
    assign ddr_axi.wlast = axi_wlast;
    assign axi_wready = ddr_axi.wready;
    assign ddr_axi.wstrb = axi_wstrb;
    assign ddr_axi.wvalid = axi_wvalid;

    
    //Capture writes to UART
  /*  always_ff @(posedge processor_clk) begin
      if (m_axi.wvalid && m_axi.wready && m_axi.awaddr[13:0] == 4096) begin
            $fwrite(output_file, "%c",m_axi.wdata[7:0]);
      end
    end
//Write channel
    //write address
    logic[3:0] write_counter;
    logic begin_write_counter;
    logic [3:0] WRITE_COUNTER_MAX;
    logic [3:0] READ_COUNTER_MAX;
    assign READ_COUNTER_MAX = 4'b0101;
    assign WRITE_COUNTER_MAX = 4'b0101;
always_ff @(posedge clk) begin
        if (rst) begin
            m_axi.wready <= 0;
            m_axi.awready <= 1; //You want it to start at ready
            m_axi.bresp <= 0;
            write_counter <= WRITE_COUNTER_MAX;
        end
        else begin
            if(m_axi.awready == 1 && m_axi.awvalid == 1) begin
                m_axi.awready <= 0;
                begin_write_counter <= 1;
            end

            if(begin_write_counter) begin
                if(write_counter == 0) begin
                    m_axi.awready <= 1;
                    m_axi.wready <= 1;
                    write_counter <= WRITE_COUNTER_MAX;
                    begin_write_counter <= 0;
                end
                else begin
                    write_counter <= write_counter - 1;
                    m_axi.wready <= 0;
                end
            end

            if(m_axi.bready == 1 && m_axi.wready) begin
                m_axi.bvalid <= 1;
                m_axi.bresp <= 0;
            end
            else begin
                m_axi.bvalid <= 0;
                m_axi.bresp <= 0;
            end

            if(m_axi.wready & m_axi.wvalid) begin
                m_axi.wready <= 0;
            end
        end
    end

*/
    assign sin = 0;

endmodule
