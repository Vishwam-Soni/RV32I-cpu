// imm_gen.v
module imm_gen (
    input  wire [31:0] instr,
    input  wire [1:0]  imm_sel, // 00=I,01=S,10=B,11=U/J (top level distinguishes J vs U by opcode)
    output reg  [31:0] imm_out
);
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (imm_sel)
            2'b00: begin // I-type
                imm_out = {{20{instr[31]}}, instr[31:20]};
            end
            2'b01: begin // S-type
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            2'b10: begin // B-type (branch) imm[12|10:5|4:1|11] <<1
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            2'b11: begin // J or U
                if (opcode == 7'b1101111) begin // JAL
                    imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                end else begin // U-type (LUI/AUIPC): top 20 bits << 12
                    imm_out = {instr[31:12], 12'b0};
                end
            end
            default: imm_out = 32'h0;
        endcase
    end
endmodule
