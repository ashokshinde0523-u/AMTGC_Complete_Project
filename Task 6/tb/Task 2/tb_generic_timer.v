

`timescale 1ns/1ps

module tb_generic_timer;

    reg clk;
    reg reset;
    reg start;
    reg [7:0] count_target;
    wire done;

    integer errors;

    generic_timer #(
        .COUNTER_WIDTH(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .count_target(count_target),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        count_target = 0;
        errors = 0;

        repeat (2) @(negedge clk);
        reset = 0;

        test_timer(3);
        test_timer(5);
        test_timer(8);

        @(negedge clk);
        count_target = 0;
        start = 1;
        @(posedge clk);
        #1;

        if (done)
            $display("PASS: zero target");
        else begin
            $display("FAIL: zero target");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("ALL TIMER TESTS PASSED");
        else
            $display("TIMER TESTS FAILED: %0d", errors);

        $finish;
    end

    task test_timer;
        input [7:0] target;
        integer cycles;
        begin
            @(negedge clk);
            start = 0;
            @(negedge clk);
            count_target = target;
            start = 1;
            cycles = 0;

            while (done !== 1'b1 && cycles < target + 3) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
            end

            if (done === 1'b1)
                $display("Timer target %0d completed", target);
            else begin
                $display("FAIL: target %0d timed out", target);
                errors = errors + 1;
            end

            @(negedge clk);
            start = 0;
        end
    endtask

endmodule
