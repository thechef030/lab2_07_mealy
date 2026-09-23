`timescale 1ns/1ps

// Combo II-DLD S75. Main clock B6 MUST be set to 1 kHz.
// K4: reset. N8: step button. DIPSW1..8 = sw[7]..sw[0].
module lab2_mealy #(parameter integer STABLE_CYCLES = 20) (
    input wire clk, rst, button,
    input wire [7:0] sw,
    output wire [7:0] led
);

    wire reset, press;
    wire [7:0] switches;

    input_frontend #(.STABLE_CYCLES(STABLE_CYCLES)) inputs(
        clk, rst, button, sw, reset, press, switches);

    wire state;
    wire [1:0] value;

    mealy_toggle core(clk, reset, press, switches[7], state, value);

    assign led = {5'b00000, state, value};

endmodule
