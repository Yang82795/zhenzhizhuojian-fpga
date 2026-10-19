// Lightweight per-color target tracker.
// Keeps a persistent track ID, holds the track for LOST_TH frames after a
// detection disappears, and smooths the reported center coordinates.
module target_tracker #(
    parameter LOST_TH = 8'd10
)(
    input              I_clk,
    input              I_rst_n,
    input              I_fstart,

    input              I_blue_valid,
    input  [10:0]     I_blue_x0, I_blue_y0, I_blue_x1, I_blue_y1,
    input              I_red_valid,
    input  [10:0]     I_red_x0,  I_red_y0,  I_red_x1,  I_red_y1,
    input              I_green_valid,
    input  [10:0]     I_green_x0, I_green_y0, I_green_x1, I_green_y1,
    output reg         O_blue_valid,
    output reg [1:0]   O_blue_id,
    output reg [10:0]  O_blue_x0, O_blue_y0, O_blue_x1, O_blue_y1,
    output reg [10:0]  O_blue_cx, O_blue_cy,

    output reg         O_red_valid,
    output reg [1:0]   O_red_id,
    output reg [10:0]  O_red_x0, O_red_y0, O_red_x1, O_red_y1,
    output reg [10:0]  O_red_cx, O_red_cy,

    output reg         O_green_valid,
    output reg [1:0]   O_green_id,
    output reg [10:0]  O_green_x0, O_green_y0, O_green_x1, O_green_y1,
    output reg [10:0]  O_green_cx, O_green_cy
);

    // Slow exponential moving average: new = (3*old + new) / 4.
    // This removes most frame-to-frame bounding-box jitter when the camera is
    // stationary while still following a moving target smoothly.
    function [10:0] F_smooth;
        input [10:0] old_val;
        input [10:0] new_val;
        begin
            F_smooth = ({2'd0, old_val} * 3'd3 + {2'd0, new_val}) >> 2;
        end
    endfunction

    reg [7:0] blue_lost, red_lost, green_lost;
    reg [10:0] blue_cx, blue_cy, red_cx, red_cy, green_cx, green_cy;
    reg [10:0] blue_sx0, blue_sy0, blue_sx1, blue_sy1;
    reg [10:0] red_sx0,  red_sy0,  red_sx1,  red_sy1;
    reg [10:0] green_sx0,green_sy0,green_sx1,green_sy1;
    reg blue_svalid, red_svalid, green_svalid;

    wire [10:0] blue_det_cx = (I_blue_x0 + I_blue_x1) >> 1;
    wire [10:0] blue_det_cy = (I_blue_y0 + I_blue_y1) >> 1;
    wire [10:0] red_det_cx  = (I_red_x0  + I_red_x1)  >> 1;
    wire [10:0] red_det_cy  = (I_red_y0  + I_red_y1)  >> 1;
    wire [10:0] green_det_cx = (I_green_x0 + I_green_x1) >> 1;
    wire [10:0] green_det_cy = (I_green_y0 + I_green_y1) >> 1;
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            blue_lost <= 8'd0; red_lost <= 8'd0; green_lost <= 8'd0;
            blue_cx <= 11'd0; blue_cy <= 11'd0;
            red_cx <= 11'd0; red_cy <= 11'd0;
            green_cx <= 11'd0; green_cy <= 11'd0;
            blue_sx0 <= 11'd0; blue_sy0 <= 11'd0; blue_sx1 <= 11'd0; blue_sy1 <= 11'd0;
            red_sx0 <= 11'd0; red_sy0 <= 11'd0; red_sx1 <= 11'd0; red_sy1 <= 11'd0;
            green_sx0 <= 11'd0; green_sy0 <= 11'd0; green_sx1 <= 11'd0; green_sy1 <= 11'd0;
            blue_svalid <= 1'b0; red_svalid <= 1'b0; green_svalid <= 1'b0;
            O_blue_valid <= 1'b0; O_red_valid <= 1'b0; O_green_valid <= 1'b0;
            O_blue_id <= 2'd1; O_red_id <= 2'd2; O_green_id <= 2'd3;
            O_blue_x0 <= 11'd0; O_blue_y0 <= 11'd0; O_blue_x1 <= 11'd0; O_blue_y1 <= 11'd0;
            O_red_x0 <= 11'd0; O_red_y0 <= 11'd0; O_red_x1 <= 11'd0; O_red_y1 <= 11'd0;
            O_green_x0 <= 11'd0; O_green_y0 <= 11'd0; O_green_x1 <= 11'd0; O_green_y1 <= 11'd0;
            O_blue_cx <= 11'd0; O_blue_cy <= 11'd0;
            O_red_cx <= 11'd0; O_red_cy <= 11'd0;
            O_green_cx <= 11'd0; O_green_cy <= 11'd0;
        end
        else if(I_fstart) begin
            // Blue track
            if(I_blue_valid) begin
                blue_lost <= 8'd0;
                O_blue_valid <= 1'b1;
                if(blue_svalid) begin
                    O_blue_x0 <= (blue_sx0 + I_blue_x0) >> 1;
                    O_blue_y0 <= (blue_sy0 + I_blue_y0) >> 1;
                    O_blue_x1 <= (blue_sx1 + I_blue_x1) >> 1;
                    O_blue_y1 <= (blue_sy1 + I_blue_y1) >> 1;
                    blue_sx0 <= (blue_sx0 + I_blue_x0) >> 1;
                    blue_sy0 <= (blue_sy0 + I_blue_y0) >> 1;
                    blue_sx1 <= (blue_sx1 + I_blue_x1) >> 1;
                    blue_sy1 <= (blue_sy1 + I_blue_y1) >> 1;
                end
                else begin
                    O_blue_x0 <= I_blue_x0; O_blue_y0 <= I_blue_y0;
                    O_blue_x1 <= I_blue_x1; O_blue_y1 <= I_blue_y1;
                    blue_sx0 <= I_blue_x0; blue_sy0 <= I_blue_y0;
                    blue_sx1 <= I_blue_x1; blue_sy1 <= I_blue_y1;
                    blue_svalid <= 1'b1;
                end
                blue_cx <= ({1'b0, blue_cx} + {1'b0, blue_det_cx}) >> 1;
                blue_cy <= ({1'b0, blue_cy} + {1'b0, blue_det_cy}) >> 1;
            end
            else begin
                if(blue_lost < LOST_TH) begin
                    blue_lost <= blue_lost + 1'b1;
                end
                else begin
                    O_blue_valid <= 1'b0;
                end
            end

            // Red track
            if(I_red_valid) begin
                red_lost <= 8'd0;
                O_red_valid <= 1'b1;
                if(red_svalid) begin
                    O_red_x0 <= (red_sx0 + I_red_x0) >> 1;
                    O_red_y0 <= (red_sy0 + I_red_y0) >> 1;
                    O_red_x1 <= (red_sx1 + I_red_x1) >> 1;
                    O_red_y1 <= (red_sy1 + I_red_y1) >> 1;
                    red_sx0 <= (red_sx0 + I_red_x0) >> 1;
                    red_sy0 <= (red_sy0 + I_red_y0) >> 1;
                    red_sx1 <= (red_sx1 + I_red_x1) >> 1;
                    red_sy1 <= (red_sy1 + I_red_y1) >> 1;
                end
                else begin
                    O_red_x0 <= I_red_x0; O_red_y0 <= I_red_y0;
                    O_red_x1 <= I_red_x1; O_red_y1 <= I_red_y1;
                    red_sx0 <= I_red_x0; red_sy0 <= I_red_y0;
                    red_sx1 <= I_red_x1; red_sy1 <= I_red_y1;
                    red_svalid <= 1'b1;
                end
                red_cx <= ({1'b0, red_cx} + {1'b0, red_det_cx}) >> 1;
                red_cy <= ({1'b0, red_cy} + {1'b0, red_det_cy}) >> 1;
            end
            else begin
                if(red_lost < LOST_TH) begin
                    red_lost <= red_lost + 1'b1;
                end
                else begin
                    O_red_valid <= 1'b0;
                end
            end

            // Green track
            if(I_green_valid) begin
                green_lost <= 8'd0;
                O_green_valid <= 1'b1;
                if(green_svalid) begin
                    O_green_x0 <= F_smooth(green_sx0, I_green_x0);
                    O_green_y0 <= F_smooth(green_sy0, I_green_y0);
                    O_green_x1 <= F_smooth(green_sx1, I_green_x1);
                    O_green_y1 <= F_smooth(green_sy1, I_green_y1);
                    green_sx0 <= F_smooth(green_sx0, I_green_x0);
                    green_sy0 <= F_smooth(green_sy0, I_green_y0);
                    green_sx1 <= F_smooth(green_sx1, I_green_x1);
                    green_sy1 <= F_smooth(green_sy1, I_green_y1);
                end
                else begin
                    O_green_x0 <= I_green_x0; O_green_y0 <= I_green_y0;
                    O_green_x1 <= I_green_x1; O_green_y1 <= I_green_y1;
                    green_sx0 <= I_green_x0; green_sy0 <= I_green_y0;
                    green_sx1 <= I_green_x1; green_sy1 <= I_green_y1;
                    green_svalid <= 1'b1;
                end
                green_cx <= F_smooth(green_cx, green_det_cx);
                green_cy <= F_smooth(green_cy, green_det_cy);
            end
            else begin
                if(green_lost < LOST_TH) begin
                    green_lost <= green_lost + 1'b1;
                end
                else begin
                    O_green_valid <= 1'b0;
                end
            end

            O_blue_cx <= blue_cx; O_blue_cy <= blue_cy;
            O_red_cx <= red_cx; O_red_cy <= red_cy;
            O_green_cx <= green_cx; O_green_cy <= green_cy;
        end
    end

endmodule
