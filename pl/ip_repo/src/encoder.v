`timescale 1ns / 1ns

module encoder #(
    parameter WIDTH = 8,
    parameter REST_STATE = 1
) (
    input clk,
    input a_value,
    input b_value,
    output reg [WIDTH-1:0] value
);
    reg [1:0] shift = {2{REST_STATE[0]}};

    always @(posedge clk)
        shift <= {shift,a_value};

    initial value = 0;
    always @(posedge clk)
        if (shift == 2'b01)
            if (!b_value)
                value <= value-1;
            else
                value <= value+1;
endmodule
