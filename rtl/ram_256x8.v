`timescale 1ns/1ps

module ram_256x8 #(
    parameter INIT_FILE = "asm/programs/ram_256x8_init.hex"
)(
    input            clk,
    input            we,      //write enable
    input      [7:0] addr, 
    input      [7:0] datain,  //write data input
    output reg [7:0] dataout  //sychronous data output
);

    reg [7:0] mem [0:255];

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= datain;
        end
        dataout <= mem[addr];
    end

endmodule
