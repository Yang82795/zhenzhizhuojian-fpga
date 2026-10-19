// 96-bit (4-pixel) video effect selector.
// mode 0: passthrough (original RGB)
// mode 1: grayscale
// mode 2: binarization (threshold on luma)
// mode 3: Sobel edge detection
// 3-stage pipeline is used to meet MIPI_RX_BYTE_CLK timing.
module video_process_96 #(
    parameter IMG_WIDTH  = 1024,
    parameter IMG_HEIGHT = 600,
    parameter EDGE_TH    = 11'd132,
    parameter BIN_TH     = 8'd128
)(
    input              I_clk,
    input              I_rst_n,
    input      [1:0]   I_mode,
    input              I_tlast,
    input              I_tuser,
    input      [95:0]  I_tdata,
    input              I_tvalid,
    input              I_tready,
    output reg         O_tlast,
    output reg         O_tuser,
    output reg [95:0]  O_tdata,
    output reg         O_tvalid,
    output             O_tready
);

    localparam IMG_WIDTH_GRP = IMG_WIDTH >> 2;

    assign O_tready = I_tready;

    // ---------------- pixel decomposition ----------------
    wire [23:0] pix0 = I_tdata[95:72];
    wire [23:0] pix1 = I_tdata[71:48];
    wire [23:0] pix2 = I_tdata[47:24];
    wire [23:0] pix3 = I_tdata[23:0];

    // Min-channel "luma": min(R,G,B). White markings keep a high min value
    // while saturated colored bins (red/green/blue) drop to a low min value,
    // which separates white icons from colored bin bodies far better than
    // a weighted grayscale.
    function [7:0] min3;
        input [7:0] a, b, c;
        reg [7:0] ab;
        begin
            ab = (a < b) ? a : b;
            min3 = (ab < c) ? ab : c;
        end
    endfunction

    wire [7:0] luma0 = min3(pix0[23:16], pix0[15:8], pix0[7:0]);
    wire [7:0] luma1 = min3(pix1[23:16], pix1[15:8], pix1[7:0]);
    wire [7:0] luma2 = min3(pix2[23:16], pix2[15:8], pix2[7:0]);
    wire [7:0] luma3 = min3(pix3[23:16], pix3[15:8], pix3[7:0]);

    // Pre-stage: register the min-channel luma so the min3 compare chain does
    // not sit in series with the downstream sum / smoothing / line-buffer path.
    reg [7:0]  luma0_r, luma1_r, luma2_r, luma3_r;
    reg [95:0] data_r;
    reg        last_r, user_r, valid_r;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            luma0_r <= 8'd0;
            luma1_r <= 8'd0;
            luma2_r <= 8'd0;
            luma3_r <= 8'd0;
            data_r  <= 96'd0;
            last_r  <= 1'b0;
            user_r  <= 1'b0;
            valid_r <= 1'b0;
        end
        else begin
            luma0_r <= luma0;
            luma1_r <= luma1;
            luma2_r <= luma2;
            luma3_r <= luma3;
            data_r  <= I_tdata;
            last_r  <= I_tlast;
            user_r  <= I_tuser;
            valid_r <= I_tvalid;
        end
    end

    wire [23:0] gp0 = {luma0_r, luma0_r, luma0_r};
    wire [23:0] gp1 = {luma1_r, luma1_r, luma1_r};
    wire [23:0] gp2 = {luma2_r, luma2_r, luma2_r};
    wire [23:0] gp3 = {luma3_r, luma3_r, luma3_r};

    wire [23:0] bp0 = (luma0_r >= BIN_TH) ? 24'hFFFFFF : 24'h000000;
    wire [23:0] bp1 = (luma1_r >= BIN_TH) ? 24'hFFFFFF : 24'h000000;
    wire [23:0] bp2 = (luma2_r >= BIN_TH) ? 24'hFFFFFF : 24'h000000;
    wire [23:0] bp3 = (luma3_r >= BIN_TH) ? 24'hFFFFFF : 24'h000000;

    wire [7:0] grp_gray = ({2'b0, luma0_r} + {2'b0, luma1_r} + {2'b0, luma2_r} + {2'b0, luma3_r}) >> 2;

    // ---------------- line buffers / smoothing ----------------
    (* ram_style = "block" *) reg [7:0] line1_mem [0:IMG_WIDTH_GRP-1];
    (* ram_style = "block" *) reg [7:0] line2_mem [0:IMG_WIDTH_GRP-1];

    reg [10:0] x_grp;
    reg [10:0] y_pos;
    reg [7:0]  prev_grp_gray_d1;
    reg [7:0]  prev_grp_gray_d2;

    reg [7:0] smooth_gray;

    always @(*) begin
        if(x_grp == 11'd0)
            smooth_gray = grp_gray;
        else if(x_grp == 11'd1)
            smooth_gray = ({2'b0, grp_gray} + {2'b0, prev_grp_gray_d1}) >> 1;
        else
            smooth_gray = ({2'b0, grp_gray} + {1'b0, prev_grp_gray_d1, 1'b0} + {2'b0, prev_grp_gray_d2}) >> 2;
    end

    // ---------------- stage 1 registers ----------------
    reg        st1_valid;
    reg        st1_last;
    reg        st1_user;
    reg [95:0] st1_orig;
    reg [95:0] st1_gray;
    reg [95:0] st1_bin;
    reg [7:0]  st1_smooth;
    reg [7:0]  st1_top;
    reg [7:0]  st1_mid;
    reg [10:0] st1_x;
    reg [10:0] st1_y;

    integer i;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            st1_valid  <= 1'b0;
            st1_last   <= 1'b0;
            st1_user   <= 1'b0;
            st1_orig   <= 96'd0;
            st1_gray   <= 96'd0;
            st1_bin    <= 96'd0;
            st1_smooth <= 8'd0;
            st1_top    <= 8'd0;
            st1_mid    <= 8'd0;
            st1_x      <= 11'd0;
            st1_y      <= 11'd0;
            x_grp      <= 11'd0;
            y_pos      <= 11'd0;
            prev_grp_gray_d1 <= 8'd0;
            prev_grp_gray_d2 <= 8'd0;
            for(i=0; i<IMG_WIDTH_GRP; i=i+1) begin
                line1_mem[i] <= 8'd0;
                line2_mem[i] <= 8'd0;
            end
        end
        else begin
            st1_last  <= last_r;
            st1_user  <= user_r;
            st1_orig  <= data_r;
            st1_gray  <= {gp3, gp2, gp1, gp0};
            st1_bin   <= {bp3, bp2, bp1, bp0};

            if(valid_r) begin
                st1_valid  <= 1'b1;
                st1_smooth <= smooth_gray;
                st1_top    <= line2_mem[x_grp];
                st1_mid    <= line1_mem[x_grp];
                st1_x      <= x_grp;
                st1_y      <= y_pos;

                line1_mem[x_grp] <= smooth_gray;
                line2_mem[x_grp] <= line1_mem[x_grp];

                prev_grp_gray_d2 <= prev_grp_gray_d1;
                prev_grp_gray_d1 <= grp_gray;

                if(user_r) begin
                    x_grp <= 11'd0;
                    y_pos <= 11'd0;
                    prev_grp_gray_d1 <= 8'd0;
                    prev_grp_gray_d2 <= 8'd0;
                end
                else if(x_grp == IMG_WIDTH_GRP - 1) begin
                    x_grp <= 11'd0;
                    if(y_pos == IMG_HEIGHT - 1)
                        y_pos <= 11'd0;
                    else
                        y_pos <= y_pos + 1'b1;
                end
                else begin
                    x_grp <= x_grp + 1'b1;
                end
            end
            else begin
                st1_valid <= 1'b0;
            end
        end
    end

    // ---------------- stage 2 registers ----------------
    reg        st2_valid;
    reg        st2_last;
    reg        st2_user;
    reg [95:0] st2_orig;
    reg [95:0] st2_gray;
    reg [95:0] st2_bin;
    reg [10:0] st2_x;
    reg [10:0] st2_y;

    reg [7:0] r0c0, r0c1, r0c2;
    reg [7:0] r1c0, r1c1, r1c2;
    reg [7:0] r2c0, r2c1, r2c2;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            st2_valid <= 1'b0;
            st2_last  <= 1'b0;
            st2_user  <= 1'b0;
            st2_orig  <= 96'd0;
            st2_gray  <= 96'd0;
            st2_bin   <= 96'd0;
            st2_x     <= 11'd0;
            st2_y     <= 11'd0;
            r0c0 <= 8'd0; r0c1 <= 8'd0; r0c2 <= 8'd0;
            r1c0 <= 8'd0; r1c1 <= 8'd0; r1c2 <= 8'd0;
            r2c0 <= 8'd0; r2c1 <= 8'd0; r2c2 <= 8'd0;
        end
        else begin
            st2_valid <= st1_valid;
            st2_last  <= st1_last;
            st2_user  <= st1_user;
            st2_orig  <= st1_orig;
            st2_gray  <= st1_gray;
            st2_bin   <= st1_bin;
            st2_x     <= st1_x;
            st2_y     <= st1_y;

            if(st1_valid) begin
                if(st1_user) begin
                    r0c0 <= 8'd0; r0c1 <= 8'd0; r0c2 <= st1_top;
                    r1c0 <= 8'd0; r1c1 <= 8'd0; r1c2 <= st1_mid;
                    r2c0 <= 8'd0; r2c1 <= 8'd0; r2c2 <= st1_smooth;
                end
                else begin
                    r0c0 <= r0c1; r0c1 <= r0c2; r0c2 <= st1_top;
                    r1c0 <= r1c1; r1c1 <= r1c2; r1c2 <= st1_mid;
                    r2c0 <= r2c1; r2c1 <= r2c2; r2c2 <= st1_smooth;
                end
            end
        end
    end

    // ---------------- stage 3: Sobel + output mux ----------------
    reg        edge_hist_d1;
    reg        edge_hist_d2;
    reg signed [12:0] gx;
    reg signed [12:0] gy;
    reg [12:0] abs_gx;
    reg [12:0] abs_gy;
    reg [13:0] mag;
    reg        edge_flag;
    reg        edge_flag_filt;
    reg [23:0] out_pix;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            O_tlast      <= 1'b0;
            O_tuser      <= 1'b0;
            O_tvalid     <= 1'b0;
            O_tdata      <= 96'd0;
            edge_hist_d1 <= 1'b0;
            edge_hist_d2 <= 1'b0;
        end
        else begin
            O_tlast  <= st2_last;
            O_tuser  <= st2_user;
            O_tvalid <= st2_valid;

            if(st2_valid) begin
                if((st2_x >= 11'd2) && (st2_y >= 11'd2)) begin
                    gx = -$signed({5'b0,r0c0}) + $signed({5'b0,r0c2})
                         - ($signed({5'b0,r1c0}) <<< 1) + ($signed({5'b0,r1c2}) <<< 1)
                         - $signed({5'b0,r2c0}) + $signed({5'b0,r2c2});

                    gy =  $signed({5'b0,r0c0}) + ($signed({5'b0,r0c1}) <<< 1) + $signed({5'b0,r0c2})
                         - $signed({5'b0,r2c0}) - ($signed({5'b0,r2c1}) <<< 1) - $signed({5'b0,r2c2});

                    abs_gx    = gx[12] ? (~gx + 1'b1) : gx;
                    abs_gy    = gy[12] ? (~gy + 1'b1) : gy;
                    mag       = abs_gx + abs_gy;
                    edge_flag = (mag >= EDGE_TH);
                end
                else begin
                    edge_flag = 1'b0;
                end

                edge_flag_filt = (edge_flag & edge_hist_d1) |
                                 (edge_flag & edge_hist_d2) |
                                 (edge_hist_d1 & edge_hist_d2);
                edge_hist_d2 <= edge_hist_d1;
                edge_hist_d1 <= edge_flag;

                out_pix = edge_flag_filt ? 24'hFFFFFF : 24'h000000;

                case(I_mode)
                    2'd0:    O_tdata <= st2_orig;
                    2'd1:    O_tdata <= st2_gray;
                    2'd2:    O_tdata <= st2_bin;
                    default: O_tdata <= {out_pix, out_pix, out_pix, out_pix};
                endcase
            end
            else begin
                O_tdata      <= 96'd0;
                edge_hist_d1 <= 1'b0;
                edge_hist_d2 <= 1'b0;
            end
        end
    end

endmodule
