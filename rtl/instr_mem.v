// instr_mem.v 
module instr_mem #(
    parameter DEPTH_WORDS = 4096
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:DEPTH_WORDS-1];
    integer i;

    initial begin
        // default = NOP
        for (i = 0; i < DEPTH_WORDS; i = i + 1)
            mem[i] = 32'h00000013;

        // Hardcoded instructions:
        mem[0] = 32'h00000293;  // addi x5, x0, 0
        mem[1] = 32'h00500313;  // addi x6, x0, 5
        mem[2] = 32'h006283B3;  // add  x7, x5, x6
        mem[3] = 32'h00000013;  // nop
        mem[4] = 32'h0000006F;  // jal x0, 0    (infinite loop)
    end

    assign instr = mem[addr[31:2]];
endmodule
