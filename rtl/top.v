`timescale 1ns / 1ps

module top (
    input        clk,
    input        btnC, //center button for increment
    input        btnU, //up button for reset
    output [6:0] segment,
    output [7:0] anode
);
    
    wire reset = btnU;

    //debounce center button (10ms filter at 100MHz)
    wire btn_tick;
    debouncer #(
        .CNT_MAX(1_000_000)
    ) u_debouncer (
        .clk       (clk),
        .reset     (reset),
        .btn_in    (btnC),
        .btn_out   (),
        .btn_pulse (btn_tick)
    );

    //counter incremented by debounced button pulses
    reg [15:0] count;
    always @(posedge clk) begin
        if (reset) begin
            count <= 16'h0000;
        end else if (btn_tick) begin
            count <= count + 1;
        end
    end

    //7 segment display driver instance
    seg7_driver u_display (
        .clk     (clk),
        .reset   (reset),
        .value   (count),
        .segment (segment),
        .anode   (anode)
    );

endmodule
