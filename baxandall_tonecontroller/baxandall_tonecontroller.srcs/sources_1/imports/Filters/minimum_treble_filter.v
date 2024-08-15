module minimum_treble_filter (
    input clk,
    input signed [15:0] audio_in,   // 16-bit signed input audio sample
    output reg [15:0] audio_out  // 16-bit signed output audio sample
);

    // Filter coefficients as 16-bit signed integers
    parameter signed [15:0] h[0:50] = {
        -16'sd5,   -16'sd57,  -16'sd4,   -16'sd6,   16'sd28,   16'sd118,  16'sd35,   16'sd228, 
        -16'sd127, 16'sd156,  -16'sd473, -16'sd61,  -16'sd619, -16'sd85,  -16'sd34,  16'sd236, 
        16'sd1196, 16'sd274,  16'sd2032, -16'sd1077,16'sd1341, -16'sd4122,-16'sd746, -16'sd7490, 
        -16'sd2610,16'sd23733,-16'sd2610,-16'sd7490,-16'sd746, -16'sd4122,16'sd1341, -16'sd1077, 
        16'sd2032, 16'sd274,  16'sd1196, 16'sd236,  -16'sd34,  -16'sd85,  -16'sd619, -16'sd61, 
        -16'sd473, 16'sd156,  -16'sd127, 16'sd228,  16'sd35,   16'sd118,  16'sd28,   -16'sd6, 
        -16'sd4,   -16'sd57,  -16'sd5
    };

    // Shift register to store input samples
    reg signed [15:0] x[0:50];
    integer i;

    // MAC (Multiply-Accumulate) register for output
    reg signed [31:0] y;

    always @(posedge clk) begin
            // Shift input samples
            for (i = 50; i > 0; i = i - 1) begin
                x[i] <= x[i-1];
            end
            x[0] <= audio_in;

            // Calculate output sample (convolution)
            y <= 32'd0;
            for (i = 0; i < 51; i = i + 1) begin
                y <= y + (x[i] * h[i] * 1/2);
            end

            // Assign the most significant 16 bits of the result to the output
            audio_out <= y[31:16];
        end
endmodule