`timescale 1ns/1ps

module debouncer #(
    parameter CNT_MAX = 1_000_000
)(
    input      clk,
    input      reset,
    input      btn_in,
    output reg btn_out,
    output     btn_pulse
);

    //2-stage synchronizer so it stabilizes the signal when the button is pressed exactly on the posedge
    reg sync_0, sync_1;
    always @(posedge clk) begin
        if (reset) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;
        end
    end

    localparam integer CNT_WIDTH = (CNT_MAX > 1) ? $clog2(CNT_MAX) : 1;
    reg [CNT_WIDTH-1:0] counter;
    reg state;

    //timer that only updates the output if the button holds long enough to filter out mechnical bounce (10ms)
    always @(posedge clk) begin
        if (reset) begin
            counter <= {CNT_WIDTH{1'b0}};
            state   <= 1'b0;
            btn_out <= 1'b0;
        end else begin
            if (sync_1 != state) begin
                counter <= counter + 1'b1;
                if (counter >= CNT_MAX - 1) begin
                    state   <= sync_1;
                    btn_out <= sync_1;
                    counter <= {CNT_WIDTH{1'b0}};
                end
            end else begin
                counter <= {CNT_WIDTH{1'b0}};
            end
        end
    end

    /*make it so that when holding down the button, the fpga sees only one 1 for when you 
    pressed the button, instead of it seeing one 1 every clock cycle */
    reg state_d;

    always @(posedge clk) begin
        if (reset) state_d <= 1'b0;
        else       state_d <= state;
    end

    assign btn_pulse = state & ~state_d;

endmodule
