module maximum_bass_filter (
    input clk,
    input signed [15:0] audio_in,   // 16-bit signed input audio sample
    output reg [15:0] audio_out  // 16-bit signed output audio sample
);

    // Filter coefficients as 16-bit signed integers
    parameter signed [15:0] h[0:50] = {
        16'sd87,  16'sd92,  16'sd105, 16'sd126, 16'sd156, 16'sd193, 16'sd237, 
        16'sd289, 16'sd346, 16'sd409, 16'sd476, 16'sd547, 16'sd620, 16'sd694, 
        16'sd768, 16'sd841, 16'sd911, 16'sd978, 16'sd1039,16'sd1095,16'sd1144, 
        16'sd1185,16'sd1218,16'sd1242,16'sd1257,16'sd1261,16'sd1257,16'sd1242, 
        16'sd1218,16'sd1185,16'sd1144,16'sd1095,16'sd1039,16'sd978, 16'sd911, 
        16'sd841,16'sd768, 16'sd694, 16'sd620, 16'sd547, 16'sd476, 16'sd409, 
        16'sd346,16'sd289, 16'sd237, 16'sd193, 16'sd156, 16'sd126, 16'sd105, 
        16'sd92, 16'sd87
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
                y <= y + (x[i] * h[i] * 2);
            end

            // Assign the most significant 16 bits of the result to the output
            audio_out <= y[31:16];
        end
endmodule