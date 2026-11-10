
`timescale 1ns/1ps

module amtgc_top #(
    parameter COUNTER_WIDTH = 8,
    parameter A_GREEN_TIME  = 10,
    parameter B_GREEN_TIME  = 10,
    parameter YELLOW_TIME   = 3,
    parameter RED_TIME      = 2,
    parameter PED_TIME      = 5
)(
    input wire clk,
    input wire reset,
    input wire ped_request_a,
    input wire ped_request_b,
    input wire emergency_override,

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

    wire ped_grant_a;
    wire ped_grant_b;
    wire ped_ack_a;
    wire ped_ack_b;

    ped_arbiter pedestrian_arbiter (
        .clk(clk),
        .reset(reset),
        .req_a(ped_request_a),
        .req_b(ped_request_b),
        .ack_a(ped_ack_a),
        .ack_b(ped_ack_b),
        .grant_a(ped_grant_a),
        .grant_b(ped_grant_b)
    );

    junction_controller #(
        .COUNTER_WIDTH(COUNTER_WIDTH),
        .GREEN_TIME(A_GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME),
        .RED_TIME(RED_TIME),
        .PED_TIME(PED_TIME)
    ) junction_a (
        .clk(clk),
        .reset(reset),
        .ped_request(ped_request_a),
        .ped_grant(ped_grant_a),
        .emergency_override(emergency_override),
        .ns_red(a_ns_red),
        .ns_yellow(a_ns_yellow),
        .ns_green(a_ns_green),
        .ew_red(a_ew_red),
        .ew_yellow(a_ew_yellow),
        .ew_green(a_ew_green),
        .ped_walk(a_ped_walk),
        .ped_ack(ped_ack_a)
    );

    junction_controller #(
        .COUNTER_WIDTH(COUNTER_WIDTH),
        .GREEN_TIME(B_GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME),
        .RED_TIME(RED_TIME),
        .PED_TIME(PED_TIME)
    ) junction_b (
        .clk(clk),
        .reset(reset),
        .ped_request(ped_request_b),
        .ped_grant(ped_grant_b),
        .emergency_override(emergency_override),
        .ns_red(b_ns_red),
        .ns_yellow(b_ns_yellow),
        .ns_green(b_ns_green),
        .ew_red(b_ew_red),
        .ew_yellow(b_ew_yellow),
        .ew_green(b_ew_green),
        .ped_walk(b_ped_walk),
        .ped_ack(ped_ack_b)
    );

endmodule
