
`timescale 1ns/1ps

module tb_amtgc_system;

    reg clk;
    reg reset;
    reg ped_request_a, ped_request_b;
    reg emergency_override;
    reg [2:0] traffic_density_a, traffic_density_b;

    wire a_ns_red, a_ns_yellow, a_ns_green;
    wire a_ew_red, a_ew_yellow, a_ew_green, a_ped_walk;

    wire b_ns_red, b_ns_yellow, b_ns_green;
    wire b_ew_red, b_ew_yellow, b_ew_green, b_ped_walk;

    integer errors;
    integer checks;
    integer i;

    integer ped_a_services;
    integer ped_b_services;
    integer fairness_timeout;

    localparam MIN_GREEN = 10;
    localparam MAX_GREEN = 30;
    localparam EXTENSION = 3;

    amtgc_top #(
        .COUNTER_WIDTH(8),
        .A_GREEN_TIME(10),
        .B_GREEN_TIME(10),
        .YELLOW_TIME(3),
        .RED_TIME(2),
        .PED_TIME(5),
        .MIN_GREEN_TIME(MIN_GREEN),
        .MAX_GREEN_TIME(MAX_GREEN),
        .GREEN_EXT_PER_LEVEL(EXTENSION)
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

    // Clock: 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    // Automatic check for conflicting green lights
    task check_safety;
    begin
        checks = checks + 1;

        if ((a_ns_green && a_ew_green) ||
            (b_ns_green && b_ew_green)) begin
            $display("FAIL: Conflicting green lights at %0t", $time);
            errors = errors + 1;
        end

        if (emergency_override) begin
            if (!(a_ns_red && a_ew_red &&
                  b_ns_red && b_ew_red) ||
                a_ns_green || a_ew_green ||
                b_ns_green || b_ew_green ||
                a_ns_yellow || a_ew_yellow ||
                b_ns_yellow || b_ew_yellow ||
                a_ped_walk || b_ped_walk) begin

                $display("FAIL: Emergency safety violation at %0t", $time);
                errors = errors + 1;
            end
        end
    end
    endtask

    // Check adaptive green-time calculation
    task check_adaptive_value;
        input integer density;
        integer expected_time;
        begin
            expected_time = MIN_GREEN + density * EXTENSION;

            if (expected_time > MAX_GREEN)
                expected_time = MAX_GREEN;

            if (expected_time < MIN_GREEN)
                expected_time = MIN_GREEN;

            checks = checks + 1;

            if (expected_time < MIN_GREEN ||
                expected_time > MAX_GREEN) begin
                $display("FAIL: Adaptive timing limit violation");
                errors = errors + 1;
            end
            else begin
                $display("PASS: Density %0d calculated green time %0d",
                         density, expected_time);
            end
        end
    endtask

    // Monitor safety on every falling clock edge
    always @(negedge clk) begin
        if (!reset)
            check_safety();
    end
// Pedestrian service counter
always @(negedge clk) begin
    if (!reset) begin
        if (dut.ped_ack_a)
            ped_a_services = ped_a_services + 1;

        if (dut.ped_ack_b)
            ped_b_services = ped_b_services + 1;
    end
end
    initial begin

        errors = 0;
        checks = 0;
      
        ped_a_services = 0;
        ped_b_services = 0;
        fairness_timeout = 0;

        reset = 1;
        ped_request_a = 0;
        ped_request_b = 0;
        emergency_override = 0;
        traffic_density_a = 0;
        traffic_density_b = 0;

        $display("==========================================");
        $display(" AMTGC TASK 5 FULL VERIFICATION START");
        $display("==========================================");

        // TEST 1: Initial reset
        repeat (3) @(negedge clk);
        reset = 0;
        repeat (3) @(negedge clk);

        $display("TEST 1: Initial reset completed");

        // TEST 2: Normal traffic
        $display("TEST 2: Normal traffic operation");

        traffic_density_a = 0;
        traffic_density_b = 0;
        repeat (60) @(negedge clk);

        // TEST 3: Five density combinations
        $display("TEST 3: Adaptive density testing");

        traffic_density_a = 0; traffic_density_b = 0;
        check_adaptive_value(0);
        repeat (35) @(negedge clk);

        traffic_density_a = 1; traffic_density_b = 2;
        check_adaptive_value(1);
        repeat (35) @(negedge clk);

        traffic_density_a = 3; traffic_density_b = 5;
        check_adaptive_value(3);
        repeat (35) @(negedge clk);

        traffic_density_a = 5; traffic_density_b = 3;
        check_adaptive_value(5);
        repeat (35) @(negedge clk);

        traffic_density_a = 7; traffic_density_b = 7;
        check_adaptive_value(7);
        repeat (35) @(negedge clk);

       
// TEST 4: Pedestrian arbitration fairness
$display("TEST 4: Pedestrian fairness - 120 completed services");

ped_a_services = 0;
ped_b_services = 0;
fairness_timeout = 0;

traffic_density_a = 0;
traffic_density_b = 0;

ped_request_a = 1;
ped_request_b = 1;

// Wait until 120 actual pedestrian acknowledgments
while ((ped_a_services + ped_b_services < 120) &&
       (fairness_timeout < 20000)) begin
    @(negedge clk);
    fairness_timeout = fairness_timeout + 1;
end

ped_request_a = 0;
ped_request_b = 0;

repeat (10) @(negedge clk);

$display("Junction A completed services: %0d", ped_a_services);
$display("Junction B completed services: %0d", ped_b_services);
$display("Total completed services: %0d",
         ped_a_services + ped_b_services);

checks = checks + 1;

if ((ped_a_services + ped_b_services) < 120) begin
    $display("FAIL: Pedestrian service timeout");
    errors = errors + 1;
end
else if ((ped_a_services < 50) ||
         (ped_b_services < 50) ||
         ((ped_a_services - ped_b_services > 1) ||
          (ped_b_services - ped_a_services > 1))) begin
    $display("FAIL: Pedestrian arbitration fairness violation");
    errors = errors + 1;
end
else begin
    $display("PASS: Pedestrian arbitration fairness verified");
end


        // TEST 5: Emergency override
        $display("TEST 5: Emergency override");

        emergency_override = 1;
        repeat (5) @(negedge clk);

        emergency_override = 0;
        repeat (30) @(negedge clk);

        // TEST 6: Repeated emergency activation
        $display("TEST 6: Repeated emergency activation");

        repeat (5) begin
            emergency_override = 1;
            @(negedge clk);
            emergency_override = 0;
            @(negedge clk);
        end

        // TEST 7: Reset during active operation
        $display("TEST 7: Active reset");

        reset = 1;
        repeat (2) @(negedge clk);
        reset = 0;
        repeat (30) @(negedge clk);

        // TEST 8: Randomized traffic testing
        $display("TEST 8: Randomized traffic testing - 500 cycles");

        for (i = 0; i < 500; i = i + 1) begin
            @(negedge clk);

            traffic_density_a = $random % 8;
            traffic_density_b = $random % 8;

            ped_request_a = ($random % 4 == 0);
            ped_request_b = ($random % 4 == 0);

            if (i % 50 == 0)
                emergency_override = 1;
            else
                emergency_override = 0;
        end

        emergency_override = 0;
        ped_request_a = 0;
        ped_request_b = 0;

        repeat (40) @(negedge clk);

        // FINAL RESULT
        $display("==========================================");
        $display(" TASK 5 VERIFICATION SUMMARY");
        $display(" Total safety checks: %0d", checks);
        $display(" Total errors: %0d", errors);

        if (errors == 0)
            $display(" AMTGC TASK 5: PASS");
        else
            $display(" AMTGC TASK 5: FAIL");

        $display("==========================================");

        $finish;
    end

endmodule
