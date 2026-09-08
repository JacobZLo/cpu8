`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 09:44:13 PM
// Design Name: 
// Module Name: switches_leds
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module switches_leds(
    input  wire [15:0] sw,
    output wire [15:0] led
    );
    
    assign led = sw;
    
endmodule
