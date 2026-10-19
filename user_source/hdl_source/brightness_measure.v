// Measures frame brightness in the HDMI display domain and reports whether the
// scene is too dark, ok, or too bright once per frame.
module brightness_measure #(
    parameter DARK_SUM   = 27'd67584000,  // 110 * 614400
    parameter BRIGHT_SUM = 27'd92160000   // 150 * 614400
)(
    input              I_clk,
    input              I_rst_n,
    input              I_fstart,
    input              I_de,
    input      [23:0]  I_data,
    output reg  [1:0]  O_status,   // 01=dark, 10=bright, 00=ok
    output reg         O_toggle    // toggles once per frame
);

    reg [27:0] sum;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            sum <= 28'd0;
            O_status <= 2'b00;
            O_toggle <= 1'b0;
        end
        else if(I_fstart) begin
            if(sum < DARK_SUM)
                O_status <= 2'b01;
            else if(sum > BRIGHT_SUM)
                O_status <= 2'b10;
            else
                O_status <= 2'b00;
            O_toggle <= ~O_toggle;
            sum <= 28'd0;
        end
        else if(I_de) begin
            sum <= sum + {20'd0, I_data[15:8]};
        end
    end

endmodule
