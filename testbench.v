`timescale 1ns/1ps

module testbench_mac;

    reg clk=0;
    reg rst, en;
    reg signed [7:0] a,b;

    wire signed [31:0] acc;

    // instantiate ports
    mac dut (
        .clk (clk),
        .rst (rst),
        .en (en),
        .weight (a),
        .inp (b),
        .acc (acc)
    );

    // clock
    always #5 clk = ~clk;

    // helper task

    task do_mac(input signed [7:0] av, input signed [7:0] bv);
        begin
            a = av;
            b = bv;
            en = 1;
            @(posedge clk);
            #1
            $display ("a=%4d b=%4d acc=%0d", av, bv, acc);
        end
    endtask

    initial begin
        // hold reset through 2 edges
        rst = 1; en = 0; a = 0; b = 0;
        @(posedge clk);
        @(posedge clk);
        #1 rst = 0;

        do_mac(   3,    2);   // expect 6
        do_mac(  -4,    5);   // expect -14
        do_mac( 127,  127);   // expect 16115
        do_mac(-128,  127);   // expect -141

        // hold test: en low, value must not change
        en = 0;
        @(posedge clk);
        #1 $display("hold       acc=%0d  (should be -141)", acc);

        $finish;
    end

endmodule