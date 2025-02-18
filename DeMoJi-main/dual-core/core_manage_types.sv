
package core_manage_types;

parameter NUM_CPUS = 2;
//parameter C_M_AXI_ADDR_WIDTH =32;
typedef struct packed{
        logic worvec;
        logic woavec;
        logic halt;
        logic [28:0] data;
    } IO_manage_t;
   
 typedef struct packed{
      logic rvalid;
      logic [31:0] raddr;
      logic arvalid;
      logic vra;
      logic [31:0] rdata;
      logic w_valid;
      logic [31:0] wdata;
      logic [31:0] waddr;
      } axi_data;
typedef enum logic [31:0] {
	HALTC1 = 32'h00000000,
	NHALTC1 = 32'h00000001,
	HALTC2 = 32'h00000002, // for the future
	NHALTC2 = 32'h00000003, // for the future
	HALTC3 = 32'h00000004,  // for the future
	NHALTC3 = 32'h00000005,  // for the future
	HALTC0  = 32'h00000006,
	NHALTC0 = 32'h00000007
} halt_t ;
typedef enum logic [31:0] {ADDR =32'h80000000} addr_t;
    endpackage