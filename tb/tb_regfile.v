`timescale 1ns/1ps

module tb_reg_file_8x8;
    reg        clk = 0;
    reg        wr_en = 0;
    reg  [2:0] wr_addr = 0;
    reg  [7:0] wr_data = 0;
    reg  [2:0] rd_addr1 = 0;
    reg  [2:0] rd_addr2 = 0;

    wire [7:0] rd_data1;
    wire [7:0] rd_data2;

    integer errors = 0;

    always #5 clk = ~clk;

    reg_file_8x8 dut (
        .clk      (clk),
        .wr_en    (wr_en),
        .wr_addr  (wr_addr),
        .wr_data  (wr_data),
        .rd_addr1 (rd_addr1),
        .rd_addr2 (rd_addr2),
        .rd_data1 (rd_data1),
        .rd_data2 (rd_data2)
    );

    task check_rd1(input [7:0] expected, input [511:0] label);
        if (rd_data1 !== expected) begin
            $display("FAIL Port 1 [%0s]: expected 0x%0h, got 0x%0h", label, expected, rd_data1);
            errors = errors + 1;
        end else begin
            $display("PASS Port 1 [%0s]: rd_data1 = 0x%0h", label, rd_data1);
        end
    endtask

    task check_rd2(input [7:0] expected, input [511:0] label);
        if (rd_data2 !== expected) begin
            $display("FAIL Port 2 [%0s]: expected 0x%0h, got 0x%0h", label, expected, rd_data2);
            errors = errors + 1;
        end else begin
            $display("PASS Port 2 [%0s]: rd_data2 = 0x%0h", label, rd_data2);
        end
    endtask

    initial begin
        @(negedge clk);

        //write to register 2
        wr_en   = 1'b1;
        wr_addr = 3'd2;
        wr_data = 8'hA5;
        @(negedge clk);

        //write to register 7
        wr_addr = 3'd7;
        wr_data = 8'h3C;
        @(negedge clk);
        wr_en   = 0;

        //read both registers concurrently (Port 1 to Reg 2, Port 2 to Reg 7)
        rd_addr1 = 3'd2;
        rd_addr2 = 3'd7;
        #1;
        check_rd1(8'hA5, "concurrent read reg 2");
        check_rd2(8'h3C, "concurrent read reg 7");

        //attempt overwrite with wr_en = 0
        wr_en   =  0;
        wr_addr = 3'd2;
        wr_data = 8'hFF;
        @(negedge clk);

        rd_addr1 = 3'd2;
        #1;
        check_rd1(8'hA5, "data unchanged when wr_en is low");

        //verify simultaneous read and write to different addresses
        wr_en    = 1;
        wr_addr  = 3'd0;
        wr_data  = 8'h77;
        rd_addr1 = 3'd7;
        @(negedge clk);
        wr_en    = 0;

        rd_addr2 = 3'd0;
        #1;
        check_rd1(8'h3C, "port 1 unaffected during write to other reg");
        check_rd2(8'h77, "read newly written reg 0");

        //same-cycle write and read to the same address
        @(negedge clk);
        wr_en = 1;
        wr_addr = 3'd7;
        wr_data = 8'h99;
        rd_addr1 = 3'd7;
        #1;
        check_rd1(8'h3C, "same-cycle write/read returns OLD value");

        @(negedge clk);
        wr_en = 0;
        #1;
        check_rd1(8'h99, "read after write completed shows NEW value");

        if (errors == 0)
            $display("\nALL TESTS PASSED\n");
        else
            $display("\n%0d TEST(S) FAILED\n", errors);
        $finish;
    end

endmodule
