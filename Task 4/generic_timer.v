
`timescale 1ns/1ps

module generic_timer #(
    parameter COUNTER_WIDTH = 32
)(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [COUNTER_WIDTH-1:0] count_target,
    output reg done
);

    reg [COUNTER_WIDTH-1:0] counter;
    reg active;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= {COUNTER_WIDTH{1'b0}};
            active  <= 1'b0;
            done    <= 1'b0;
        end
        else begin
            done <= 1'b0;

            if (!start) begin
                counter <= {COUNTER_WIDTH{1'b0}};
                active  <= 1'b0;
            end
            else if (count_target == 0) begin
                counter <= {COUNTER_WIDTH{1'b0}};
                active  <= 1'b0;
                done    <= 1'b1;
            end
            else if (!active) begin
                counter <= {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
                active  <= 1'b1;

                if (count_target == 1) begin
                    active <= 1'b0;
                    done   <= 1'b1;
                    counter <= {COUNTER_WIDTH{1'b0}};
                end
            end
            else if (counter >= count_target) begin
                counter <= {COUNTER_WIDTH{1'b0}};
                active  <= 1'b0;
                done    <= 1'b1;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule
