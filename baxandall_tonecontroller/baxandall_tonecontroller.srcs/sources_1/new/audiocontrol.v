`timescale 1ns / 1ps

module audiocontrol(input CLK,input reset, input switch1, input switch2, input switch3, input switch4, input vp_in, input vn_in, output reg [15:0] output_signal);

wire [15:0] input_signal;
wire enable;

xadc_wiz_0 xadcinst (
        .daddr_in(8'h10),            // Address bus for the dynamic reconfiguration port
        .dclk_in(CLK),             // Clock input for the dynamic reconfiguration port
        .den_in(enable),              // Enable Signal for the dynamic reconfiguration port
        .di_in(0),               // Input data bus for the dynamic reconfiguration port
        .dwe_in(0),              // Write Enable for the dynamic reconfiguration port
        .busy_out(),            // ADC Busy signal
        .channel_out(),         // Channel Selection Outputs
        .do_out(input_signal),              // Output data bus for dynamic reconfiguration port
        .eoc_out(enable),             // End of Conversion Signal
        .eos_out(),             // End of Sequence Signal
        .alarm_out(),           // OR'ed output of all the Alarms  
        .vp_in(vp_in),                        // input wire vp_in
        .vn_in(vn_in)
        );

localparam L = 2'b00;
localparam H = 2'b01;
localparam U = 2'b10;

reg [1:0] bass_present_state, bass_next_state;
reg [1:0] treble_present_state, treble_next_state;

// intialize and reset
always @(posedge CLK or posedge reset) begin
    if (reset) begin
        bass_present_state <= U;
        treble_present_state <= U;        
    end else begin
        bass_present_state <= bass_next_state;
        treble_present_state <= treble_next_state;
        end
    end

// bass state controller
    always @(posedge CLK) begin
        case(bass_present_state)
            L: begin
                if (switch3 & switch1)
                   bass_next_state = H;
            end   
            H: begin
                if (!switch3 & switch1)
                    bass_next_state = L;
                    end
            default: bass_next_state = U;
        endcase
    end

// treble state controller
    always @(posedge CLK) begin
        case(treble_present_state)
            L: begin
                if (switch4 & switch2)
                   treble_next_state = H;
            end   
            H: begin
                if (!switch4 & switch2)
                    treble_next_state = L;
                    end
            default: treble_next_state = U;
        endcase
    end
  
// output logic

wire [2:0] [15:0]  treble_filter;
wire [2:0] [15:0]  bass_filter;
reg [15:0] treble_signal;
reg [15:0] bass_signal;
reg [15:0] middle_signal;


minimum_treble_filter filter0(CLK,input_signal,treble_filter[0]);

maximum_treble_filter filter1(CLK,input_signal,treble_filter[2]);

unmodulated_treble_filter filter2(CLK,input_signal,treble_filter[1]);

minimum_bass_filter filter3(CLK,input_signal,bass_filter[0]);

maximum_bass_filter filter4(CLK,input_signal,bass_filter[2]);

unmodulated_bass_filter filter5(CLK,input_signal,bass_filter[1]);




always @(posedge CLK) begin
      case(treble_present_state)
        L: begin
            treble_signal = treble_filter[0];
           end
        H: begin
            treble_signal = treble_filter[2];
           end
        U: begin
           treble_signal = treble_filter[1];
           end
       endcase
     case(bass_present_state)
        L: begin
            bass_signal = bass_filter[0];
           end
        H: begin
            bass_signal = bass_filter[2];
           end
        U: begin
           bass_signal = bass_filter[1];
           end
        endcase
     middle_signal = input_signal - treble_filter[1] - bass_filter[1];
     output_signal <= treble_signal + bass_signal + middle_signal;
     end
          
endmodule
