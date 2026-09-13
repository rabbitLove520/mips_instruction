`timescale 1ns / 1ns
//------------------------------------------------------------
// tb_mips_ori.v : ori 指令自动化测试 (自检查 testbench)
// 1. 加载 inst_rom.data 中的 6 条 ori 指令
// 2. 监视顶层写回端口 (wb_we/wb_wdest/wb_wdata), 维护"影子寄存器堆"
//    —— 验证的是 CPU 对外的写回行为, 不窥探内部信号
// 3. 若 CPU 出现"写 $0"的行为, 直接记为 ERROR
// 4. 执行完后逐项比对预期值, 输出 PASS/ERROR 与总结论
//------------------------------------------------------------
module tb_mips_ori;

    reg  clk;
    reg  rst_n;
    wire        wb_we;
    wire [4:0]  wb_wdest;
    wire [31:0] wb_wdata;

    // 例化被测 CPU (MEM_FILE 相对仿真运行目录, 即 sim/)
    mips_core #(
        .MEM_FILE ("inst_rom.data")
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .wb_we    (wb_we),
        .wb_wdest (wb_wdest),
        .wb_wdata (wb_wdata)
    );

    // 50 MHz 时钟
    initial clk = 1'b0;
    always #10 clk = ~clk;

    integer errors;
    integer i;

    reg [31:0] shadow   [0:31];   // 影子寄存器堆: 记录 CPU 实际写回的内容
    reg [31:0] expected [0:31];   // 期望结果

    // 监视写回端口
    always @(posedge clk) begin
        if (rst_n && wb_we) begin
            if (wb_wdest == 5'd0) begin
                $display("[%0t] ERROR: CPU 试图写 $0 (data=%08h)", $time, wb_wdata);
                errors = errors + 1;
            end else begin
                shadow[wb_wdest] = wb_wdata;
                $display("[%0t] 写回: $%0d <= 0x%08h", $time, wb_wdest, wb_wdata);
            end
        end
    end

    task check;
        input [4:0]  r;
        input [31:0] exp;
        begin
            if (shadow[r] !== exp) begin
                $display("ERROR: $%0d = 0x%08h, 期望 0x%08h", r, shadow[r], exp);
                errors = errors + 1;
            end else begin
                $display("PASS : $%0d = 0x%08h", r, shadow[r]);
            end
        end
    endtask

    initial begin
        errors = 0;
        for (i = 0; i < 32; i = i + 1) begin
            shadow[i]   = 32'h0;
            expected[i] = 32'h0;
        end
        // 对应 inst_rom.data 中 6 条指令的期望结果
        expected[1] = 32'h0000_11FF;  // 0x1100 | 0x00FF
        expected[2] = 32'h0000_ABCD;
        expected[3] = 32'h0000_BBFD;  // 0xABCD | 0x1234
        expected[4] = 32'h0000_FFFF;  // 零扩展: 不是 0xFFFFFFFF
        expected[0] = 32'h0000_0000;  // 写 $0 必须被忽略

        // 复位 2 个时钟
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        // 单周期 CPU: 6 条指令 6 拍执行完, 多等几拍再检查
        repeat (12) @(posedge clk);

        check(5'd0, expected[0]);
        check(5'd1, expected[1]);
        check(5'd2, expected[2]);
        check(5'd3, expected[3]);
        check(5'd4, expected[4]);

        if (errors == 0)
            $display("==== ALL TESTS PASSED ====");
        else
            $display("==== TEST FAILED: %0d error(s) ====", errors);
        $finish;
    end

endmodule
