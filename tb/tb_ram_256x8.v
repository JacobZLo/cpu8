`timescale 1ns/1ps

module tb_ram_256x8;

    reg        clk = 0;
    reg        we = 0;
    reg  [7:0] addr = 0;
    reg  [7:0] datain = 0;

    wire [7:0] dataout;

    integer errors = 0;

    always #5 clk = ~clk;

    ram_256x8 #(
        .INIT_FILE("asm/programs/ram_256x8_init.hex")
    ) dut (
        .clk     (clk),
        .we      (we),
        .addr    (addr),
        .datain  (datain),
        .dataout (dataout)
    );

    task check_data(input [7:0] expected, input [511:0] label);
        if (dataout !== expected) begin
            $display("FAIL [%0s]: expected 0x%0h, got 0x%0h", label, expected, dataout);
            errors = errors + 1;
        end else begin
            $display("PASS [%0s]: dataout = 0x%0h", label, dataout);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_ram_256x8.vcd");
        $dumpvars(0, tb_ram_256x8);

        @(negedge clk);

        // verify pre-loaded values from the hex file
        we = 0;
        addr = 8'h00;
        @(negedge clk);
        check_data(8'hAA, "read hex address 0");

        addr = 8'h01;
        @(negedge clk);
        check_data(8'hBB, "read hex address 1");

        addr = 8'h02;
        @(negedge clk);
        check_data(8'hCC, "read hex address 2");

        //stadard write, then read back
        we     = 1;
        addr   = 8'h20;
        datain = 8'h55;
        @(negedge clk);

        we     = 0;
        datain = 8'h00;
        @(negedge clk);
        check_data(8'h55, "read newly written data at address 0x20");

        //attempt overwrite with we = 0
        we = 0;
        addr = 8'h20;
        datain = 8'hFF;
        @(negedge clk);

        addr = 8'h20;
        @(negedge clk);
        check_data(8'h55, "data unchanged when we is low");

        //same-cycle write and read collision (read-first behaviour)
        we     = 1;
        addr   = 8'h00;
        datain = 8'h77;
        @(negedge clk);
        check_data(8'hAA, "read-first: same-cycle read returns old value");

        we = 0;
        @(negedge clk);
        check_data(8'h77, "read committed value on subsequent cycle");

        if (errors == 0) begin
            $display("\nALL TESTS PASSED\n");
        end else begin
            $display("\n%0d TEST(S) FAILED\n", errors);
        end
        $finish;
    end

endmodule
