
`timescale 1ns/1ps

module ped_arbiter (
    input  wire clk,
    input  wire reset,
    input  wire req_a,
    input  wire req_b,
    input  wire ack_a,
    input  wire ack_b,
    output reg  grant_a,
    output reg  grant_b
);

    reg last_grant;
    reg active;
    reg selected;

    // selected = 0: Junction A
    // selected = 1: Junction B
    // last_grant remembers the junction served last.

    always @(posedge clk) begin
        if (reset) begin
            last_grant <= 1'b1;
            active     <= 1'b0;
            selected   <= 1'b0;
        end
        else begin
            if (!active) begin
                if (req_a && req_b) begin
                    active   <= 1'b1;
                    selected <= ~last_grant;
                end
                else if (req_a) begin
                    active   <= 1'b1;
                    selected <= 1'b0;
                end
                else if (req_b) begin
                    active   <= 1'b1;
                    selected <= 1'b1;
                end
            end
            else if ((selected == 1'b0 && ack_a) ||
                     (selected == 1'b1 && ack_b)) begin
                active     <= 1'b0;
                last_grant <= selected;
            end
        end
    end

    always @(*) begin
        grant_a = 1'b0;
        grant_b = 1'b0;

        if (active) begin
            if (selected == 1'b0)
                grant_a = req_a;
            else
                grant_b = req_b;
        end
    end

endmodule
