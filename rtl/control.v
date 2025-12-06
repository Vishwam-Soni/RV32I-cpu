// control.v
module control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        mem_write,
    output reg        mem_read,
    output reg        reg_write,
    output reg  [1:0] imm_sel,
    output reg        alu_src,       // 0=reg, 1=imm
    output reg  [3:0] alu_ctrl,
    output reg        branch,        // any branch
    output reg        jal,
    output reg        jalr,
    output reg        lui,
    output reg        auipc,
    output reg        load_instr     // true for loads (to select mem->reg)
);
    // opcode constants
    localparam OP_R     = 7'b0110011;
    localparam OP_I     = 7'b0010011;
    localparam OP_LOAD  = 7'b0000011;
    localparam OP_STORE = 7'b0100011;
    localparam OP_BRANCH= 7'b1100011;
    localparam OP_JAL   = 7'b1101111;
    localparam OP_JALR  = 7'b1100111;
    localparam OP_LUI   = 7'b0110111;
    localparam OP_AUIPC = 7'b0010111;

    always @(*) begin
        // defaults
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        reg_write  = 1'b0;
        imm_sel    = 2'b00;
        alu_src    = 1'b0;
        alu_ctrl   = 4'h0;
        branch     = 1'b0;
        jal        = 1'b0;
        jalr       = 1'b0;
        lui        = 1'b0;
        auipc      = 1'b0;
        load_instr = 1'b0;

        case (opcode)
            OP_R: begin // R-type
                reg_write = 1'b1;
                alu_src   = 1'b0;
                imm_sel   = 2'b00;
                case (funct3)
                    3'b000: alu_ctrl = (funct7 == 7'b0100000) ? 4'h1 : 4'h0; // SUB/ADD
                    3'b111: alu_ctrl = 4'h2; // AND
                    3'b110: alu_ctrl = 4'h3; // OR
                    3'b100: alu_ctrl = 4'h4; // XOR
                    3'b001: alu_ctrl = 4'h5; // SLL
                    3'b101: alu_ctrl = (funct7 == 7'b0100000) ? 4'h7 : 4'h6; // SRA / SRL
                    3'b010: alu_ctrl = 4'h8; // SLT
                    3'b011: alu_ctrl = 4'h9; // SLTU
                    default: alu_ctrl = 4'h0;
                endcase
            end

            OP_I: begin // ALU immediate type
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 2'b00;
                case (funct3)
                    3'b000: alu_ctrl = 4'h0; // ADDI
                    3'b111: alu_ctrl = 4'h2; // ANDI
                    3'b110: alu_ctrl = 4'h3; // ORI
                    3'b100: alu_ctrl = 4'h4; // XORI
                    3'b001: alu_ctrl = 4'h5; // SLLI
                    3'b101: alu_ctrl = (funct7[5]) ? 4'h7 : 4'h6; // SRAI / SRLI (funct7[5]=1 -> SRAI)
                    3'b010: alu_ctrl = 4'h8; // SLTI
                    3'b011: alu_ctrl = 4'h9; // SLTIU
                    default: alu_ctrl = 4'h0;
                endcase
            end

            OP_LOAD: begin
                mem_read   = 1'b1;
                load_instr = 1'b1;
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_sel    = 2'b00;
                alu_ctrl   = 4'h0; // address = base + imm
            end

            OP_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 2'b01;
                alu_ctrl  = 4'h0; // address = base + imm
            end

            OP_BRANCH: begin
                branch   = 1'b1;
                alu_src  = 1'b0;
                imm_sel  = 2'b10;
                alu_ctrl = 4'h1; // SUB used for BEQ/BNE; for SLT-based branches top-level will use lt flags
            end

            OP_JAL: begin
                jal       = 1'b1;
                reg_write = 1'b1; // write PC+4
                imm_sel   = 2'b11;
            end

            OP_JALR: begin
                jalr      = 1'b1;
                reg_write = 1'b1; // write PC+4
                imm_sel   = 2'b00;
                alu_src   = 1'b1; // base + imm (to compute target separately)
            end

            OP_LUI: begin
                lui       = 1'b1;
                reg_write = 1'b1;
                imm_sel   = 2'b11; // U-type
            end

            OP_AUIPC: begin
                auipc     = 1'b1;
                reg_write = 1'b1;
                imm_sel   = 2'b11;
            end

            default: begin
                // illegal/unsupported -> keep defaults
            end
        endcase
    end
endmodule
