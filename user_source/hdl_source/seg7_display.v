// Dynamic-scan 7-segment display driver for the common-anode 8-digit display.
// It shows the rightmost three digits of I_value (hundreds/tens/ones) and keeps
// the other digits blank.
module seg7_display (
    input  wire        I_clk,
    input  wire        I_rst_n,
    input  wire [10:0] I_value,
    output reg  [7:0]  O_seg,  // {dp,g,f,e,d,c,b,a}, active low
    output reg  [7:0]  O_sel   // active high digit select
);

    reg [17:0] scan_cnt;
    wire [2:0] digit_idx = scan_cnt[17:15];

    // Keep the displayed value stable for about 0.65 s so a jittery motion
    // count does not make every digit change at frame rate.
    reg [10:0] disp_value;
    reg [24:0] upd_cnt;

    reg [3:0] cur_digit;
    always @(*) begin
        case(digit_idx)
            3'd5: cur_digit = (disp_value / 10'd100) % 4'd10;
            3'd6: cur_digit = (disp_value / 10'd10)  % 4'd10;
            3'd7: cur_digit = disp_value % 4'd10;
            default: cur_digit = 4'd15;
        endcase
    end

    reg [6:0] seg_active;  // {g,f,e,d,c,b,a}, active high
    always @(*) begin
        case(cur_digit)
            4'd0: seg_active = 7'b0111111;
            4'd1: seg_active = 7'b0000110;
            4'd2: seg_active = 7'b1011011;
            4'd3: seg_active = 7'b1001111;
            4'd4: seg_active = 7'b1100110;
            4'd5: seg_active = 7'b1101101;
            4'd6: seg_active = 7'b1111101;
            4'd7: seg_active = 7'b0000111;
            4'd8: seg_active = 7'b1111111;
            4'd9: seg_active = 7'b1101111;
            default: seg_active = 7'b0000000;
        endcase
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            scan_cnt <= 16'd0;
            upd_cnt  <= 25'd0;
            disp_value <= 11'd0;
            O_sel <= 8'd0;
            O_seg <= 8'hFF;
        end
        else begin
            scan_cnt <= scan_cnt + 1'b1;
            upd_cnt  <= upd_cnt + 1'b1;
            if(upd_cnt == 25'd0)
                disp_value <= I_value;
            O_sel <= 8'b1 << digit_idx;
            O_seg <= {1'b1, ~seg_active};
        end
    end

endmodule
