`timescale 1ns / 1ns
//------------------------------------------------------------
// regfile.v : 通用寄存器堆  32 x 32bit
// - 写: 时钟上升沿同步写；$0 恒为 0，对 $0 的写被忽略
// - 读: 组合逻辑异步读
//------------------------------------------------------------
module regfile (
    input  wire        clk,
    input  wire        we,        // 写使能
    input  wire [4:0]  waddr,     // 写地址
    input  wire [31:0] wdata,     // 写数据
    input  wire [4:0]  raddr1,    // 读地址 1 (rs)
    output wire [31:0] rdata1,    // 读数据 1
    input  wire [4:0]  raddr2,    // 读地址 2 (rt)
    output wire [31:0] rdata2     // 读数据 2
);

    reg [31:0] regs [0:31];

    // 同步写；$0 不可写 (第二重保护)
    always @(posedge clk) begin
        if (we && waddr != 5'd0)
            regs[waddr] <= wdata;
    end

    // 异步读；读 $0 恒返回 0 (第一重保护)
    assign rdata1 = (raddr1 == 5'd0) ? 32'h0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? 32'h0 : regs[raddr2];

endmodule
