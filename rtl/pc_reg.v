`timescale 1ns / 1ns
//------------------------------------------------------------
// pc_reg.v : 程序计数器 (PC)
// 复位时 PC = 0x0000_0000，之后每个时钟上升沿 PC = PC + 4
//------------------------------------------------------------
module pc_reg (
    input  wire        clk,     // 时钟
    input  wire        rst_n,   // 低电平同步复位
    output reg  [31:0] pc       // 当前取指地址
);

    always @(posedge clk) begin
        if (!rst_n)
            pc <= 32'h0000_0000;
        else
            pc <= pc + 32'd4;    // 顺序执行：下一条指令地址
    end

endmodule
