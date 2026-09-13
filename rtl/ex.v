`timescale 1ns / 1ns
//------------------------------------------------------------
// ex.v : 执行级 (ALU)
// 当前仅实现 OR 运算，结构上为后续指令预留 alu_op 分支
//------------------------------------------------------------
module ex (
    input  wire        rst_n,
    input  wire        alu_we,
    input  wire [4:0]  alu_wdest,
    input  wire [31:0] alu_src1,
    input  wire [31:0] alu_src2,
    input  wire [3:0]  alu_op,
    // 写回端口
    output reg         wb_we,
    output reg  [4:0]  wb_wdest,
    output reg  [31:0] wb_wdata
);

    localparam ALU_OP_OR = 4'b0001;

    reg [31:0] res;

    // 组合逻辑: 按操作码计算
    always @(*) begin
        case (alu_op)
            ALU_OP_OR: res = alu_src1 | alu_src2;
            default:   res = 32'h0;
        endcase
    end

    // 组合逻辑: 写回信息直通
    always @(*) begin
        if (!rst_n) begin
            wb_we    = 1'b0;
            wb_wdest = 5'd0;
            wb_wdata = 32'h0;
        end else begin
            wb_we    = alu_we;
            wb_wdest = alu_wdest;
            wb_wdata = res;
        end
    end

endmodule
