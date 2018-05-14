`timescale 1ns/1ns

module ssd #(parameter DSP_CYCLES_NB = 1000) (
    input               clk,
    input [7:0]         value,
    output reg [6:0]    ssd_segs,   // SSD's segments
    output reg          ssd_dsp     // SSD's Digit Selection Pin
);

    // https://reference.digilentinc.com/_detail/pmod/pmod/ssd/pmodssd1.png?id=reference%3Apmod%3Apmodssd%3Areference-manual
    // https://reference.digilentinc.com/_detail/pmod/pmod/ssd/pmodssd_sevensegment.png?id=reference%3Apmod%3Apmodssd%3Areference-manual
    wire [3:0] digit;
    always @(posedge clk)
        case (digit)
        4'h0: ssd_segs <= 7'b1111110; // ABCDEF
        4'h1: ssd_segs <= 7'b0110000; // BC
        4'h2: ssd_segs <= 7'b1101101; // ABDEG
        4'h3: ssd_segs <= 7'b1111001; // ABCDG
        4'h4: ssd_segs <= 7'b0110011; // BCFG
        4'h5: ssd_segs <= 7'b1011011; // ACDFG
        4'h6: ssd_segs <= 7'b1011111; // ACDEFG
        4'h7: ssd_segs <= 7'b1110000; // ABC
        4'h8: ssd_segs <= 7'b1111111; // ABCDEFG
        4'h9: ssd_segs <= 7'b1111011; // ABCDFG
        4'hA: ssd_segs <= 7'b1110111; // ABCEFG
        4'hB: ssd_segs <= 7'b0011111; // CDEFG
        4'hC: ssd_segs <= 7'b1001110; // ADEF
        4'hD: ssd_segs <= 7'b0111101; // BCDEG
        4'hE: ssd_segs <= 7'b1001111; // ADEFG
        4'hF: ssd_segs <= 7'b1000111; // AEFG
        endcase

    reg [0:$clog2(DSP_CYCLES_NB)-1] count = 0;
    always @(posedge clk)
        count <= count+1;
    always @(posedge clk)
        ssd_dsp <= count[0];
    assign digit = count[0] ? value[7:4] : value[3:0];

endmodule
