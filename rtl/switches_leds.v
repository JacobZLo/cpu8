`timescale 1ns / 1ps

module switches_leds(
    input  wire [15:0] SW,
    output wire [15:0] LED
    );
    
    assign LED = SW;
    
endmodule
