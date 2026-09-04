module counter_8bit (
    input            clk,
    input            reset,     //Synchronous, active-high
    input            load,      //Takes priority over enable
    input            enable,    //Clock enable, ignored if load is asserted
    input      [7:0] d,
    output reg [7:0] q
);

    always @(posedge clk) begin
        if (reset) begin
            q <= 8'h0;
        end else if (load) begin
            q <= d;
        end else if (enable) begin
            q <= q + 1'h1;
        end
    end

endmodule
