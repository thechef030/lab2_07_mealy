`timescale 1ns/1ps

module tb_mealy_toggle;

    reg clk=0, rst=1;
    integer checks=0;

    always #5 clk=~clk;

    task step;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task check(input condition, input [8*100-1:0] description);
    begin
        checks=checks+1;
        if (condition !== 1'b1) begin
            $display("LAB2_FAIL %0s time=%0t",description,$time);
            $fatal(1,"check failed");
        end
    end
    endtask

    task finish;
    begin
        $display("LAB2_PASS mealy_toggle checks=%0d",checks);
        $finish;
    end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0,tb_mealy_toggle);
    end

    initial begin
        #1000000;
        $fatal(1,"watchdog timeout");
    end

    reg enable=0, bit_in=0;
    wire state;
    wire [1:0] value;

    mealy_toggle dut(clk,rst,enable,bit_in,state,value);

    initial begin
        step;
        check({state,value}===3'b000,"reset input zero");
        rst=0;

        bit_in=1;
        #1;
        check({state,value}===3'b010,"S0 input changes between clocks");

        step;
        check({state,value}===3'b010,"disabled state still has Mealy output");

        enable=1;
        step;
        check({state,value}===3'b101,"transition to S1");

        bit_in=0;
        #1;
        check({state,value}===3'b100,"S1 input zero immediately");

        step;
        check(state===1,"input zero holds S1");

        bit_in=1;
        #1;
        check(value===1,"S1 pre-edge value");

        step;
        check({state,value}===3'b010,"transition to S0");

        step;
        check(state===1,"toggle again");

        rst=1;
        step;
        check({state,value}===3'b010,"reset state with input one");

        bit_in=0;
        #1;
        check(value===0,"clear combinational output");

        finish;
    end

endmodule
