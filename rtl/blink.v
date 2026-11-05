`timescale 1ns/1ps

module blink (
    input clk,
    input reset,
    output reg led
);

    localparam integer HALF_PERIOD = 50_000_000;
    reg [25:0] counter;
    wire tick;
    
    assign tick = (counter == HALF_PERIOD - 1);
    
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
        end else if (tick) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            led <= 0;
        end else if (tick) begin
            led <= ~led;
        end
    end
endmodule
