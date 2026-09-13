`timescale 1ns / 1ns
//------------------------------------------------------------
// mips_core.v : 单周期 MIPS 顶层 (当前仅支持 ori 指令)
// 每个时钟周期组合逻辑依次完成: 取指 -> 译码 -> 读寄存器 -> ALU
// 时钟上升沿同时做两件事: PC 更新为 PC+4、寄存器堆写回
//------------------------------------------------------------
module mips_core #(
    parameter MEM_FILE = "inst_rom.data"
)(
    input  wire        clk,
    input  wire        rst_n,     // 低电平同步复位
    // 写回端口引出 (供 testbench 观测)
    output wire        wb_we,
    output wire [4:0]  wb_wdest,
    output wire [31:0] wb_wdata
);

    wire [31:0] pc;
    wire [31:0] inst;

    //---------------- IF : 取指 ----------------
    pc_reg u_pc (
        .clk   (clk),
        .rst_n (rst_n),
        .pc    (pc)
    );

    inst_rom #(
        .MEM_FILE (MEM_FILE)
    ) u_im (
        .ce   (1'b1),
        .addr (pc),
        .inst (inst)
    );

    //---------------- ID : 译码 + 读寄存器 ----------------
    wire [4:0]  raddr1, raddr2;
    wire [31:0] rdata1, rdata2;
    wire        alu_we;
    wire [4:0]  alu_wdest;
    wire [31:0] alu_src1, alu_src2;
    wire [3:0]  alu_op;

    id u_id (
        .rst_n     (rst_n),
        .inst      (inst),
        .raddr1    (raddr1),
        .rdata1    (rdata1),
        .raddr2    (raddr2),
        .rdata2    (rdata2),
        .alu_we    (alu_we),
        .alu_wdest (alu_wdest),
        .alu_src1  (alu_src1),
        .alu_src2  (alu_src2),
        .alu_op    (alu_op)
    );

    regfile u_rf (
        .clk    (clk),
        .we     (wb_we),        // 写回端口直接接到寄存器堆写端
        .waddr  (wb_wdest),
        .wdata  (wb_wdata),
        .raddr1 (raddr1),
        .rdata1 (rdata1),
        .raddr2 (raddr2),
        .rdata2 (rdata2)
    );

    //---------------- EX : 执行 ----------------
    ex u_ex (
        .rst_n     (rst_n),
        .alu_we    (alu_we),
        .alu_wdest (alu_wdest),
        .alu_src1  (alu_src1),
        .alu_src2  (alu_src2),
        .alu_op    (alu_op),
        .wb_we     (wb_we),
        .wb_wdest  (wb_wdest),
        .wb_wdata  (wb_wdata)
    );

endmodule
