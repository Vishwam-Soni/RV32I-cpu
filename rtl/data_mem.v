// data_mem.v  (NO dmem.hex, clean initialization)
module data_mem #(
    parameter DEPTH_WORDS = 4096
) (
    input  wire         clk,
    input  wire         we,       // write enable
    input  wire [31:0]  addr,     // byte address
    input  wire [31:0]  wd,       // write data
    output wire [31:0]  rd        // read data
);
    reg [31:0] mem [0:DEPTH_WORDS-1];
    integer i;

    initial begin
        // Initialize memory to zero
        for (i = 0; i < DEPTH_WORDS; i = i + 1)
            mem[i] = 32'h00000000;
    end

    // Synchronous WRITE (on clock edge)
    always @(posedge clk) begin
        if (we)
            mem[addr[31:2]] <= wd;   // word-aligned write
    end

    // Combinational READ
    assign rd = mem[addr[31:2]];     // word-aligned read
endmodule
