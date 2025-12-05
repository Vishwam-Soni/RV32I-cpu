// tb.v
`timescale 1ns/1ps
module tb;
    reg clk = 0;
    reg reset = 1;

    // instantiate CPU
    cpu_top cpu(.clk(clk), .reset(reset));

    // 10 ns period => 100 MHz
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb);

        #12 reset = 0;

        // run a bunch of cycles
        #200 $display("Simulation done");
        $finish;
    end
endmodule
