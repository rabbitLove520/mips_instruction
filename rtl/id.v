`timescale 1ns / 1ns
//------------------------------------------------------------
// id.v : 译码级
// ori 指令格式 (I 型):
//   31..26 | 25..21 | 20..16 | 15..0
//   001101 |   rs   |   rt   | imm16
// 语义: rt <- rs | {16'h0000, imm}   (立即数零扩展)
//------------------------------------------------------------
module id (
    input  wire        rst_n,
    input  wire [31:0] inst,
    // 寄存器堆读端口
    output wire [4:0]  raddr1,
    input  wire [31:0] rdata1,
    output wire [4:0]  raddr2,
    input  wire [31:0] rdata2,
    // 译码结果 -> EX
    output reg         alu_we,      // 是否写回
    output reg  [4:0]  alu_wdest,   // 写回目的寄存器 (rt)
    output reg  [31:0] alu_src1,    // 操作数1: rs 的值
    output reg  [31:0] alu_src2,    // 操作数2: 零扩展后的立即数
    output reg  [3:0]  alu_op       // ALU 操作码
);

    localparam OP_ORI    = 6'b001101;   // ori 的 opcode
    localparam ALU_OP_OR = 4'b0001;

    wire [5:0]  op  = inst[31:26];
    wire [4:0]  rs  = inst[25:21];
    wire [4:0]  rt  = inst[20:16];
    wire [15:0] imm = inst[15:0];

    always @(*) begin
        if (!rst_n) begin
            // 复位期间不产生任何写回
            alu_we    = 1'b0;
            alu_wdest = 5'd0;
            alu_src1  = 32'h0;
            alu_src2  = 32'h0;
            alu_op    = ALU_OP_OR;
        end else if (op == OP_ORI) begin
            alu_we    = (rt != 5'd0);        // 目的寄存器是 $0 则不写 (第一重保护)
            alu_wdest = rt;
            alu_src1  = rdata1;
            alu_src2  = {16'h0000, imm};     // 关键: 零扩展 (addi 才是符号扩展)
            alu_op    = ALU_OP_OR;
        end else begin
            // 其他指令尚未实现: 不写任何寄存器 (等效 nop)
            alu_we    = 1'b0;
            alu_wdest = 5'd0;
            alu_src1  = 32'h0;
            alu_src2  = 32'h0;
            alu_op    = ALU_OP_OR;
        end
    end

    // 读寄存器地址: 恒为指令中的 rs / rt 字段
    assign raddr1 = rs;
    assign raddr2 = rt;

endmodule
