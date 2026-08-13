`timescale 1ns/1ps
module tb_hello;
  reg clk = 0;
  reg [3:0] count = 0;

  always #5 clk = ~clk;

  always @(posedge clk) count <= count + 1;

  initial begin
    $dumpfile("sim/hello.vcd");
    $dumpvars(0, tb_hello);
    $display("Simulation starting");
    #100;
    $display("Final count = %d", count);
    $finish;
  end
endmodule