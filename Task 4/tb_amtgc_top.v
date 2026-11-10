`timescale 1ns/1ps

module tb_amtgc_top;

    reg clk;
    reg reset;
    reg ped_request_a;
    reg ped_request_b;
    reg emergency_override;

reg [2:0] traffic_density_a;
reg [2:0] traffic_density_b;

    wire a_ns_red, a_ns_yellow, a_ns_green;
    wire a_ew_red, a_ew_yellow, a_ew_green;
    wire a_ped_walk;

    wire b_ns_red, b_ns_yellow, b_ns_green;
    wire b_ew_red, b_ew_yellow, b_ew_green;
    wire b_ped_walk;

    integer errors;

    amtgc_top #(
        .COUNTER_WIDTH(8),
        .A_GREEN_TIME(10),
        .B_GREEN_TIME(10),
        .YELLOW_TIME(3),
        .RED_TIME(2),
        .PED_TIME(5)
    ) dut (
        .clk(clk),
        .reset(reset),
        .ped_request_a(ped_request_a),
        .ped_request_b(ped_request_b),
       .emergency_override(emergency_override),
       .traffic_density_a(traffic_density_a),
       .traffic_density_b(traffic_density_b),


        .a_ns_red(a_ns_red),
        .a_ns_yellow(a_ns_yellow),
        .a_ns_green(a_ns_green),
        .a_ew_red(a_ew_red),
        .a_ew_yellow(a_ew_yellow),
        .a_ew_green(a_ew_green),
        .a_ped_walk(a_ped_walk),

        .b_ns_red(b_ns_red),
        .b_ns_yellow(b_ns_yellow),
        .b_ns_green(b_ns_green),
        .b_ew_red(b_ew_red),
        .b_ew_yellow(b_ew_yellow),
        .b_ew_green(b_ew_green),
        .b_ped_walk(b_ped_walk)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_all_red;
    begin
        if (a_ns_red !== 1'b1 || a_ew_red !== 1'b1 ||
            a_ns_yellow !== 1'b0 || a_ew_yellow !== 1'b0 ||
            a_ns_green !== 1'b0 || a_ew_green !== 1'b0 ||
            b_ns_red !== 1'b1 || b_ew_red !== 1'b1 ||
            b_ns_yellow !== 1'b0 || b_ew_yellow !== 1'b0 ||
            b_ns_green !== 1'b0 || b_ew_green !== 1'b0) begin
            $display("[%0t] ERROR: Both junctions are not all-red.", $time);
            errors = errors + 1;
        end else begin
            $display("[%0t] PASS: Both junctions are all-red.", $time);
        end
    end
    endtask

    initial begin
        errors = 0;
        reset = 1'b1;
        ped_request_a = 1'b0;
        ped_request_b = 1'b0;
        emergency_override = 1'b0;
        traffic_density_a = 3'd0;
        traffic_density_b = 3'd0;

        $display("========================================");
        $display(" AMTGC TOP INTEGRATION TEST START");
        $display("========================================");

        // Reset
        repeat (3) @(negedge clk);
        reset = 1'b0;
        repeat (2) @(negedge clk);

       // Test different traffic-density levels
$display("[%0t] Testing traffic density levels.", $time);

traffic_density_a = 3'd0;
traffic_density_b = 3'd0;
repeat (30) @(negedge clk);

traffic_density_a = 3'd3;
traffic_density_b = 3'd5;
repeat (30) @(negedge clk);

traffic_density_a = 3'd7;
traffic_density_b = 3'd2;
repeat (30) @(negedge clk);

        // Simultaneous pedestrian requests
        $display("[%0t] Applying simultaneous pedestrian requests.", $time);
        ped_request_a = 1'b1;
        ped_request_b = 1'b1;
        repeat (30) @(negedge clk);
        ped_request_a = 1'b0;
        ped_request_b = 1'b0;
        repeat (20) @(negedge clk);

        // Emergency response check after a bounded wait of two clocks.
        $display("[%0t] Asserting emergency override.", $time);
        emergency_override = 1'b1;
        @(negedge clk);
        check_all_red();
        @(negedge clk);
        check_all_red();

        // Ensure all-red remains active while override is held.
        repeat (5) begin
            @(negedge clk);
            check_all_red();
        end

        // Release emergency and observe recovery.
        $display("[%0t] Releasing emergency override.", $time);
        emergency_override = 1'b0;
        repeat (30) @(negedge clk);

        $display("========================================");
        if (errors == 0)
            $display(" TEST FINISHED: No emergency all-red check failures detected.");
        else
            $display(" TEST FINISHED: %0d error(s) detected.", errors);
        $display(" Note: Review waveforms and controller/arbiter logic for");
        $display(" pedestrian fairness, normal sequence, reset, and green-wave timing.");
        $display("========================================");

        $finish;
    end

    initial begin
        $monitor("t=%0t reset=%b emergency=%b | A(NS RYG)=%b%b%b A(EW RYG)=%b%b%b A_PED=%b | B(NS RYG)=%b%b%b B(EW RYG)=%b%b%b B_PED=%b",
                 $time, reset, emergency_override,
                 a_ns_red, a_ns_yellow, a_ns_green,
                 a_ew_red, a_ew_yellow, a_ew_green, a_ped_walk,
                 b_ns_red, b_ns_yellow, b_ns_green,
                 b_ew_red, b_ew_yellow, b_ew_green, b_ped_walk);
    end

endmodule
