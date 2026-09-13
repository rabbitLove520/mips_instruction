`timescale 1ns / 1ns
//------------------------------------------------------------
// inst_rom.v : 指令存储器 (只读)
// - 按 32 位指令字组织，$readmemh 从 hex 文件加载
// - 未加载的部分填 0 (opcode=0，不是 ori，不产生任何写回，等效 nop)
//------------------------------------------------------------
module inst_rom #(
    parameter DEPTH    = 64,                 // 指令字数 (64 x 4Byte = 256B)
    parameter MEM_FILE = "inst_rom.data"     // 指令文件 (hex, 相对仿真运行目录)
)(
    input  wire        ce,      // 读使能(片选)
    input  wire [31:0] addr,    // 字节地址
    output reg  [31:0] inst     // 读出的指令
);

    reg [31:0] mem [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'h0000_0000;
        $readmemh(MEM_FILE, mem);
    end

    always @(*) begin
        if (ce)
            inst = mem[addr[31:2] % DEPTH];   // 按字取指 (忽略低 2 位字节偏移)
        else
            inst = 32'h0000_0000;
    end

endmodule
