
`timescale 1ns/1ps

module tb_junction_controller;

    reg clk;
    reg reset;
    reg ped_request;

    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;
    wire ped_walk;

    junction_controller #(
        .COUNTER_WIDTH(8),
        .GREEN_TIME(4),
        .YELLOW_TIME(2),
        .RED_TIME(2),
        .PED_TIME(3)
    ) dut (
        .clk(clk),
        .reset(reset),
        .ped_request(ped_request),
        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),
        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green),
        .ped_walk(ped_walk)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        ped_request = 0;

        repeat (2) @(negedge clk);
        reset = 0;

        // Request pedestrian service during the first cycle.
        @(negedge clk);
        ped_request = 1;
        @(negedge clk);
        ped_request = 0;

        // Display the traffic-light sequence.
        repeat (50) begin
            @(negedge clk);
            $display(
                "Time=%0t NS(RYG)=%b%b%b EW(RYG)=%b%b%b PED=%b",
                $time,
                ns_red, ns_yellow, ns_green,
                ew_red, ew_yellow, ew_green,
                ped_walk
            );
        end

        $finish;
    end

endmodule
