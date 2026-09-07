`timescale 1ns/1ps

module traffic_light_fsm #(
    parameter integer GREEN_TIME  = 4,
    parameter integer YELLOW_TIME = 2,
    parameter integer RED_TIME    = 1
)(
    input            clk,
    input            reset,
    output reg [2:0] lights_ns,
    output reg [2:0] lights_ew
);

    localparam [2:0] GREEN  = 3'b001;
    localparam [2:0] YELLOW = 3'b010;
    localparam [2:0] RED    = 3'b100;

    localparam [2:0] NS_GREEN  = 3'd0, 
                     NS_YELLOW = 3'd1,
                     ALL_RED_1 = 3'd2, 
                     EW_GREEN  = 3'd3, 
                     EW_YELLOW = 3'd4,
                     ALL_RED_2 = 3'd5;
    
    //widest duration determines how many bits the timer needs
    function integer max3(input integer a, input integer b, input integer c);
        integer m;
        begin
            m = (a > b) ? a : b;
            m = (m > c) ? m : c;
            max3 = m;
        end
    endfunction

    //clamped to at least 1 bit so TIMER_WIDTH-1 is never negative if max3 == 1
    localparam integer MAX_TIME = max3(GREEN_TIME, YELLOW_TIME, RED_TIME);
    localparam integer CLOG2_MAX = $clog2(MAX_TIME);
    localparam integer TIMER_WIDTH = (CLOG2_MAX > 0) ? CLOG2_MAX : 1;

    reg [2:0]                 state, next_state;
    reg [TIMER_WIDTH - 1 : 0] timer;
    wire                      timer_done;

    function [TIMER_WIDTH-1:0] state_duration(input [2:0] s);
        case(s)
            NS_GREEN, EW_GREEN:   state_duration = (GREEN_TIME  > 0) ? (GREEN_TIME  - 1) : 0;
            NS_YELLOW, EW_YELLOW: state_duration = (YELLOW_TIME > 0) ? (YELLOW_TIME - 1) : 0;
            ALL_RED_1, ALL_RED_2: state_duration = (RED_TIME    > 0) ? (RED_TIME    - 1) : 0;
            default:              state_duration = {TIMER_WIDTH{1'b0}};
        endcase
    endfunction

    assign timer_done = (timer >= state_duration(state));

    always @(posedge clk) begin
        if (reset) begin
            state <= NS_GREEN;
            timer <= {TIMER_WIDTH{1'b0}};
        end else if (state != next_state) begin
            state <= next_state;
            timer <= {TIMER_WIDTH{1'b0}};
        end else begin
            timer <= timer + 1'b1;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            NS_GREEN:  if (timer_done) next_state = NS_YELLOW;
            NS_YELLOW: if (timer_done) next_state = ALL_RED_1;
            ALL_RED_1: if (timer_done) next_state = EW_GREEN;
            EW_GREEN:  if (timer_done) next_state = EW_YELLOW;
            EW_YELLOW: if (timer_done) next_state = ALL_RED_2;
            ALL_RED_2: if (timer_done) next_state = NS_GREEN;
            default:   next_state = NS_GREEN;
        endcase
    end

    always @(*) begin
        lights_ns = RED;
        lights_ew = RED;
        case(state)
            NS_GREEN:  lights_ns = GREEN;
            NS_YELLOW: lights_ns = YELLOW;
            EW_GREEN:  lights_ew = GREEN;
            EW_YELLOW: lights_ew = YELLOW;
            ALL_RED_1, 
            ALL_RED_2: begin
                lights_ns = RED;
                lights_ew = RED;
            end
            default: begin
                lights_ns = RED;
                lights_ew = RED;
            end
        endcase
    end
    
endmodule
