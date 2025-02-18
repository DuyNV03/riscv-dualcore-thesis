/*
 * Copyright © 2019 Eric Matthews,  Lesley Shannon
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

import core_manage_types::*;

interface axi_interface;

    logic arready;
    logic arvalid;
    logic [32-1:0] araddr;
    logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic [3:0] arcache;
    logic [5:0] arid;

    //read data
    logic rready;
    logic rvalid;
    logic [32-1:0] rdata;
    logic [1:0] rresp;
    logic rlast;
    logic [5:0] rid;

    //Write channel
    //write address
    logic awready;
    logic awvalid;
    logic [32-1:0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic [3:0] awcache;
    logic [5:0] awid;

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
    logic [5:0] bid;

    modport master (input arready, rvalid, rdata, rresp, rlast, rid, awready, wready, bvalid, bresp, bid,
            output arvalid, araddr, arlen, arsize, arburst, arcache, arid, rready, awvalid, awaddr, awlen, awsize, awburst, awcache, awid,
            wvalid, wdata, wstrb, wlast, bready);


    modport slave (input arvalid, araddr, arlen, arsize, arburst, arcache,
            rready,
            awvalid, awaddr, awlen, awsize, awburst, awcache, arid,
            wvalid, wdata, wstrb, wlast, awid,
            bready,
            output arready, rvalid, rdata, rresp, rlast, rid,
            awready,
            wready,
            bvalid, bresp, bid);

endinterface


