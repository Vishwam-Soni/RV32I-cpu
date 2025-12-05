// alu.v
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero,
    output wire        lt,   // signed less-than a < b
    output wire        ltu   // unsigned less-than
);
    wire signed [31:0] sa = a;
    wire signed [31:0] sb = b;

    always @(*) begin
        case (alu_ctrl)
            4'h0: result = a + b;                       // ADD
            4'h1: result = a - b;                       // SUB
            4'h2: result = a & b;                       // AND
            4'h3: result = a | b;                       // OR
            4'h4: result = a ^ b;                       // XOR
            4'h5: result = a << b[4:0];                 // SLL
            4'h6: result = $unsigned(a) >> b[4:0];      // SRL logical
            4'h7: result = $signed(a) >>> b[4:0];       // SRA arithmetic
            4'h8: result = (sa < sb) ? 32'h1 : 32'h0;   // SLT signed
            4'h9: result = ($unsigned(a) < $unsigned(b)) ? 32'h1 : 32'h0; // SLTU
            default: result = 32'h0;
        endcase
    end

    assign zero = (result == 32'h0);
    assign lt   = ($signed(a) < $signed(b));
    assign ltu  = ($unsigned(a) < $unsigned(b));
endmodule
