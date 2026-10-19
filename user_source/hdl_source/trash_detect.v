// Color-based trash-can detector.
// Detects blue / red / green blobs, filters them by minimum area and a
// taller-than-wide shape, and outputs one bounding box per color.
module trash_detect #(
    parameter IMG_WIDTH  = 1024,
    parameter IMG_HEIGHT = 600,
    parameter BLUE_TH    = 8'd28,
    parameter RED_TH     = 8'd28,
    parameter GREEN_TH   = 8'd12,
    parameter MIN_AREA    = 17'd1200
)(
    input              I_clk,
    input              I_rst_n,
    input              I_fstart,
    input              I_de,
    input      [23:0]  I_data,

    output reg         O_blue_valid,
    output reg [10:0]  O_blue_x0,
    output reg [10:0]  O_blue_y0,
    output reg [10:0]  O_blue_x1,
    output reg [10:0]  O_blue_y1,

    output reg         O_red_valid,
    output reg [10:0]  O_red_x0,
    output reg [10:0]  O_red_y0,
    output reg [10:0]  O_red_x1,
    output reg [10:0]  O_red_y1,

    output reg         O_green_valid,
    output reg [10:0]  O_green_x0,
    output reg [10:0]  O_green_y0,
    output reg [10:0]  O_green_x1,
    output reg [10:0]  O_green_y1
);

    // Align the detector with the OSD pixel pipeline (2-cycle delay), so the
    // reported box coordinates match the displayed pixel coordinates.
    reg [23:0] d_data1, d_data2;
    reg        d_de1, d_de2;
    reg        d_fstart1, d_fstart2;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            d_data1 <= 24'd0; d_data2 <= 24'd0;
            d_de1 <= 1'b0; d_de2 <= 1'b0;
            d_fstart1 <= 1'b0; d_fstart2 <= 1'b0;
        end
        else begin
            d_data1 <= I_data; d_data2 <= d_data1;
            d_de1 <= I_de; d_de2 <= d_de1;
            d_fstart1 <= I_fstart; d_fstart2 <= d_fstart1;
        end
    end

    wire [7:0] R = d_data2[23:16];
    wire [7:0] G = d_data2[15:8];
    wire [7:0] B = d_data2[7:0];

    wire [8:0] R9 = {1'b0, R};
    wire [8:0] G9 = {1'b0, G};
    wire [8:0] B9 = {1'b0, B};
    wire [8:0] BLUE_TH9  = {1'b0, BLUE_TH};
    wire [8:0] RED_TH9   = {1'b0, RED_TH};
    wire [8:0] GREEN_TH9 = {1'b0, GREEN_TH};

    wire is_blue  = (B9 > R9 + (R9 >> 1)) && (B9 > G9 + (G9 >> 1));
    wire is_red   = (R9 > G9 + (G9 >> 1)) && (R9 > B9 + (B9 >> 1));
    wire is_green = (G9 > B9) && (R9 < 9'd60) && (G9 > 9'd40);

    reg [10:0] x;
    reg [10:0] y;

    reg        blue_seen, red_seen, green_seen;
    reg [19:0] blue_area, red_area, green_area;
    reg [10:0]  blue_min_x, blue_max_x, blue_min_y, blue_max_y;
    reg [10:0]  red_min_x,  red_max_x,  red_min_y,  red_max_y;
    reg [10:0]  green_min_x,green_max_x,green_min_y,green_max_y;

    reg [2:0]  blue_confirm, red_confirm, green_confirm;
    reg [10:0]  blue_x0, blue_y0, blue_x1, blue_y1;
    reg [10:0]  red_x0,  red_y0,  red_x1,  red_y1;
    reg [10:0]  green_x0, green_y0, green_x1, green_y1;

    wire [11:0] blue_w  = {2'b00, (blue_max_x - blue_min_x)} + 12'd1;
    wire [11:0] blue_h  = {2'b00, (blue_max_y - blue_min_y)} + 12'd1;
    wire [19:0] blue_w20 = {8'b0, blue_w};
    wire [19:0] blue_h20 = {8'b0, blue_h};
    wire [19:0] blue_box  = blue_w20 * blue_h20;
    wire [22:0] blue_area8 = {3'b0, blue_area} << 3;
    wire [22:0] blue_box23 = {3'b0, blue_box};
    wire        blue_fill_ok = blue_area8 > blue_box23;
    wire        blue_cand  = blue_seen && (blue_area > MIN_AREA) && blue_fill_ok;

    wire [11:0] red_w  = {2'b00, (red_max_x - red_min_x)} + 12'd1;
    wire [11:0] red_h  = {2'b00, (red_max_y - red_min_y)} + 12'd1;
    wire [19:0] red_w20 = {8'b0, red_w};
    wire [19:0] red_h20 = {8'b0, red_h};
    wire [19:0] red_box  = red_w20 * red_h20;
    wire [22:0] red_area8 = {3'b0, red_area} << 3;
    wire [22:0] red_box23 = {3'b0, red_box};
    wire        red_fill_ok = red_area8 > red_box23;
    wire        red_cand  = red_seen && (red_area > MIN_AREA) && red_fill_ok;

    wire [11:0] green_w  = {2'b00, (green_max_x - green_min_x)} + 12'd1;
    wire [11:0] green_h  = {2'b00, (green_max_y - green_min_y)} + 12'd1;
    wire [19:0] green_w20 = {8'b0, green_w};
    wire [19:0] green_h20 = {8'b0, green_h};
    wire [19:0] green_box  = green_w20 * green_h20;
    wire [22:0] green_area8 = {3'b0, green_area} << 3;
    wire [22:0] green_box23 = {3'b0, green_box};
    wire        green_fill_ok = green_area8 > green_box23;
    wire        green_cand  = green_seen && (green_area > MIN_AREA) && green_fill_ok;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            x <= 11'd0;
            y <= 11'd0;
            blue_seen <= 1'b0; red_seen <= 1'b0; green_seen <= 1'b0;
            blue_area <= 20'd0; red_area <= 20'd0; green_area <= 20'd0;
            blue_min_x <= IMG_WIDTH-1; blue_max_x <= 11'd0;
            blue_min_y <= IMG_HEIGHT-1; blue_max_y <= 11'd0;
            red_min_x <= IMG_WIDTH-1; red_max_x <= 11'd0;
            red_min_y <= IMG_HEIGHT-1; red_max_y <= 11'd0;
            green_min_x <= IMG_WIDTH-1; green_max_x <= 11'd0;
            green_min_y <= IMG_HEIGHT-1; green_max_y <= 11'd0;
            blue_confirm <= 3'd0; red_confirm <= 3'd0; green_confirm <= 3'd0;
            blue_x0 <= 11'd0; blue_y0 <= 11'd0; blue_x1 <= 11'd0; blue_y1 <= 11'd0;
            red_x0 <= 11'd0; red_y0 <= 11'd0; red_x1 <= 11'd0; red_y1 <= 11'd0;
            green_x0 <= 11'd0; green_y0 <= 11'd0; green_x1 <= 11'd0; green_y1 <= 11'd0;
            O_blue_valid <= 1'b0; O_red_valid <= 1'b0; O_green_valid <= 1'b0;
            O_blue_x0 <= 11'd0; O_blue_y0 <= 11'd0; O_blue_x1 <= 11'd0; O_blue_y1 <= 11'd0;
            O_red_x0 <= 11'd0; O_red_y0 <= 11'd0; O_red_x1 <= 11'd0; O_red_y1 <= 11'd0;
            O_green_x0 <= 11'd0; O_green_y0 <= 11'd0; O_green_x1 <= 11'd0; O_green_y1 <= 11'd0;
        end
        else if(d_fstart2) begin
            if(blue_cand) begin
                if(blue_confirm < 3'd7) blue_confirm <= blue_confirm + 1'b1;
                blue_x0 <= blue_min_x; blue_y0 <= blue_min_y;
                blue_x1 <= blue_max_x; blue_y1 <= blue_max_y;
            end
            else if(blue_confirm > 3'd0)
                blue_confirm <= blue_confirm - 1'b1;
            O_blue_valid <= (blue_confirm >= 3'd6);
            O_blue_x0 <= blue_x0; O_blue_y0 <= blue_y0;
            O_blue_x1 <= blue_x1; O_blue_y1 <= blue_y1;

            if(red_cand) begin
                if(red_confirm < 3'd7) red_confirm <= red_confirm + 1'b1;
                red_x0 <= red_min_x; red_y0 <= red_min_y;
                red_x1 <= red_max_x; red_y1 <= red_max_y;
            end
            else if(red_confirm > 3'd0)
                red_confirm <= red_confirm - 1'b1;
            O_red_valid <= (red_confirm >= 3'd6);
            O_red_x0 <= red_x0; O_red_y0 <= red_y0;
            O_red_x1 <= red_x1; O_red_y1 <= red_y1;

            if(green_cand) begin
                if(green_confirm < 3'd7) green_confirm <= green_confirm + 1'b1;
                green_x0 <= green_min_x; green_y0 <= green_min_y;
                green_x1 <= green_max_x; green_y1 <= green_max_y;
            end
            else if(green_confirm > 3'd0)
                green_confirm <= green_confirm - 1'b1;
            O_green_valid <= (green_confirm >= 3'd6);
            O_green_x0 <= green_x0; O_green_y0 <= green_y0;
            O_green_x1 <= green_x1; O_green_y1 <= green_y1;

            blue_seen <= 1'b0; red_seen <= 1'b0; green_seen <= 1'b0;
            blue_area <= 20'd0; red_area <= 20'd0; green_area <= 20'd0;
            blue_min_x <= IMG_WIDTH-1; blue_max_x <= 11'd0;
            blue_min_y <= IMG_HEIGHT-1; blue_max_y <= 11'd0;
            red_min_x <= IMG_WIDTH-1; red_max_x <= 11'd0;
            red_min_y <= IMG_HEIGHT-1; red_max_y <= 11'd0;
            green_min_x <= IMG_WIDTH-1; green_max_x <= 11'd0;
            green_min_y <= IMG_HEIGHT-1; green_max_y <= 11'd0;
            x <= 11'd0;
            y <= 11'd0;
        end
        else if(d_de2) begin
            if(is_blue) begin
                blue_seen <= 1'b1;
                blue_area <= blue_area + 20'd1;
                if(x < blue_min_x) blue_min_x <= x;
                if(x > blue_max_x) blue_max_x <= x;
                if(y < blue_min_y) blue_min_y <= y;
                if(y > blue_max_y) blue_max_y <= y;
            end
            if(is_red) begin
                red_seen <= 1'b1;
                red_area <= red_area + 20'd1;
                if(x < red_min_x) red_min_x <= x;
                if(x > red_max_x) red_max_x <= x;
                if(y < red_min_y) red_min_y <= y;
                if(y > red_max_y) red_max_y <= y;
            end
            if(is_green) begin
                green_seen <= 1'b1;
                green_area <= green_area + 20'd1;
                if(x < green_min_x) green_min_x <= x;
                if(x > green_max_x) green_max_x <= x;
                if(y < green_min_y) green_min_y <= y;
                if(y > green_max_y) green_max_y <= y;
            end
            if(x == IMG_WIDTH - 1) begin
                x <= 11'd0;
                if(y == IMG_HEIGHT - 1)
                    y <= 11'd0;
                else
                    y <= y + 1'b1;
            end
            else begin
                x <= x + 1'b1;
            end
        end
    end

endmodule
