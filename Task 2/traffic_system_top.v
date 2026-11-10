

`timescale 1ns/1ps

module traffic_system_top (
    input wire clk,
    input wire reset,
    input wire ped_request_a,
    input wire ped_request_b,

    output wire a_ns_red,
    output wire a_ns_yellow,
    output wire a_ns_green,
    output wire a_ew_red,
    output wire a_ew_yellow,
    output wire a_ew_green,
    output wire a_ped_walk,

    output wire b_ns_red,
    output wire b_ns_yellow,
    output wire b_ns_green,
    output wire b_ew_red,
    output wire b_ew_yellow,
    output wire b_ew_green,
    output wire b_ped_walk
);

    junction_controller #(
        .COUNTER_WIDTH(8),
        .GREEN_TIME(10),
        .YELLOW_TIME(3),
        .RED_TIME(2),
        .PED_TIME(5)
    ) junction_a (
        .clk(clk),
        .reset(reset),
        .ped_request(ped_request_a),
        .ns_red(a_ns_red),
        .ns_yellow(a_ns_yellow),
        .ns_green(a_ns_green),
        .ew_red(a_ew_red),
        .ew_yellow(a_ew_yellow),
        .ew_green(a_ew_green),
        .ped_walk(a_ped_walk)
    );

    junction_controller #(
        .COUNTER_WIDTH(8),
        .GREEN_TIME(8),
        .YELLOW_TIME(2),
        .RED_TIME(2),
        .PED_TIME(4)
    ) junction_b (
        .clk(clk),
        .reset(reset),
        .ped_request(ped_request_b),
        .ns_red(b_ns_red),
        .ns_yellow(b_ns_yellow),
        .ns_green(b_ns_green),
        .ew_red(b_ew_red),
        .ew_yellow(b_ew_yellow),
        .ew_green(b_ew_green),
        .ped_walk(b_ped_walk)
    );

endmodule
