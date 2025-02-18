


interface c2snoopy_request;

//logic cpu_id;
logic wnr;
logic [31:0] addr;
//logic [31:0] data; // this is can be set during reading from another cache
//logic ack [1:0]; // ack[0] to ack on what had been sent and ack[1] the address is existing and i want the data that on that address during update request
logic valid; // to differ the wnr signal during reading and reset and in case of no read no write
modport master (output wnr, valid, addr);
modport slave ( input wnr, addr, valid); 

endinterface

interface cache2snoopy_update;

//logic cpu_id;
logic [31:0] addr;
logic ack;
modport master ( output addr, input ack);
modport slave (input addr, output ack);

endinterface

interface snoopy2cache_update_return;

//logic cpu_id;
logic [31:0] addr;
logic [31:0] data;
logic ack;
modport master ( input addr, output data, ack);
modport slave (output addr, input ack, data);

endinterface
