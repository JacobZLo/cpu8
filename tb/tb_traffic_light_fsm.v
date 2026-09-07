`timescale 1ns/1ps

module tb_traffic_light_fsm;

    localparam integer P_GREEN  = 3;
    localparam integer P_YELLOW = 2;
    localparam integer P_RED    = 1;

    localparam [2:0] GREEN  = 3'b001;
    localparam [2:0] YELLOW = 3'b010;
    localparam [2:0] RED    = 3'b100;

    reg        clk   = 0;
    reg        reset = 1;
    wire [2:0] lights_ns;
    wire [2:0] lights_ew;

    integer errors = 0;

    traffic_light_fsm #(
        .GREEN_TIME(P_GREEN),
        .YELLOW_TIME(P_YELLOW),
        .RED_TIME(P_RED)
    ) dut (
        .clk(clk),
        .reset(reset),
        .lights_ns(lights_ns),
        .lights_ew(lights_ew)
    );

    always #5 clk = ~clk;

    task check_state(input[2:0] expected_ns, input[2:0] expected_ew, input integer cycles, input[511:0] label);
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                #1;
                if (lights_ns !== expected_ns || lights_ew !== expected_ew) begin
                    $display("[FAIL] %0t ns | %s (cycle %0d): Expected NS=%b EW=%b, Got NS=%b  EW=%b", 
                        $time, label, i, expected_ns, expected_ew, lights_ns, lights_ew);
                    errors = errors + 1;
                end
                if ((lights_ns != RED) && (lights_ew != RED)) begin
                    $display("[UH OH SERIOUS PROBLEM] %0t ns | Safety violation! Both directions active! NS=%b EW=%b",
                        $time, lights_ns, lights_ew);
                    errors = errors + 1;
                end
                @(posedge clk);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_traffic_light_fsm.vcd");
        $dumpvars(0, tb_traffic_light_fsm);

        repeat(2) @(posedge clk);
        #1;
        if (lights_ns !== GREEN || lights_ew !== RED) begin
            $display("[FAIL] %0t ns | Reset state mismatch: NS=%b EW=%b", $time, lights_ns, lights_ew);
            errors = errors + 1;
        end

        @(negedge clk);
        reset = 0;
        
        //check full cycle (one complete rotation of the intersection, not clock cycle) 1
        check_state(GREEN,  RED,    P_GREEN,  "NS_GREEN Cycle 1");
        check_state(YELLOW, RED,    P_YELLOW, "NS_YELLOW Cycle 1");
        check_state(RED,    RED,    P_RED,    "ALL_RED_1 Cycle 1");
        check_state(RED,    GREEN,  P_GREEN,  "EW_GREEN Cycle 1");
        check_state(RED,    YELLOW, P_YELLOW, "EW_YELLOW Cycle 1");
        check_state(RED,    RED,    P_RED,    "ALL_RED_2 Cycle 1");

        //verify return to loop start
        check_state(GREEN,  RED,    P_GREEN,  "NS_GREEN Cycle 2");

        if (errors == 0) begin
            $display("TRAFFIC LIGHT FSM: PASS");
        end else begin
            $display("TRAFFIC LIGHT FSM: FAIL (%0d errors)", errors);
        end

        $finish;
    end

    endmodule
