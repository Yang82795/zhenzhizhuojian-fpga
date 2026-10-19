// Block-based frame-difference motion detector.
// Outputs one motion bounding box for the current scene, overlaid on top of
// the color-based trash-can detection.
module motion_detect #(
    parameter IMG_WIDTH  = 1024,
    parameter IMG_HEIGHT = 600,
    parameter BLOCK      = 32,
    parameter MOTION_TH  = 18'd12000,
    parameter MIN_AREA   = 17'd1
)(
    input              I_clk,
    input              I_rst_n,
    input              I_fstart,
    input              I_de,
    input      [23:0]  I_data,
    output reg         O_motion_valid,
    output reg [10:0]  O_box_x0,
    output reg [10:0]  O_box_y0,
    output reg [10:0]  O_box_x1,
    output reg [10:0]  O_box_y1
);

    localparam NX = IMG_WIDTH  / BLOCK;
    localparam NY = (IMG_HEIGHT + BLOCK - 1) / BLOCK;

    // Align with the OSD pixel pipeline.
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

    reg [10:0] x, y;
    wire [5:0] bx = x[9:5];
    wire [5:0] by = y[9:5];
    wire [9:0] idx = (by * NX) + bx;

    wire [7:0]  luma    = d_data2[15:8];
    reg  [17:0] blk_acc [0:NX-1];
    reg  [17:0] prev_val;
    (* ram_style = "block" *) reg [17:0] prev_block [0:NX*NY-1];
    wire [17:0] cur_sum = blk_acc[bx] + {10'd0, luma};

    wire finalize = d_de2 && (x[4:0] == 5'd31) &&
                    ((y[4:0] == 5'd31) || (y == IMG_HEIGHT - 1));
    wire read_en  = d_de2 && (x[4:0] == 5'd30);

    reg  first_frame;
    wire motion = (!first_frame) &&
                  ({1'b0, cur_sum} > ({1'b0, prev_val} + {1'b0, MOTION_TH}));
    wire [10:0] bx_pix = bx * BLOCK;
    wire [10:0] by_pix = by * BLOCK;

    reg        motion_seen;
    reg [19:0] motion_area;
    reg [10:0]  min_x, max_x, min_y, max_y;
    reg [2:0]  confirm;

    integer i;

    always @(posedge I_clk) begin
        if(read_en)
            prev_val <= prev_block[idx];
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            x <= 11'd0; y <= 11'd0;
            first_frame <= 1'b1;
            motion_seen <= 1'b0;
            motion_area <= 20'd0;
            min_x <= IMG_WIDTH-1; max_x <= 11'd0;
            min_y <= IMG_HEIGHT-1; max_y <= 11'd0;
            confirm <= 3'd0;
            O_motion_valid <= 1'b0;
            O_box_x0 <= 11'd0; O_box_y0 <= 11'd0;
            O_box_x1 <= 11'd0; O_box_y1 <= 11'd0;
            for(i=0; i<NX; i=i+1)
                blk_acc[i] <= 18'd0;
        end
        else if(d_fstart2) begin
            O_motion_valid <= motion_seen && (confirm >= 3'd1);
            O_box_x0 <= min_x; O_box_y0 <= min_y;
            O_box_x1 <= (max_x + BLOCK - 1);
            O_box_y1 <= ((max_y + BLOCK - 1) > (IMG_HEIGHT - 1)) ?
                        (IMG_HEIGHT - 1) : (max_y + BLOCK - 1);

            if(motion_seen && (motion_area > MIN_AREA)) begin
                if(confirm < 3'd7) confirm <= confirm + 1'b1;
            end
            else if(confirm > 3'd0)
                confirm <= confirm - 1'b1;

            first_frame <= 1'b0;
            motion_seen <= 1'b0;
            motion_area <= 20'd0;
            min_x <= IMG_WIDTH-1; max_x <= 11'd0;
            min_y <= IMG_HEIGHT-1; max_y <= 11'd0;
            x <= 11'd0; y <= 11'd0;
        end
        else if(d_de2) begin
            if(finalize) begin
                if(motion) begin
                    motion_seen <= 1'b1;
                    motion_area <= motion_area + 20'd1;
                    if(bx_pix < min_x) min_x <= bx_pix;
                    if(bx_pix > max_x) max_x <= bx_pix;
                    if(by_pix < min_y) min_y <= by_pix;
                    if(by_pix > max_y) max_y <= by_pix;
                end
                prev_block[idx] <= cur_sum;
                blk_acc[bx] <= 18'd0;
            end
            else begin
                blk_acc[bx] <= cur_sum;
            end

            if(x == IMG_WIDTH - 1) begin
                x <= 11'd0;
                if(y == IMG_HEIGHT - 1) y <= 11'd0;
                else y <= y + 1'b1;
            end
            else begin
                x <= x + 1'b1;
            end
        end
    end

endmodule
