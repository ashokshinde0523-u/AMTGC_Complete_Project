
`timescale 1ns/1ps

module junction_controller #(
   parameter COUNTER_WIDTH = 8,
parameter GREEN_TIME    = 10,
parameter YELLOW_TIME   = 3,
parameter RED_TIME      = 2,
parameter PED_TIME      = 5,

parameter MIN_GREEN_TIME = GREEN_TIME,
parameter MAX_GREEN_TIME = 30,
parameter GREEN_EXT_PER_LEVEL = 3
)(
    input wire clk,
    input wire reset,
    input wire ped_request,
    input wire ped_grant,
    input wire emergency_override,
    input wire [2:0] traffic_density,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,
    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green,
    output reg ped_walk,
    output reg ped_ack
);

    localparam NS_GREEN  = 3'd0;
    localparam NS_YELLOW = 3'd1;
    localparam ALL_RED_1 = 3'd2;
    localparam EW_GREEN  = 3'd3;
    localparam EW_YELLOW = 3'd4;
    localparam ALL_RED_2 = 3'd5;
    localparam PED_NS    = 3'd6;
    localparam PED_EW    = 3'd7;

    reg [2:0] state, next_state;
    reg ped_pending;
    reg [COUNTER_WIDTH-1:0] phase_time;
    reg timer_start;
    reg [2:0] previous_state;
    reg [COUNTER_WIDTH-1:0] green_time_latched;
    reg [COUNTER_WIDTH-1:0] adaptive_green_calc;

    wire timer_done;
    wire state_changed;

    assign state_changed = (state != previous_state);
    always @(posedge clk) begin
    if (reset || emergency_override)
        green_time_latched <= MIN_GREEN_TIME;

    else if (state_changed &&
            ((state == NS_GREEN) || (state == EW_GREEN)))
        green_time_latched <= adaptive_green_calc;
end
    always @(*) begin
    adaptive_green_calc =
        MIN_GREEN_TIME + (traffic_density * GREEN_EXT_PER_LEVEL);

    if (adaptive_green_calc > MAX_GREEN_TIME)
        adaptive_green_calc = MAX_GREEN_TIME;

    if (adaptive_green_calc < MIN_GREEN_TIME)
        adaptive_green_calc = MIN_GREEN_TIME;
end

    always @(posedge clk) begin
        if (reset)
            previous_state <= ALL_RED_1;
        else if (emergency_override)
            previous_state <= ALL_RED_1;
        else
            previous_state <= state;
    end

    always @(*) begin
        case (state)
            NS_GREEN:  phase_time = green_time_latched;
            NS_YELLOW: phase_time = YELLOW_TIME;
            ALL_RED_1: phase_time = RED_TIME;
            EW_GREEN:  phase_time = green_time_latched;
            EW_YELLOW: phase_time = YELLOW_TIME;
            ALL_RED_2: phase_time = RED_TIME;
            PED_NS:    phase_time = PED_TIME;
            PED_EW:    phase_time = PED_TIME;
            default:   phase_time = RED_TIME;
        endcase
    end

    always @(*) begin
        timer_start = !state_changed && !reset &&
                      !emergency_override;
    end

    generic_timer #(
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) phase_timer (
        .clk(clk),
        .reset(reset || emergency_override),
        .start(timer_start),
        .count_target(phase_time),
        .done(timer_done)
    );

    always @(posedge clk) begin
        if (reset || emergency_override)
            ped_pending <= 1'b0;
        else if (ped_request)
            ped_pending <= 1'b1;
        else if ((state == PED_NS) || (state == PED_EW))
            ped_pending <= 1'b0;
    end

    always @(*) begin
        next_state = state;

        case (state)
            NS_GREEN:
                if (timer_done) next_state = NS_YELLOW;

            NS_YELLOW:
                if (timer_done) next_state = ALL_RED_1;

            ALL_RED_1:
                if (timer_done) begin
                    if (ped_pending && ped_grant)
                        next_state = PED_NS;
                    else
                        next_state = EW_GREEN;
                end

            EW_GREEN:
                if (timer_done) next_state = EW_YELLOW;

            EW_YELLOW:
                if (timer_done) next_state = ALL_RED_2;

            ALL_RED_2:
                if (timer_done) begin
                    if (ped_pending && ped_grant)
                        next_state = PED_EW;
                    else
                        next_state = NS_GREEN;
                end

            PED_NS:
                if (timer_done) next_state = EW_GREEN;

            PED_EW:
                if (timer_done) next_state = NS_GREEN;

            default: next_state = ALL_RED_1;
        endcase
    end

    always @(posedge clk) begin
        if (reset)
            state <= ALL_RED_1;
        else if (emergency_override)
            state <= ALL_RED_1;
        else
            state <= next_state;
    end

    always @(*) begin
        ns_red    = 1'b1;
        ns_yellow = 1'b0;
        ns_green  = 1'b0;
        ew_red    = 1'b1;
        ew_yellow = 1'b0;
        ew_green  = 1'b0;
        ped_walk  = 1'b0;
        ped_ack = 1'b0;

        if (emergency_override) begin
            ns_red    = 1'b1;
            ns_yellow = 1'b0;
            ns_green  = 1'b0;
            ew_red    = 1'b1;
            ew_yellow = 1'b0;
            ew_green  = 1'b0;
            ped_walk  = 1'b0;
            ped_ack   = 1'b0;
        end
        else begin
            case (state)
                NS_GREEN: begin
                    ns_red   = 1'b0;
                    ns_green = 1'b1;
                end

                NS_YELLOW: begin
                    ns_red    = 1'b0;
                    ns_yellow = 1'b1;
                end

                EW_GREEN: begin
                    ew_red   = 1'b0;
                    ew_green = 1'b1;
                end

                EW_YELLOW: begin
                    ew_red    = 1'b0;
                    ew_yellow = 1'b1;
                end

                PED_NS, PED_EW: begin
                    ped_walk = 1'b1;
                    if (timer_done)
                    ped_ack = 1'b1;
                end

                default: begin
                    // All-red safety phase.
                end
            endcase
        end
    end

endmodule
