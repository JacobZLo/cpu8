`timescale 1ns/1ps

module tb_counter;
    reg clk = 0;
    reg reset = 0;
    reg load = 0;
    reg enable = 0;
    reg [7:0] d = 0;
    wire [7:0] q;
    integer errors = 0;

    always #5 clk = ~clk;

    counter_8bit dut (
        .clk    (clk),
        .reset  (reset),
        .load   (load),
        .enable (enable),
        .d      (d),
        .q      (q)
    );

    task check(input [7:0] expected, input [127:0] label);
        if  (q !== expected) begin
            $display("FAIL [%0s]: expected %0d, got %0d", label, expected, q);
            errors = errors + 1;
        end else begin
            $display("PASS [%0s]: q = %0d", label, q);
        end
    endtask

    initial begin
        @(negedge clk);

        //reset
        reset = 1;
        @(negedge clk);
        reset = 0;
        check(0, "after reset");

        //count up test
        enable = 1;
        repeat (3) @(negedge clk);
        enable = 0;
        check(3, "after 3 enabled cycles");

        //priority test of load vs enable
        enable = 1;
        load = 1;
        d = 8'd50;
        @(negedge clk);
        load = 0;
        check(50, "after load");

        //counting from loaded value
        @(negedge clk);
        enable = 0;
        check(51, "after load then enable");

        if (errors == 0)
            $display("\nALL TESTS PASSED\n");
        else
            $display("\n%0d TEST(S) FAILED\n", errors);

        $finish;
    end

endmodule