`timescale 1ns / 1ps

module seg7_driver (
    input             clk,
    input             reset,
    input      [15:0] value,
    output reg [6:0]  segment,
    output reg [7:0]  anode
);

    reg [17:0] refresh_count;
    always @(posedge clk) begin
        if(reset) begin
            refresh_count <= 18'd0;
        end else begin
            refresh_count <= refresh_count + 1;
        end
    end

    /*The display can't show 4 numbers at the same time, so it 
    cycles through each digit one after the other at a high 
    refresh rate (~381 Hz), relying on persistence of vision to 
    make them appear simultaneously lit. The top 2 bits split the 
    counter's cycle into 4 equal time slices, one for each digit.*/
    wire [1:0] digit_select = refresh_count [17:16];

    //active-low 0 = LED ON, 1 = LED OFF
    reg [3:0] nibble;
    always @(*) begin
        anode[7:4] = 4'b1111;

        case(digit_select)
            2'b00: begin
                anode[3:0] = 4'b1110;
                nibble = value[3:0];
            end
            2'b01: begin
                anode[3:0] = 4'b1101;
                nibble = value[7:4];
            end
            2'b10: begin
                anode[3:0] = 4'b1011;
                nibble = value[11:8];
            end
            2'b11: begin
                anode[3:0] = 4'b0111;
                nibble = value[15:12];
            end
        endcase
    end

    //bit mapping: segment = {CG, CF, CE, CD, CC, CB, CA}
    always @(*) begin
        case (nibble)
            4'h0: segment = 7'b1000000;
            4'h1: segment = 7'b1111001;
            4'h2: segment = 7'b0100100;
            4'h3: segment = 7'b0110000;
            4'h4: segment = 7'b0011001;
            4'h5: segment = 7'b0010010;
            4'h6: segment = 7'b0000010;
            4'h7: segment = 7'b1111000;
            4'h8: segment = 7'b0000000;
            4'h9: segment = 7'b0010000;
            4'hA: segment = 7'b0001000;
            4'hB: segment = 7'b0000011;
            4'hC: segment = 7'b1000110;
            4'hD: segment = 7'b0100001;
            4'hE: segment = 7'b0000110;
            4'hF: segment = 7'b0001110;
            default: segment = 7'b1111111;
        endcase
    end

endmodule

