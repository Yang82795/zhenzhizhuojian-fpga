module hdmi_mixer #(
    parameter H_OFFSET = 128,
    parameter V_OFFSET = 60,
    parameter IMG_WIDTH = 1024,
    parameter IMG_HEIGHT = 600,
    parameter integer DEBUG_MODE = 0
)(
    input wire        I_clk,
    input wire        I_rst_n,

    input wire        I_video_vsync,
    input wire        I_video_hsync,
    input wire        I_video_de,
    input wire        I_video_user,
    input wire        I_video_last,

    input wire[3:0]   I_debug_status,
    input wire[1:0]   I_video_mode,
    input wire        I_blue_valid,
    input wire[10:0]  I_blue_x0,
    input wire[10:0]  I_blue_y0,
    input wire[10:0]  I_blue_x1,
    input wire[10:0]  I_blue_y1,
    input wire        I_red_valid,
    input wire[10:0]  I_red_x0,
    input wire[10:0]  I_red_y0,
    input wire[10:0]  I_red_x1,
    input wire[10:0]  I_red_y1,
    input wire        I_green_valid,
    input wire[10:0]  I_green_x0,
    input wire[10:0]  I_green_y0,
    input wire[10:0]  I_green_x1,
    input wire[10:0]  I_green_y1,
    input wire[10:0]  I_blue_cx,
    input wire[10:0]  I_blue_cy,
    input wire[10:0]  I_red_cx,
    input wire[10:0]  I_red_cy,
    input wire[10:0]  I_green_cx,
    input wire[10:0]  I_green_cy,
    input wire        I_auto_ae_on,
    input wire        I_motion_track_on,
    input wire        I_motion_valid,
    input wire[10:0]  I_motion_x0,
    input wire[10:0]  I_motion_y0,
    input wire[10:0]  I_motion_x1,
    input wire[10:0]  I_motion_y1,
    input wire[15:0]  I_latency_frames,
    input wire        I_lte_ok,

    output wire       O_video_rd_en,
    input wire[23:0]  I_video_rd_data,

    output reg        O_hdmi_vsync,
    output reg        O_hdmi_hsync,
    output reg        O_hdmi_de,
    output reg[23:0]  O_hdmi_data
);

    reg        S_video_vsync_1d;
    reg        S_video_vsync_2d;
    reg        S_video_hsync_1d;
    reg        S_video_hsync_2d;
    reg        S_video_de_1d;
    reg        S_video_de_2d;
    reg [23:0] S_video_data_1d;
    reg [23:0] S_video_data_2d;
    reg [11:0] S_x;
    reg [11:0] S_y;
    reg [11:0] S_x_1d;
    reg [11:0] S_x_2d;
    reg [11:0] S_y_1d;
    reg [11:0] S_y_2d;

    reg        S_osd_hit;
    reg [23:0] S_osd_color;
    reg [11:0] S_logo_x;
    reg [11:0] S_logo_y;
    reg [3:0]  S_char_idx;
    reg [2:0]  S_char_row;
    reg [2:0]  S_char_col;
    reg [4:0]  S_char_bits;
    reg        S_char_on;
    reg        S_logo_blue_on;
    reg        S_logo_red_on;
    reg [11:0] S_logo_tmp_y;
    reg [3:0]  S_logo_red_band;
    reg [11:0] S_logo_red_x_start;
    reg [11:0] S_logo_red_x_end;
    reg [14:0] S_logo_addr;
    wire[24:0] S_logo_pixel;
    reg [31:0] S_frame_cnt;
    reg [11:0] S_dyn_x;
    reg [11:0] S_dyn_y;
    reg [3:0]  S_dyn_char;
    reg [2:0]  S_dyn_col;
    reg [2:0]  S_dyn_row;
    reg [4:0]  S_dyn_bits;
    reg        S_dyn_on;
    reg [3:0]  S_dyn_digit_idx;
    reg [11:0] S_dyn_digit_x;
    reg [6:0]  S_dyn_seg;
    reg [3:0]  S_cnt_d0;
    reg [3:0]  S_cnt_d1;
    reg [3:0]  S_cnt_d2;
    reg [3:0]  S_cnt_d3;
    reg [3:0]  S_cnt_d4;
    reg [3:0]  S_cnt_d5;
    reg [2:0]  S_lbl_row;
    reg [2:0]  S_lbl_col;
    reg [1:0]  S_lbl_idx;
    reg [4:0]  S_lbl_bits;
    reg [6:0]  S_lbl_local_x;
    reg [3:0]  S_dyn_dec_digit;
    reg [4:0]  S_cn_local_x;
    reg [4:0]  S_cn_local_y;
    reg [3:0]  S_cn_col;
    reg [3:0]  S_cn_row;
    reg  [15:0] S_cn_row_bits;
    wire [15:0] S_cn_row_bits_c;
    reg        S_cn_on;
    reg [9:0]  S_cn_scale_x;
    reg [9:0]  S_cn_scale_y;
    reg [7:0]  S_pf_char;
    reg [4:0]  S_pf_local_x;
    reg [4:0]  S_pf_local_y;
    reg [3:0]  S_pf_col;
    reg [3:0]  S_pf_row;
    reg  [15:0] S_pf_row_bits;
    wire [15:0] S_pf_row_bits_c;
    reg        S_pf_on;
    reg [9:0]  S_pf_scale_x;
    reg [9:0]  S_pf_scale_y;
    reg [11:0] S_mode_x;
    reg [11:0] S_mode_y;
    reg [7:0]  S_cn_char;

    localparam LOGO_X = 12'd0;
    localparam LOGO_Y = 12'd0;
    localparam LOGO_W = 12'd160;
    localparam LOGO_H = 12'd160;

    localparam COLOR_LOGO_BLUE   = 24'h1f315c;
    localparam COLOR_LOGO_RED    = 24'hec1c2d;
    localparam COLOR_TEXT        = 24'h00e6ff;
    localparam DYN_OSD_X         = 12'd820;
    localparam DYN_OSD_Y         = 12'd8;
    localparam DYN_OSD_W         = 12'd192;
    localparam DYN_OSD_H         = 12'd16;
    localparam CN_Y_OFFSET       = 12'd2;
    localparam COLOR_DYN_TEXT    = 24'h00ffff;
    localparam CHAR_AN           = 8'h80;
    localparam CHAR_LU           = 8'h81;
    localparam CHAR_C            = 8'h43;
    localparam CHAR_N            = 8'h4e;
    localparam CHAR_T            = 8'h54;
    localparam CHAR_0            = 8'h30;
    localparam CHAR_4            = 8'h34;
    localparam CHAR_G            = 8'h47;
    localparam CHAR_COLON        = 8'h3a;
    localparam CHAR_SLASH        = 8'h2f;
    localparam CHAR_PERIOD       = 8'h2e;
    localparam CHAR_SPACE        = 8'h20;
    localparam CHAR_a            = 8'h61;
    localparam CHAR_b            = 8'h62;
    localparam CHAR_c            = 8'h63;
    localparam CHAR_d            = 8'h64;
    localparam CHAR_e            = 8'h65;
    localparam CHAR_g            = 8'h67;
    localparam CHAR_i            = 8'h69;
    localparam CHAR_k            = 8'h6b;
    localparam CHAR_m            = 8'h6d;
    localparam CHAR_n            = 8'h6e;
    localparam CHAR_o            = 8'h6f;
    localparam CHAR_r            = 8'h72;
    localparam CHAR_s            = 8'h73;
    localparam CHAR_y            = 8'h79;
    localparam CHAR_M            = 8'h4d;
    localparam CHAR_O            = 8'h4f;
    localparam CHAR_D            = 8'h44;
    localparam CHAR_E            = 8'h45;

    localparam MODE_OSD_X        = 12'd820;
    localparam MODE_OSD_Y        = 12'd560;
    localparam MODE_OSD_W        = 12'd96;
    localparam MODE_OSD_H        = 12'd16;
    localparam COLOR_MODE_TEXT   = 24'h00ff00;
    localparam COLOR_MOTION_BOX  = 24'hff0000;
    localparam BOX_TH            = 12'd5;
    localparam COLOR_BLUE_TEXT   = 24'h0000ff;
    localparam COLOR_RED_TEXT    = 24'hff0000;
    localparam COLOR_GREEN_TEXT  = 24'h00ff00;

    localparam CN_KE    = 8'hA0;
    localparam CN_HUI   = 8'hA1;
    localparam CN_SHOU  = 8'hA2;
    localparam CN_LA    = 8'hA3;
    localparam CN_JI    = 8'hA4;
    localparam CN_TONG  = 8'hA5;
    localparam CN_YOU   = 8'hA6;
    localparam CN_HAI   = 8'hA7;
    localparam CN_CHU   = 8'hA8;
    localparam CN_YU    = 8'hA9;
    localparam CN_ZI    = 8'hAA;
    localparam CN_DONG  = 8'hAB;
    localparam CN_PU    = 8'hAC;
    localparam CN_GUANG = 8'hAD;
    localparam CN_KAI   = 8'hAE;
    localparam CN_QI    = 8'hAF;
    localparam CN_GUAN  = 8'hB0;
    localparam CN_BI    = 8'hB1;
    localparam CN_QI2   = 8'hB2;
    localparam CN_TA    = 8'hB3;
    localparam CN_WU    = 8'hB4;
    localparam CN_YUN   = 8'hB5;
    localparam CN_GEN   = 8'hB6;
    localparam CN_ZONG  = 8'hB7;
    localparam CN_MU    = 8'hB8;
    localparam CN_BIAO  = 8'hB9;
    localparam CN_JIAN  = 8'hBA;
    localparam CN_CE    = 8'hBB;
    localparam CN_ZHONG = 8'hBC;
    localparam CN_DOT   = 8'hBD;
    localparam CN_BAI   = 8'hBE;   // 白
    localparam CN_PING  = 8'hBF;   // 平
    localparam CN_HENG  = 8'hC0;   // 衡
    localparam CN_YAN   = 8'hC1;   // 延
    localparam CN_CHI   = 8'hC2;   // 迟
    localparam CN_ZHEN  = 8'hC3;   // 帧
    localparam CN_YIJ   = 8'hC4;   // 已
    localparam CN_LIAN  = 8'hC5;   // 连
    localparam CN_JIE   = 8'hC6;   // 接
    localparam CN_WEI   = 8'hC7;   // 未

    localparam LAT_OSD_X      = 12'd780;
    localparam LAT_OSD_Y      = 12'd32;
    localparam WB_OSD_X       = 12'd8;
    localparam WB_OSD_Y       = 12'd544;
    localparam AE_OSD_X       = 12'd8;
    localparam AE_OSD_Y       = 12'd560;
    localparam MOTION_OSD_X   = 12'd8;
    localparam MOTION_OSD_Y   = 12'd576;
    localparam SIGN_OSD_X     = 12'd424;
    localparam SIGN_OSD_Y     = 12'd584;
    localparam SIGN_OSD_W     = 12'd176;
    localparam SIGN_OSD_H     = 12'd16;
    localparam COLOR_AE_TEXT  = 24'hffff00;
    localparam COLOR_SIGN     = 24'hffffff;
    localparam COLOR_COORD    = 24'hffffff;
    localparam COLOR_MOTION   = 24'hffff00;
    localparam COLOR_LAT      = 24'h00ffff;
    localparam LTE_OSD_X      = 12'd200;
    localparam LTE_OSD_Y      = 12'd8;
    localparam LTE_OSD_W      = 12'd80;
    localparam LTE_OSD_H      = 12'd16;
    localparam COLOR_LTE_OK   = 24'h00ff00;
    localparam COLOR_LTE_BAD  = 24'hff0000;
    localparam MOTION_BOX_TH  = 12'd12;
    localparam ID_BLUE        = 8'h31;
    localparam ID_RED         = 8'h32;
    localparam ID_GREEN       = 8'h33;

    function [4:0] F_logo_text_bits;
        input [3:0] I_char;
        input [2:0] I_row;
        begin
            case(I_char)
                4'd0: begin
                    case(I_row) // A
                        3'd0: F_logo_text_bits = 5'b01110;
                        3'd1: F_logo_text_bits = 5'b10001;
                        3'd2: F_logo_text_bits = 5'b10001;
                        3'd3: F_logo_text_bits = 5'b11111;
                        3'd4: F_logo_text_bits = 5'b10001;
                        3'd5: F_logo_text_bits = 5'b10001;
                        3'd6: F_logo_text_bits = 5'b10001;
                        default: F_logo_text_bits = 5'b00000;
                    endcase
                end
                4'd1: begin
                    case(I_row) // N
                        3'd0: F_logo_text_bits = 5'b10001;
                        3'd1: F_logo_text_bits = 5'b11001;
                        3'd2: F_logo_text_bits = 5'b10101;
                        3'd3: F_logo_text_bits = 5'b10011;
                        3'd4: F_logo_text_bits = 5'b10001;
                        3'd5: F_logo_text_bits = 5'b10001;
                        3'd6: F_logo_text_bits = 5'b10001;
                        default: F_logo_text_bits = 5'b00000;
                    endcase
                end
                4'd2: begin
                    case(I_row) // L
                        3'd0: F_logo_text_bits = 5'b10000;
                        3'd1: F_logo_text_bits = 5'b10000;
                        3'd2: F_logo_text_bits = 5'b10000;
                        3'd3: F_logo_text_bits = 5'b10000;
                        3'd4: F_logo_text_bits = 5'b10000;
                        3'd5: F_logo_text_bits = 5'b10000;
                        3'd6: F_logo_text_bits = 5'b11111;
                        default: F_logo_text_bits = 5'b00000;
                    endcase
                end
                4'd3: begin
                    case(I_row) // O
                        3'd0: F_logo_text_bits = 5'b01110;
                        3'd1: F_logo_text_bits = 5'b10001;
                        3'd2: F_logo_text_bits = 5'b10001;
                        3'd3: F_logo_text_bits = 5'b10001;
                        3'd4: F_logo_text_bits = 5'b10001;
                        3'd5: F_logo_text_bits = 5'b10001;
                        3'd6: F_logo_text_bits = 5'b01110;
                        default: F_logo_text_bits = 5'b00000;
                    endcase
                end
                4'd4: begin
                    case(I_row) // G
                        3'd0: F_logo_text_bits = 5'b01110;
                        3'd1: F_logo_text_bits = 5'b10001;
                        3'd2: F_logo_text_bits = 5'b10000;
                        3'd3: F_logo_text_bits = 5'b10111;
                        3'd4: F_logo_text_bits = 5'b10001;
                        3'd5: F_logo_text_bits = 5'b10001;
                        3'd6: F_logo_text_bits = 5'b01110;
                        default: F_logo_text_bits = 5'b00000;
                    endcase
                end
                4'd5: begin
                    case(I_row) // I
                        3'd0: F_logo_text_bits = 5'b11111;
                        3'd1: F_logo_text_bits = 5'b00100;
                        3'd2: F_logo_text_bits = 5'b00100;
                        3'd3: F_logo_text_bits = 5'b00100;
                        3'd4: F_logo_text_bits = 5'b00100;
                        3'd5: F_logo_text_bits = 5'b00100;
                        3'd6: F_logo_text_bits = 5'b11111;
                        default: F_logo_text_bits = 5'b00000;
                    endcase
                end
                4'd6: begin
                    case(I_row) // C
                        3'd0: F_logo_text_bits = 5'b01110;
                        3'd1: F_logo_text_bits = 5'b10001;
                        3'd2: F_logo_text_bits = 5'b10000;
                        3'd3: F_logo_text_bits = 5'b10000;
                        3'd4: F_logo_text_bits = 5'b10000;
                        3'd5: F_logo_text_bits = 5'b10001;
                        3'd6: F_logo_text_bits = 5'b01110;
                        default: F_logo_text_bits = 5'b00000;
                    endcase
                end
                default: F_logo_text_bits = 5'b00000;
            endcase
        end
    endfunction

    // 7-seg bit mapping: {a,b,c,d,e,f,g}
    function [6:0] F_hex7seg;
        input [3:0] I_hex;
        begin
            case(I_hex)
                4'h0: F_hex7seg = 7'b1111110;
                4'h1: F_hex7seg = 7'b0110000;
                4'h2: F_hex7seg = 7'b1101101;
                4'h3: F_hex7seg = 7'b1111001;
                4'h4: F_hex7seg = 7'b0110011;
                4'h5: F_hex7seg = 7'b1011011;
                4'h6: F_hex7seg = 7'b1011111;
                4'h7: F_hex7seg = 7'b1110000;
                4'h8: F_hex7seg = 7'b1111111;
                4'h9: F_hex7seg = 7'b1111011;
                4'ha: F_hex7seg = 7'b1110111;
                4'hb: F_hex7seg = 7'b0011111;
                4'hc: F_hex7seg = 7'b1001110;
                4'hd: F_hex7seg = 7'b0111101;
                4'he: F_hex7seg = 7'b1001111;
                4'hf: F_hex7seg = 7'b1000111;
                default: F_hex7seg = 7'b0000000;
            endcase
        end
    endfunction

    function [4:0] F_cnt_label_bits;
        input [1:0] I_idx;
        input [2:0] I_row;
        begin
            case(I_idx)
                2'd0: begin // C
                    case(I_row)
                        3'd0: F_cnt_label_bits = 5'b01110;
                        3'd1: F_cnt_label_bits = 5'b10001;
                        3'd2: F_cnt_label_bits = 5'b10000;
                        3'd3: F_cnt_label_bits = 5'b10000;
                        3'd4: F_cnt_label_bits = 5'b10000;
                        3'd5: F_cnt_label_bits = 5'b10001;
                        3'd6: F_cnt_label_bits = 5'b01110;
                        default: F_cnt_label_bits = 5'b00000;
                    endcase
                end
                2'd1: begin // N
                    case(I_row)
                        3'd0: F_cnt_label_bits = 5'b10001;
                        3'd1: F_cnt_label_bits = 5'b11001;
                        3'd2: F_cnt_label_bits = 5'b10101;
                        3'd3: F_cnt_label_bits = 5'b10011;
                        3'd4: F_cnt_label_bits = 5'b10001;
                        3'd5: F_cnt_label_bits = 5'b10001;
                        3'd6: F_cnt_label_bits = 5'b10001;
                        default: F_cnt_label_bits = 5'b00000;
                    endcase
                end
                2'd2: begin // T
                    case(I_row)
                        3'd0: F_cnt_label_bits = 5'b11111;
                        3'd1: F_cnt_label_bits = 5'b00100;
                        3'd2: F_cnt_label_bits = 5'b00100;
                        3'd3: F_cnt_label_bits = 5'b00100;
                        3'd4: F_cnt_label_bits = 5'b00100;
                        3'd5: F_cnt_label_bits = 5'b00100;
                        3'd6: F_cnt_label_bits = 5'b00100;
                        default: F_cnt_label_bits = 5'b00000;
                    endcase
                end
                default: begin // ':'
                    case(I_row)
                        3'd2: F_cnt_label_bits = 5'b00100;
                        3'd5: F_cnt_label_bits = 5'b00100;
                        default: F_cnt_label_bits = 5'b00000;
                    endcase
                end
            endcase
        end
    endfunction

    // Minimal 16x16 Chinese bitmap rows for "an" and "lu".
    function [15:0] F_cn16_row;
        input I_char; // 0: an, 1: lu
        input [3:0] I_row;
        begin
            if(!I_char) begin
                case(I_row)
                    4'd0:  F_cn16_row = 16'h0200;
                    4'd1:  F_cn16_row = 16'h7ff0;
                    4'd2:  F_cn16_row = 16'h4410;
                    4'd3:  F_cn16_row = 16'h0400;
                    4'd4:  F_cn16_row = 16'h7ff0;
                    4'd5:  F_cn16_row = 16'h0840;
                    4'd6:  F_cn16_row = 16'h1040;
                    4'd7:  F_cn16_row = 16'h1c80;
                    4'd8:  F_cn16_row = 16'h0300;
                    4'd9:  F_cn16_row = 16'h0cc0;
                    4'd10: F_cn16_row = 16'h7020;
                    4'd11: F_cn16_row = 16'h0000;
                    4'd12: F_cn16_row = 16'h0000;
                    4'd13: F_cn16_row = 16'h0000;
                    4'd14: F_cn16_row = 16'h0000;
                    4'd15: F_cn16_row = 16'h0000;
                    default: F_cn16_row = 16'h0000;
                endcase
            end
            else begin
                case(I_row)
                    4'd0:  F_cn16_row = 16'h79e0;
                    4'd1:  F_cn16_row = 16'h4a20;
                    4'd2:  F_cn16_row = 16'h4d40;
                    4'd3:  F_cn16_row = 16'h7880;
                    4'd4:  F_cn16_row = 16'h1140;
                    4'd5:  F_cn16_row = 16'h1630;
                    4'd6:  F_cn16_row = 16'h5be0;
                    4'd7:  F_cn16_row = 16'h5220;
                    4'd8:  F_cn16_row = 16'h5220;
                    4'd9:  F_cn16_row = 16'h5be0;
                    4'd10: F_cn16_row = 16'h6220;
                    4'd11: F_cn16_row = 16'h0000;
                    4'd12: F_cn16_row = 16'h0000;
                    4'd13: F_cn16_row = 16'h0000;
                    4'd14: F_cn16_row = 16'h0000;
                    4'd15: F_cn16_row = 16'h0000;
                    default: F_cn16_row = 16'h0000;
                endcase
            end
        end
    endfunction

    function [4:0] F_dyn_char_bits;
        input [3:0] I_char;
        input [2:0] I_row;
        begin
            case(I_char)
                4'h0: begin case(I_row) 3'd0:F_dyn_char_bits=5'b01110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b10011; 3'd3:F_dyn_char_bits=5'b10101; 3'd4:F_dyn_char_bits=5'b11001; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b01110; default:F_dyn_char_bits=5'b00000; endcase end
                4'h1: begin case(I_row) 3'd0:F_dyn_char_bits=5'b00100; 3'd1:F_dyn_char_bits=5'b01100; 3'd2:F_dyn_char_bits=5'b00100; 3'd3:F_dyn_char_bits=5'b00100; 3'd4:F_dyn_char_bits=5'b00100; 3'd5:F_dyn_char_bits=5'b00100; 3'd6:F_dyn_char_bits=5'b01110; default:F_dyn_char_bits=5'b00000; endcase end
                4'h2: begin case(I_row) 3'd0:F_dyn_char_bits=5'b01110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b00001; 3'd3:F_dyn_char_bits=5'b00110; 3'd4:F_dyn_char_bits=5'b01000; 3'd5:F_dyn_char_bits=5'b10000; 3'd6:F_dyn_char_bits=5'b11111; default:F_dyn_char_bits=5'b00000; endcase end
                4'h3: begin case(I_row) 3'd0:F_dyn_char_bits=5'b11110; 3'd1:F_dyn_char_bits=5'b00001; 3'd2:F_dyn_char_bits=5'b00001; 3'd3:F_dyn_char_bits=5'b01110; 3'd4:F_dyn_char_bits=5'b00001; 3'd5:F_dyn_char_bits=5'b00001; 3'd6:F_dyn_char_bits=5'b11110; default:F_dyn_char_bits=5'b00000; endcase end
                4'h4: begin case(I_row) 3'd0:F_dyn_char_bits=5'b00010; 3'd1:F_dyn_char_bits=5'b00110; 3'd2:F_dyn_char_bits=5'b01010; 3'd3:F_dyn_char_bits=5'b10010; 3'd4:F_dyn_char_bits=5'b11111; 3'd5:F_dyn_char_bits=5'b00010; 3'd6:F_dyn_char_bits=5'b00010; default:F_dyn_char_bits=5'b00000; endcase end
                4'h5: begin case(I_row) 3'd0:F_dyn_char_bits=5'b11111; 3'd1:F_dyn_char_bits=5'b10000; 3'd2:F_dyn_char_bits=5'b11110; 3'd3:F_dyn_char_bits=5'b00001; 3'd4:F_dyn_char_bits=5'b00001; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b01110; default:F_dyn_char_bits=5'b00000; endcase end
                4'h6: begin case(I_row) 3'd0:F_dyn_char_bits=5'b00110; 3'd1:F_dyn_char_bits=5'b01000; 3'd2:F_dyn_char_bits=5'b10000; 3'd3:F_dyn_char_bits=5'b11110; 3'd4:F_dyn_char_bits=5'b10001; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b01110; default:F_dyn_char_bits=5'b00000; endcase end
                4'h7: begin case(I_row) 3'd0:F_dyn_char_bits=5'b11111; 3'd1:F_dyn_char_bits=5'b00001; 3'd2:F_dyn_char_bits=5'b00010; 3'd3:F_dyn_char_bits=5'b00100; 3'd4:F_dyn_char_bits=5'b01000; 3'd5:F_dyn_char_bits=5'b01000; 3'd6:F_dyn_char_bits=5'b01000; default:F_dyn_char_bits=5'b00000; endcase end
                4'h8: begin case(I_row) 3'd0:F_dyn_char_bits=5'b01110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b10001; 3'd3:F_dyn_char_bits=5'b01110; 3'd4:F_dyn_char_bits=5'b10001; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b01110; default:F_dyn_char_bits=5'b00000; endcase end
                4'h9: begin case(I_row) 3'd0:F_dyn_char_bits=5'b01110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b10001; 3'd3:F_dyn_char_bits=5'b01111; 3'd4:F_dyn_char_bits=5'b00001; 3'd5:F_dyn_char_bits=5'b00010; 3'd6:F_dyn_char_bits=5'b11100; default:F_dyn_char_bits=5'b00000; endcase end
                4'ha: begin case(I_row) 3'd0:F_dyn_char_bits=5'b01110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b10001; 3'd3:F_dyn_char_bits=5'b11111; 3'd4:F_dyn_char_bits=5'b10001; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b10001; default:F_dyn_char_bits=5'b00000; endcase end
                4'hb: begin case(I_row) 3'd0:F_dyn_char_bits=5'b11110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b10001; 3'd3:F_dyn_char_bits=5'b11110; 3'd4:F_dyn_char_bits=5'b10001; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b11110; default:F_dyn_char_bits=5'b00000; endcase end
                4'hc: begin case(I_row) 3'd0:F_dyn_char_bits=5'b01110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b10000; 3'd3:F_dyn_char_bits=5'b10000; 3'd4:F_dyn_char_bits=5'b10000; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b01110; default:F_dyn_char_bits=5'b00000; endcase end
                4'hd: begin case(I_row) 3'd0:F_dyn_char_bits=5'b11110; 3'd1:F_dyn_char_bits=5'b10001; 3'd2:F_dyn_char_bits=5'b10001; 3'd3:F_dyn_char_bits=5'b10001; 3'd4:F_dyn_char_bits=5'b10001; 3'd5:F_dyn_char_bits=5'b10001; 3'd6:F_dyn_char_bits=5'b11110; default:F_dyn_char_bits=5'b00000; endcase end
                4'he: begin case(I_row) 3'd0:F_dyn_char_bits=5'b11111; 3'd1:F_dyn_char_bits=5'b10000; 3'd2:F_dyn_char_bits=5'b10000; 3'd3:F_dyn_char_bits=5'b11110; 3'd4:F_dyn_char_bits=5'b10000; 3'd5:F_dyn_char_bits=5'b10000; 3'd6:F_dyn_char_bits=5'b11111; default:F_dyn_char_bits=5'b00000; endcase end
                4'hf: begin case(I_row) 3'd0:F_dyn_char_bits=5'b11111; 3'd1:F_dyn_char_bits=5'b10000; 3'd2:F_dyn_char_bits=5'b10000; 3'd3:F_dyn_char_bits=5'b11110; 3'd4:F_dyn_char_bits=5'b10000; 3'd5:F_dyn_char_bits=5'b10000; 3'd6:F_dyn_char_bits=5'b10000; default:F_dyn_char_bits=5'b00000; endcase end
                default: F_dyn_char_bits = 5'b00000;
            endcase
        end
    endfunction

    // Unified prefix character library (16x16 rows): an/lu/C/N/T/:
    function [15:0] F_osd_char16_row;
        input [7:0] I_char;
        input [3:0] I_row;
        begin
            case(I_char)
                CHAR_AN: begin
                    case(I_row)
                        4'd0:  F_osd_char16_row = 16'h0200;
                        4'd1:  F_osd_char16_row = 16'h7ff0;
                        4'd2:  F_osd_char16_row = 16'h4410;
                        4'd3:  F_osd_char16_row = 16'h0400;
                        4'd4:  F_osd_char16_row = 16'h7ff0;
                        4'd5:  F_osd_char16_row = 16'h0840;
                        4'd6:  F_osd_char16_row = 16'h1040;
                        4'd7:  F_osd_char16_row = 16'h1c80;
                        4'd8:  F_osd_char16_row = 16'h0300;
                        4'd9:  F_osd_char16_row = 16'h0cc0;
                        4'd10: F_osd_char16_row = 16'h7020;
                        default: F_osd_char16_row = 16'h0000;
                    endcase
                end
                CHAR_LU: begin
                    case(I_row)
                        4'd0:  F_osd_char16_row = 16'h79e0;
                        4'd1:  F_osd_char16_row = 16'h4a20;
                        4'd2:  F_osd_char16_row = 16'h4d40;
                        4'd3:  F_osd_char16_row = 16'h7880;
                        4'd4:  F_osd_char16_row = 16'h1140;
                        4'd5:  F_osd_char16_row = 16'h1630;
                        4'd6:  F_osd_char16_row = 16'h5be0;
                        4'd7:  F_osd_char16_row = 16'h5220;
                        4'd8:  F_osd_char16_row = 16'h5220;
                        4'd9:  F_osd_char16_row = 16'h5be0;
                        4'd10: F_osd_char16_row = 16'h6220;
                        default: F_osd_char16_row = 16'h0000;
                    endcase
                end
                CHAR_C: begin
                    case(I_row)
                        4'd2:  F_osd_char16_row = 16'h03f0;
                        4'd3:  F_osd_char16_row = 16'h0c0c;
                        4'd4:  F_osd_char16_row = 16'h1800;
                        4'd5:  F_osd_char16_row = 16'h3000;
                        4'd6:  F_osd_char16_row = 16'h3000;
                        4'd7:  F_osd_char16_row = 16'h3000;
                        4'd8:  F_osd_char16_row = 16'h3000;
                        4'd9:  F_osd_char16_row = 16'h3000;
                        4'd10: F_osd_char16_row = 16'h1800;
                        4'd11: F_osd_char16_row = 16'h0c0c;
                        4'd12: F_osd_char16_row = 16'h03f0;
                        default: F_osd_char16_row = 16'h0000;
                    endcase
                end
                CHAR_N: begin
                    case(I_row)
                        4'd2:  F_osd_char16_row = 16'h300c;
                        4'd3:  F_osd_char16_row = 16'h380c;
                        4'd4:  F_osd_char16_row = 16'h3c0c;
                        4'd5:  F_osd_char16_row = 16'h360c;
                        4'd6:  F_osd_char16_row = 16'h330c;
                        4'd7:  F_osd_char16_row = 16'h318c;
                        4'd8:  F_osd_char16_row = 16'h30cc;
                        4'd9:  F_osd_char16_row = 16'h306c;
                        4'd10: F_osd_char16_row = 16'h303c;
                        4'd11: F_osd_char16_row = 16'h301c;
                        4'd12: F_osd_char16_row = 16'h300c;
                        default: F_osd_char16_row = 16'h0000;
                    endcase
                end
                CHAR_T: begin
                    case(I_row)
                        4'd2:  F_osd_char16_row = 16'h3ffc;
                        4'd3:  F_osd_char16_row = 16'h03c0;
                        4'd4:  F_osd_char16_row = 16'h03c0;
                        4'd5:  F_osd_char16_row = 16'h03c0;
                        4'd6:  F_osd_char16_row = 16'h03c0;
                        4'd7:  F_osd_char16_row = 16'h03c0;
                        4'd8:  F_osd_char16_row = 16'h03c0;
                        4'd9:  F_osd_char16_row = 16'h03c0;
                        4'd10: F_osd_char16_row = 16'h03c0;
                        4'd11: F_osd_char16_row = 16'h03c0;
                        4'd12: F_osd_char16_row = 16'h03c0;
                        default: F_osd_char16_row = 16'h0000;
                    endcase
                end
                CHAR_COLON: begin
                    case(I_row)
                        4'd6:  F_osd_char16_row = 16'h0180;
                        4'd7:  F_osd_char16_row = 16'h0180;
                        4'd10: F_osd_char16_row = 16'h0180;
                        4'd11: F_osd_char16_row = 16'h0180;
                        default: F_osd_char16_row = 16'h0000;
                    endcase
                end
                default: F_osd_char16_row = 16'h0000;
            endcase
        end
    endfunction

    assign O_video_rd_en = I_video_de;

    wire [3:0] blue_x_d2 = I_blue_cx / 10'd100;
    wire [3:0] blue_x_d1 = (I_blue_cx / 10'd10) % 4'd10;
    wire [3:0] blue_x_d0 = I_blue_cx % 4'd10;
    wire [3:0] blue_y_d2 = I_blue_cy / 10'd100;
    wire [3:0] blue_y_d1 = (I_blue_cy / 10'd10) % 4'd10;
    wire [3:0] blue_y_d0 = I_blue_cy % 4'd10;

    wire [3:0] red_x_d2 = I_red_cx / 10'd100;
    wire [3:0] red_x_d1 = (I_red_cx / 10'd10) % 4'd10;
    wire [3:0] red_x_d0 = I_red_cx % 4'd10;
    wire [3:0] red_y_d2 = I_red_cy / 10'd100;
    wire [3:0] red_y_d1 = (I_red_cy / 10'd10) % 4'd10;
    wire [3:0] red_y_d0 = I_red_cy % 4'd10;

    wire [3:0] green_x_d2 = I_green_cx / 10'd100;
    wire [3:0] green_x_d1 = (I_green_cx / 10'd10) % 4'd10;
    wire [3:0] green_x_d0 = I_green_cx % 4'd10;
    wire [3:0] green_y_d2 = I_green_cy / 10'd100;
    wire [3:0] green_y_d1 = (I_green_cy / 10'd10) % 4'd10;
    wire [3:0] green_y_d0 = I_green_cy % 4'd10;

    wire [11:0] motion_cx = (I_motion_x0 + I_motion_x1) >> 1;
    wire [11:0] motion_cy = (I_motion_y0 + I_motion_y1) >> 1;
    wire [3:0]  lat_d1    = (I_latency_frames[6:0] / 7'd10);
    wire [3:0]  lat_d0    = (I_latency_frames[6:0] % 7'd10);
    wire [15:0] lat_ms_tenths = I_latency_frames * 16'd167;
    wire [11:0] lat_ms_int    = lat_ms_tenths / 16'd10;
    wire [3:0]  lat_ms_frac   = lat_ms_tenths % 16'd10;
    wire [3:0]  lat_ms_tens   = (lat_ms_int / 8'd10) % 4'd10;
    wire [3:0]  lat_ms_ones   = lat_ms_int % 8'd10;

    anlogic_logo_rom u_anlogic_logo_rom(
        .I_addr  ( S_logo_addr  ),
        .O_pixel ( S_logo_pixel )
    );

    osd_char_lib u_osd_char_lib(
        .I_char     ( S_pf_char     ),
        .I_row      ( S_pf_row      ),
        .O_row_bits ( S_pf_row_bits_c )
    );

    cn_char_lib u_cn_char_lib(
        .I_char     ( S_cn_char     ),
        .I_row      ( S_cn_row      ),
        .O_row_bits ( S_cn_row_bits_c )
    );

    // Register the font ROM outputs to break combinational feedback loops.
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            S_pf_row_bits <= 16'd0;
            S_cn_row_bits <= 16'd0;
        end
        else begin
            S_pf_row_bits <= S_pf_row_bits_c;
            S_cn_row_bits <= S_cn_row_bits_c;
        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            S_x <= 12'd0;
            S_y <= 12'd0;
        end
        else if(I_video_user) begin
            S_x <= 12'd0;
            S_y <= 12'd0;
        end
        else if(I_video_de) begin
            if(I_video_last) begin
                S_x <= 12'd0;
                S_y <= S_y + 12'd1;
            end
            else begin
                S_x <= S_x + 12'd1;
            end
        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            S_frame_cnt <= 32'd0;
            S_cnt_d0 <= 4'd0;
            S_cnt_d1 <= 4'd0;
            S_cnt_d2 <= 4'd0;
            S_cnt_d3 <= 4'd0;
            S_cnt_d4 <= 4'd0;
            S_cnt_d5 <= 4'd0;
        end
        else if(I_video_user) begin
            S_frame_cnt <= S_frame_cnt + 32'd1;
            if(S_cnt_d0 == 4'd9) begin
                S_cnt_d0 <= 4'd0;
                if(S_cnt_d1 == 4'd9) begin
                    S_cnt_d1 <= 4'd0;
                    if(S_cnt_d2 == 4'd9) begin
                        S_cnt_d2 <= 4'd0;
                        if(S_cnt_d3 == 4'd9) begin
                            S_cnt_d3 <= 4'd0;
                            if(S_cnt_d4 == 4'd9) begin
                                S_cnt_d4 <= 4'd0;
                                if(S_cnt_d5 == 4'd9)
                                    S_cnt_d5 <= 4'd0;
                                else
                                    S_cnt_d5 <= S_cnt_d5 + 4'd1;
                            end
                            else
                                S_cnt_d4 <= S_cnt_d4 + 4'd1;
                        end
                        else
                            S_cnt_d3 <= S_cnt_d3 + 4'd1;
                    end
                    else
                        S_cnt_d2 <= S_cnt_d2 + 4'd1;
                end
                else
                    S_cnt_d1 <= S_cnt_d1 + 4'd1;
            end
            else
                S_cnt_d0 <= S_cnt_d0 + 4'd1;
        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            S_x_1d <= 12'd0;
            S_x_2d <= 12'd0;
            S_y_1d <= 12'd0;
            S_y_2d <= 12'd0;
        end
        else begin
            S_x_1d <= S_x;
            S_x_2d <= S_x_1d;
            S_y_1d <= S_y;
            S_y_2d <= S_y_1d;
        end
    end

    always @(*) begin
        S_osd_hit   = 1'b0;
        S_osd_color = 24'd0;
        S_logo_addr = 15'd0;

        S_logo_x = 12'd0;
        S_logo_y = 12'd0;
        S_char_idx = 4'd0;
        S_char_row = 3'd0;
        S_char_col = 3'd0;
        S_char_bits = 5'd0;
        S_char_on = 1'b0;
        S_logo_blue_on = 1'b0;
        S_logo_red_on = 1'b0;
        S_logo_tmp_y = 12'd0;
        S_logo_red_band = 4'd0;
        S_logo_red_x_start = 12'd0;
        S_logo_red_x_end = 12'd0;
        S_dyn_x = 12'd0;
        S_dyn_y = 12'd0;
        S_dyn_char = 4'd0;
        S_dyn_col = 3'd0;
        S_dyn_row = 3'd0;
        S_dyn_bits = 5'd0;
        S_dyn_on = 1'b0;
        S_dyn_digit_idx = 4'd0;
        S_dyn_digit_x = 12'd0;
        S_dyn_seg = 7'd0;
        S_lbl_row = 3'd0;
        S_lbl_col = 3'd0;
        S_lbl_idx = 2'd0;
        S_lbl_bits = 5'd0;
        S_lbl_local_x = 7'd0;
        S_dyn_dec_digit = 4'd0;
        S_cn_local_x = 5'd0;
        S_cn_local_y = 5'd0;
        S_cn_col = 4'd0;
        S_cn_row = 4'd0;
        S_cn_on = 1'b0;
        S_cn_char = 8'd0;
        S_cn_scale_x = 10'd0;
        S_cn_scale_y = 10'd0;
        S_pf_char = 8'd0;
        S_pf_local_x = 5'd0;
        S_pf_local_y = 5'd0;
        S_pf_col = 4'd0;
        S_pf_row = 4'd0;
        S_pf_on = 1'b0;
        S_pf_scale_x = 10'd0;
        S_pf_scale_y = 10'd0;
        S_mode_x = 12'd0;
        S_mode_y = 12'd0;

        if(S_video_de_2d) begin
            if((S_x_2d >= LOGO_X) && (S_x_2d < (LOGO_X + LOGO_W)) &&
               (S_y_2d >= LOGO_Y) && (S_y_2d < (LOGO_Y + LOGO_H))) begin
                S_logo_x = S_x_2d - LOGO_X;
                S_logo_y = S_y_2d - LOGO_Y;
                S_logo_addr = (S_logo_y << 7) + (S_logo_y << 5) + S_logo_x;
                if(S_logo_pixel[24]) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = S_logo_pixel[23:0];
                end
            end

            if((!S_osd_hit) &&
               (S_x_2d >= DYN_OSD_X) && (S_x_2d < (DYN_OSD_X + DYN_OSD_W)) &&
               (S_y_2d >= DYN_OSD_Y) && (S_y_2d < (DYN_OSD_Y + DYN_OSD_H))) begin
                S_dyn_x = S_x_2d - DYN_OSD_X;
                S_dyn_y = S_y_2d - DYN_OSD_Y;

                // Unified 16x16 rendering: 安路 CNT: + 6 decimal digits.
                if(S_dyn_y < 12'd16) begin
                    if(S_dyn_x < 12'd16) begin
                        S_pf_char = CHAR_AN;
                        S_pf_local_x = S_dyn_x;
                    end
                    else if(S_dyn_x < 12'd32) begin
                        S_pf_char = CHAR_LU;
                        S_pf_local_x = S_dyn_x - 12'd16;
                    end
                    else if(S_dyn_x < 12'd48) begin
                        S_pf_char = CHAR_C;
                        S_pf_local_x = S_dyn_x - 12'd32;
                    end
                    else if(S_dyn_x < 12'd64) begin
                        S_pf_char = CHAR_N;
                        S_pf_local_x = S_dyn_x - 12'd48;
                    end
                    else if(S_dyn_x < 12'd80) begin
                        S_pf_char = CHAR_T;
                        S_pf_local_x = S_dyn_x - 12'd64;
                    end
                    else if(S_dyn_x < 12'd96) begin
                        S_pf_char = CHAR_COLON;
                        S_pf_local_x = S_dyn_x - 12'd80;
                    end
                    else if(S_dyn_x < 12'd112) begin
                        S_pf_char = CHAR_0 + {4'd0, S_cnt_d5};
                        S_pf_local_x = S_dyn_x - 12'd96;
                    end
                    else if(S_dyn_x < 12'd128) begin
                        S_pf_char = CHAR_0 + {4'd0, S_cnt_d4};
                        S_pf_local_x = S_dyn_x - 12'd112;
                    end
                    else if(S_dyn_x < 12'd144) begin
                        S_pf_char = CHAR_0 + {4'd0, S_cnt_d3};
                        S_pf_local_x = S_dyn_x - 12'd128;
                    end
                    else if(S_dyn_x < 12'd160) begin
                        S_pf_char = CHAR_0 + {4'd0, S_cnt_d2};
                        S_pf_local_x = S_dyn_x - 12'd144;
                    end
                    else if(S_dyn_x < 12'd176) begin
                        S_pf_char = CHAR_0 + {4'd0, S_cnt_d1};
                        S_pf_local_x = S_dyn_x - 12'd160;
                    end
                    else if(S_dyn_x < 12'd192) begin
                        S_pf_char = CHAR_0 + {4'd0, S_cnt_d0};
                        S_pf_local_x = S_dyn_x - 12'd176;
                    end

                    S_pf_local_y = S_dyn_y;
                    S_pf_col = S_pf_local_x[3:0];
                    S_pf_row = S_pf_local_y[3:0];
                    case(S_pf_col)
                        4'd0:  S_pf_on = S_pf_row_bits[15];
                        4'd1:  S_pf_on = S_pf_row_bits[14];
                        4'd2:  S_pf_on = S_pf_row_bits[13];
                        4'd3:  S_pf_on = S_pf_row_bits[12];
                        4'd4:  S_pf_on = S_pf_row_bits[11];
                        4'd5:  S_pf_on = S_pf_row_bits[10];
                        4'd6:  S_pf_on = S_pf_row_bits[9];
                        4'd7:  S_pf_on = S_pf_row_bits[8];
                        4'd8:  S_pf_on = S_pf_row_bits[7];
                        4'd9:  S_pf_on = S_pf_row_bits[6];
                        4'd10: S_pf_on = S_pf_row_bits[5];
                        4'd11: S_pf_on = S_pf_row_bits[4];
                        4'd12: S_pf_on = S_pf_row_bits[3];
                        4'd13: S_pf_on = S_pf_row_bits[2];
                        4'd14: S_pf_on = S_pf_row_bits[1];
                        4'd15: S_pf_on = S_pf_row_bits[0];
                        default: S_pf_on = 1'b0;
                    endcase
                    if(S_pf_on)
                        S_dyn_on = 1'b1;
                end

                if(S_dyn_on) begin
                    S_osd_hit = 1'b1;
                    S_osd_color = COLOR_DYN_TEXT;
                end
            end

            if((!S_osd_hit) &&
               (S_x_2d >= MODE_OSD_X) && (S_x_2d < (MODE_OSD_X + MODE_OSD_W)) &&
               (S_y_2d >= MODE_OSD_Y) && (S_y_2d < (MODE_OSD_Y + MODE_OSD_H))) begin
                S_mode_x = S_x_2d - MODE_OSD_X;
                S_mode_y = S_y_2d - MODE_OSD_Y;

                if(S_mode_x < 12'd16)
                    S_pf_char = CHAR_M;
                else if(S_mode_x < 12'd32)
                    S_pf_char = CHAR_O;
                else if(S_mode_x < 12'd48)
                    S_pf_char = CHAR_D;
                else if(S_mode_x < 12'd64)
                    S_pf_char = CHAR_E;
                else if(S_mode_x < 12'd80)
                    S_pf_char = CHAR_COLON;
                else
                    S_pf_char = CHAR_0 + {2'b00, I_video_mode};

                S_pf_local_x = S_mode_x[3:0];
                S_pf_local_y = S_mode_y[3:0];
                S_pf_col = S_pf_local_x[3:0];
                S_pf_row = S_pf_local_y[3:0];

                case(S_pf_col)
                    4'd0:  S_pf_on = S_pf_row_bits[15];
                    4'd1:  S_pf_on = S_pf_row_bits[14];
                    4'd2:  S_pf_on = S_pf_row_bits[13];
                    4'd3:  S_pf_on = S_pf_row_bits[12];
                    4'd4:  S_pf_on = S_pf_row_bits[11];
                    4'd5:  S_pf_on = S_pf_row_bits[10];
                    4'd6:  S_pf_on = S_pf_row_bits[9];
                    4'd7:  S_pf_on = S_pf_row_bits[8];
                    4'd8:  S_pf_on = S_pf_row_bits[7];
                    4'd9:  S_pf_on = S_pf_row_bits[6];
                    4'd10: S_pf_on = S_pf_row_bits[5];
                    4'd11: S_pf_on = S_pf_row_bits[4];
                    4'd12: S_pf_on = S_pf_row_bits[3];
                    4'd13: S_pf_on = S_pf_row_bits[2];
                    4'd14: S_pf_on = S_pf_row_bits[1];
                    4'd15: S_pf_on = S_pf_row_bits[0];
                    default: S_pf_on = 1'b0;
                endcase

                if(S_pf_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_MODE_TEXT;
                end
            end

            if((!S_osd_hit) && I_blue_valid &&
               (S_x_2d >= I_blue_x0) && (S_x_2d <= I_blue_x1) &&
               (S_y_2d >= I_blue_y0) && (S_y_2d <= I_blue_y1) &&
               ((S_x_2d - I_blue_x0 < BOX_TH) ||
                (I_blue_x1 - S_x_2d < BOX_TH) ||
                (S_y_2d - I_blue_y0 < BOX_TH) ||
                (I_blue_y1 - S_y_2d < BOX_TH))) begin
                S_osd_hit   = 1'b1;
                S_osd_color = I_motion_valid ? COLOR_MOTION : COLOR_MOTION_BOX;
            end

            if((!S_osd_hit) && I_blue_valid &&
               (S_x_2d >= I_blue_x0 + 12'd4) && (S_x_2d < I_blue_x0 + 12'd68) &&
               (S_y_2d >= I_blue_y0 + 12'd4) && (S_y_2d < I_blue_y0 + 12'd20)) begin
                S_mode_x = S_x_2d - (I_blue_x0 + 12'd4);
                S_mode_y = S_y_2d - (I_blue_y0 + 12'd4);
                if(S_mode_x < 12'd16)      S_cn_char = CN_KE;
                else if(S_mode_x < 12'd32) S_cn_char = CN_HUI;
                else if(S_mode_x < 12'd48) S_cn_char = CN_SHOU;
                else                       S_cn_char = CN_WU;
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_BLUE_TEXT;
                end
            end

            if((!S_osd_hit) && I_red_valid &&
               (S_x_2d >= I_red_x0) && (S_x_2d <= I_red_x1) &&
               (S_y_2d >= I_red_y0) && (S_y_2d <= I_red_y1) &&
               ((S_x_2d - I_red_x0 < BOX_TH) ||
                (I_red_x1 - S_x_2d < BOX_TH) ||
                (S_y_2d - I_red_y0 < BOX_TH) ||
                (I_red_y1 - S_y_2d < BOX_TH))) begin
                S_osd_hit   = 1'b1;
                S_osd_color = I_motion_valid ? COLOR_MOTION : COLOR_MOTION_BOX;
            end

            if((!S_osd_hit) && I_red_valid &&
               (S_x_2d >= I_red_x0 + 12'd4) && (S_x_2d < I_red_x0 + 12'd68) &&
               (S_y_2d >= I_red_y0 + 12'd4) && (S_y_2d < I_red_y0 + 12'd20)) begin
                S_mode_x = S_x_2d - (I_red_x0 + 12'd4);
                S_mode_y = S_y_2d - (I_red_y0 + 12'd4);
                if(S_mode_x < 12'd16)      S_cn_char = CN_YOU;
                else if(S_mode_x < 12'd32) S_cn_char = CN_HAI;
                else if(S_mode_x < 12'd48) S_cn_char = CN_LA;
                else                       S_cn_char = CN_JI;
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_RED_TEXT;
                end
            end

            if((!S_osd_hit) && I_green_valid &&
               (S_x_2d >= I_green_x0) && (S_x_2d <= I_green_x1) &&
               (S_y_2d >= I_green_y0) && (S_y_2d <= I_green_y1) &&
               ((S_x_2d - I_green_x0 < BOX_TH) ||
                (I_green_x1 - S_x_2d < BOX_TH) ||
                (S_y_2d - I_green_y0 < BOX_TH) ||
                (I_green_y1 - S_y_2d < BOX_TH))) begin
                S_osd_hit   = 1'b1;
                S_osd_color = I_motion_valid ? COLOR_MOTION : COLOR_MOTION_BOX;
            end

            if((!S_osd_hit) && I_green_valid &&
               (S_x_2d >= I_green_x0 + 12'd4) && (S_x_2d < I_green_x0 + 12'd68) &&
               (S_y_2d >= I_green_y0 + 12'd4) && (S_y_2d < I_green_y0 + 12'd20)) begin
                S_mode_x = S_x_2d - (I_green_x0 + 12'd4);
                S_mode_y = S_y_2d - (I_green_y0 + 12'd4);
                if(S_mode_x < 12'd16)      S_cn_char = CN_CHU;
                else if(S_mode_x < 12'd32) S_cn_char = CN_YU;
                else if(S_mode_x < 12'd48) S_cn_char = CN_LA;
                else                       S_cn_char = CN_JI;
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_GREEN_TEXT;
                end
            end

            if((!S_osd_hit) && I_motion_valid && I_blue_valid &&
               (S_x_2d >= I_blue_cx - 12'd64) && (S_x_2d < I_blue_cx + 12'd64) &&
               (S_y_2d >= I_blue_cy - 12'd8) && (S_y_2d < I_blue_cy + 12'd8)) begin
                S_mode_x = S_x_2d - (I_blue_cx - 12'd64);
                S_mode_y = S_y_2d - (I_blue_cy - 12'd8);
                case(S_mode_x[7:4])
                    4'd0: S_cn_char = CN_YUN;
                    4'd1: S_cn_char = CN_DONG;
                    4'd2: S_cn_char = CN_MU;
                    4'd3: S_cn_char = CN_BIAO;
                    4'd4: S_cn_char = CN_JIAN;
                    4'd5: S_cn_char = CN_CE;
                    4'd6: S_cn_char = CN_ZHONG;
                    4'd7: S_cn_char = CN_DOT;
                    default: S_cn_char = 8'h00;
                endcase
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_MOTION;
                end
            end

            if((!S_osd_hit) && I_motion_valid && I_red_valid &&
               (S_x_2d >= I_red_cx - 12'd64) && (S_x_2d < I_red_cx + 12'd64) &&
               (S_y_2d >= I_red_cy - 12'd8) && (S_y_2d < I_red_cy + 12'd8)) begin
                S_mode_x = S_x_2d - (I_red_cx - 12'd64);
                S_mode_y = S_y_2d - (I_red_cy - 12'd8);
                case(S_mode_x[7:4])
                    4'd0: S_cn_char = CN_YUN;
                    4'd1: S_cn_char = CN_DONG;
                    4'd2: S_cn_char = CN_MU;
                    4'd3: S_cn_char = CN_BIAO;
                    4'd4: S_cn_char = CN_JIAN;
                    4'd5: S_cn_char = CN_CE;
                    4'd6: S_cn_char = CN_ZHONG;
                    4'd7: S_cn_char = CN_DOT;
                    default: S_cn_char = 8'h00;
                endcase
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_MOTION;
                end
            end

            if((!S_osd_hit) && I_motion_valid && I_green_valid &&
               (S_x_2d >= I_green_cx - 12'd64) && (S_x_2d < I_green_cx + 12'd64) &&
               (S_y_2d >= I_green_cy - 12'd8) && (S_y_2d < I_green_cy + 12'd8)) begin
                S_mode_x = S_x_2d - (I_green_cx - 12'd64);
                S_mode_y = S_y_2d - (I_green_cy - 12'd8);
                case(S_mode_x[7:4])
                    4'd0: S_cn_char = CN_YUN;
                    4'd1: S_cn_char = CN_DONG;
                    4'd2: S_cn_char = CN_MU;
                    4'd3: S_cn_char = CN_BIAO;
                    4'd4: S_cn_char = CN_JIAN;
                    4'd5: S_cn_char = CN_CE;
                    4'd6: S_cn_char = CN_ZHONG;
                    4'd7: S_cn_char = CN_DOT;
                    default: S_cn_char = 8'h00;
                endcase
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_MOTION;
                end
            end

            if((!S_osd_hit) && I_blue_valid &&
               (S_x_2d >= I_blue_x0) && (S_x_2d < I_blue_x0 + 12'd144) &&
               (S_y_2d >= I_blue_y0 + 12'd20) && (S_y_2d < I_blue_y0 + 12'd36)) begin
                S_mode_x = S_x_2d - I_blue_x0;
                S_mode_y = S_y_2d - (I_blue_y0 + 12'd20);
                case(S_mode_x[7:4])
                    4'd0: S_pf_char = ID_BLUE;
                    4'd1: S_pf_char = CHAR_COLON;
                    4'd2: S_pf_char = CHAR_0 + {3'b000, blue_x_d2};
                    4'd3: S_pf_char = CHAR_0 + {3'b000, blue_x_d1};
                    4'd4: S_pf_char = CHAR_0 + {3'b000, blue_x_d0};
                    4'd5: S_pf_char = CHAR_COLON;
                    4'd6: S_pf_char = CHAR_0 + {3'b000, blue_y_d2};
                    4'd7: S_pf_char = CHAR_0 + {3'b000, blue_y_d1};
                    4'd8: S_pf_char = CHAR_0 + {3'b000, blue_y_d0};
                    default: S_pf_char = 8'h00;
                endcase
                S_pf_col = S_mode_x[3:0];
                S_pf_row = S_mode_y[3:0];
                case(S_pf_col)
                    4'd0:  S_pf_on = S_pf_row_bits[15];
                    4'd1:  S_pf_on = S_pf_row_bits[14];
                    4'd2:  S_pf_on = S_pf_row_bits[13];
                    4'd3:  S_pf_on = S_pf_row_bits[12];
                    4'd4:  S_pf_on = S_pf_row_bits[11];
                    4'd5:  S_pf_on = S_pf_row_bits[10];
                    4'd6:  S_pf_on = S_pf_row_bits[9];
                    4'd7:  S_pf_on = S_pf_row_bits[8];
                    4'd8:  S_pf_on = S_pf_row_bits[7];
                    4'd9:  S_pf_on = S_pf_row_bits[6];
                    4'd10: S_pf_on = S_pf_row_bits[5];
                    4'd11: S_pf_on = S_pf_row_bits[4];
                    4'd12: S_pf_on = S_pf_row_bits[3];
                    4'd13: S_pf_on = S_pf_row_bits[2];
                    4'd14: S_pf_on = S_pf_row_bits[1];
                    4'd15: S_pf_on = S_pf_row_bits[0];
                    default: S_pf_on = 1'b0;
                endcase
                if(S_pf_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_COORD;
                end
            end

            if((!S_osd_hit) && I_red_valid &&
               (S_x_2d >= I_red_x0) && (S_x_2d < I_red_x0 + 12'd144) &&
               (S_y_2d >= I_red_y0 + 12'd20) && (S_y_2d < I_red_y0 + 12'd36)) begin
                S_mode_x = S_x_2d - I_red_x0;
                S_mode_y = S_y_2d - (I_red_y0 + 12'd20);
                case(S_mode_x[7:4])
                    4'd0: S_pf_char = ID_RED;
                    4'd1: S_pf_char = CHAR_COLON;
                    4'd2: S_pf_char = CHAR_0 + {3'b000, red_x_d2};
                    4'd3: S_pf_char = CHAR_0 + {3'b000, red_x_d1};
                    4'd4: S_pf_char = CHAR_0 + {3'b000, red_x_d0};
                    4'd5: S_pf_char = CHAR_COLON;
                    4'd6: S_pf_char = CHAR_0 + {3'b000, red_y_d2};
                    4'd7: S_pf_char = CHAR_0 + {3'b000, red_y_d1};
                    4'd8: S_pf_char = CHAR_0 + {3'b000, red_y_d0};
                    default: S_pf_char = 8'h00;
                endcase
                S_pf_col = S_mode_x[3:0];
                S_pf_row = S_mode_y[3:0];
                case(S_pf_col)
                    4'd0:  S_pf_on = S_pf_row_bits[15];
                    4'd1:  S_pf_on = S_pf_row_bits[14];
                    4'd2:  S_pf_on = S_pf_row_bits[13];
                    4'd3:  S_pf_on = S_pf_row_bits[12];
                    4'd4:  S_pf_on = S_pf_row_bits[11];
                    4'd5:  S_pf_on = S_pf_row_bits[10];
                    4'd6:  S_pf_on = S_pf_row_bits[9];
                    4'd7:  S_pf_on = S_pf_row_bits[8];
                    4'd8:  S_pf_on = S_pf_row_bits[7];
                    4'd9:  S_pf_on = S_pf_row_bits[6];
                    4'd10: S_pf_on = S_pf_row_bits[5];
                    4'd11: S_pf_on = S_pf_row_bits[4];
                    4'd12: S_pf_on = S_pf_row_bits[3];
                    4'd13: S_pf_on = S_pf_row_bits[2];
                    4'd14: S_pf_on = S_pf_row_bits[1];
                    4'd15: S_pf_on = S_pf_row_bits[0];
                    default: S_pf_on = 1'b0;
                endcase
                if(S_pf_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_COORD;
                end
            end

            if((!S_osd_hit) && I_green_valid &&
               (S_x_2d >= I_green_x0) && (S_x_2d < I_green_x0 + 12'd144) &&
               (S_y_2d >= I_green_y0 + 12'd20) && (S_y_2d < I_green_y0 + 12'd36)) begin
                S_mode_x = S_x_2d - I_green_x0;
                S_mode_y = S_y_2d - (I_green_y0 + 12'd20);
                case(S_mode_x[7:4])
                    4'd0: S_pf_char = ID_GREEN;
                    4'd1: S_pf_char = CHAR_COLON;
                    4'd2: S_pf_char = CHAR_0 + {3'b000, green_x_d2};
                    4'd3: S_pf_char = CHAR_0 + {3'b000, green_x_d1};
                    4'd4: S_pf_char = CHAR_0 + {3'b000, green_x_d0};
                    4'd5: S_pf_char = CHAR_COLON;
                    4'd6: S_pf_char = CHAR_0 + {3'b000, green_y_d2};
                    4'd7: S_pf_char = CHAR_0 + {3'b000, green_y_d1};
                    4'd8: S_pf_char = CHAR_0 + {3'b000, green_y_d0};
                    default: S_pf_char = 8'h00;
                endcase
                S_pf_col = S_mode_x[3:0];
                S_pf_row = S_mode_y[3:0];
                case(S_pf_col)
                    4'd0:  S_pf_on = S_pf_row_bits[15];
                    4'd1:  S_pf_on = S_pf_row_bits[14];
                    4'd2:  S_pf_on = S_pf_row_bits[13];
                    4'd3:  S_pf_on = S_pf_row_bits[12];
                    4'd4:  S_pf_on = S_pf_row_bits[11];
                    4'd5:  S_pf_on = S_pf_row_bits[10];
                    4'd6:  S_pf_on = S_pf_row_bits[9];
                    4'd7:  S_pf_on = S_pf_row_bits[8];
                    4'd8:  S_pf_on = S_pf_row_bits[7];
                    4'd9:  S_pf_on = S_pf_row_bits[6];
                    4'd10: S_pf_on = S_pf_row_bits[5];
                    4'd11: S_pf_on = S_pf_row_bits[4];
                    4'd12: S_pf_on = S_pf_row_bits[3];
                    4'd13: S_pf_on = S_pf_row_bits[2];
                    4'd14: S_pf_on = S_pf_row_bits[1];
                    4'd15: S_pf_on = S_pf_row_bits[0];
                    default: S_pf_on = 1'b0;
                endcase
                if(S_pf_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_COORD;
                end
            end

            // Frame latency text: "延迟 [tens][ones] 帧".
            if((!S_osd_hit) &&
               (S_x_2d >= LAT_OSD_X) && (S_x_2d < (LAT_OSD_X + 12'd240)) &&
               (S_y_2d >= LAT_OSD_Y) && (S_y_2d < (LAT_OSD_Y + 12'd16))) begin
                S_mode_x = S_x_2d - LAT_OSD_X;
                S_mode_y = S_y_2d - LAT_OSD_Y;

                if((S_mode_x < 12'd32) || ((S_mode_x >= 12'd80) && (S_mode_x < 12'd96))) begin
                    if(S_mode_x < 12'd16)      S_cn_char = CN_YAN;
                    else if(S_mode_x < 12'd32) S_cn_char = CN_CHI;
                    else                       S_cn_char = CN_ZHEN;
                    S_cn_col = S_mode_x[3:0];
                    S_cn_row = S_mode_y[3:0];
                    case(S_cn_col)
                        4'd0:  S_cn_on = S_cn_row_bits[15];
                        4'd1:  S_cn_on = S_cn_row_bits[14];
                        4'd2:  S_cn_on = S_cn_row_bits[13];
                        4'd3:  S_cn_on = S_cn_row_bits[12];
                        4'd4:  S_cn_on = S_cn_row_bits[11];
                        4'd5:  S_cn_on = S_cn_row_bits[10];
                        4'd6:  S_cn_on = S_cn_row_bits[9];
                        4'd7:  S_cn_on = S_cn_row_bits[8];
                        4'd8:  S_cn_on = S_cn_row_bits[7];
                        4'd9:  S_cn_on = S_cn_row_bits[6];
                        4'd10: S_cn_on = S_cn_row_bits[5];
                        4'd11: S_cn_on = S_cn_row_bits[4];
                        4'd12: S_cn_on = S_cn_row_bits[3];
                        4'd13: S_cn_on = S_cn_row_bits[2];
                        4'd14: S_cn_on = S_cn_row_bits[1];
                        4'd15: S_cn_on = S_cn_row_bits[0];
                        default: S_cn_on = 1'b0;
                    endcase
                    if(S_cn_on) begin
                        S_osd_hit   = 1'b1;
                        S_osd_color = COLOR_LAT;
                    end
                end
                else begin
                    if(S_mode_x < 12'd48)       S_pf_char = CHAR_COLON;
                    else if(S_mode_x < 12'd64)  S_pf_char = CHAR_0 + lat_d0;
                    else if(S_mode_x < 12'd80)  S_pf_char = CHAR_SPACE;
                    else if(S_mode_x < 12'd112) S_pf_char = CHAR_SPACE;
                    else if(S_mode_x < 12'd128) S_pf_char = CHAR_SLASH;
                    else if(S_mode_x < 12'd144) S_pf_char = CHAR_SPACE;
                    else if(S_mode_x < 12'd160) S_pf_char = CHAR_0 + lat_ms_tens;
                    else if(S_mode_x < 12'd176) S_pf_char = CHAR_0 + lat_ms_ones;
                    else if(S_mode_x < 12'd192) S_pf_char = CHAR_PERIOD;
                    else if(S_mode_x < 12'd208) S_pf_char = CHAR_0 + lat_ms_frac;
                    else if(S_mode_x < 12'd224) S_pf_char = CHAR_m;
                    else                        S_pf_char = CHAR_s;
                    S_pf_col = S_mode_x[3:0];
                    S_pf_row = S_mode_y[3:0];
                    case(S_pf_col)
                        4'd0:  S_pf_on = S_pf_row_bits[15];
                        4'd1:  S_pf_on = S_pf_row_bits[14];
                        4'd2:  S_pf_on = S_pf_row_bits[13];
                        4'd3:  S_pf_on = S_pf_row_bits[12];
                        4'd4:  S_pf_on = S_pf_row_bits[11];
                        4'd5:  S_pf_on = S_pf_row_bits[10];
                        4'd6:  S_pf_on = S_pf_row_bits[9];
                        4'd7:  S_pf_on = S_pf_row_bits[8];
                        4'd8:  S_pf_on = S_pf_row_bits[7];
                        4'd9:  S_pf_on = S_pf_row_bits[6];
                        4'd10: S_pf_on = S_pf_row_bits[5];
                        4'd11: S_pf_on = S_pf_row_bits[4];
                        4'd12: S_pf_on = S_pf_row_bits[3];
                        4'd13: S_pf_on = S_pf_row_bits[2];
                        4'd14: S_pf_on = S_pf_row_bits[1];
                        4'd15: S_pf_on = S_pf_row_bits[0];
                        default: S_pf_on = 1'b0;
                    endcase
                    if(S_pf_on) begin
                        S_osd_hit   = 1'b1;
                        S_osd_color = COLOR_LAT;
                    end
                end
            end

            // 4G module link status: "4G已连接" (green) or "4G未连接" (red).
            if((!S_osd_hit) &&
               (S_x_2d >= LTE_OSD_X) && (S_x_2d < (LTE_OSD_X + LTE_OSD_W)) &&
               (S_y_2d >= LTE_OSD_Y) && (S_y_2d < (LTE_OSD_Y + LTE_OSD_H))) begin
                S_mode_x = S_x_2d - LTE_OSD_X;
                S_mode_y = S_y_2d - LTE_OSD_Y;

                // "4" and "G" are ASCII, the rest are Chinese glyphs.
                if(S_mode_x < 12'd32) begin
                    if(S_mode_x < 12'd16)
                        S_pf_char = CHAR_4;
                    else
                        S_pf_char = CHAR_G;
                    S_pf_col = S_mode_x[3:0];
                    S_pf_row = S_mode_y[3:0];
                    case(S_pf_col)
                        4'd0:  S_pf_on = S_pf_row_bits[15];
                        4'd1:  S_pf_on = S_pf_row_bits[14];
                        4'd2:  S_pf_on = S_pf_row_bits[13];
                        4'd3:  S_pf_on = S_pf_row_bits[12];
                        4'd4:  S_pf_on = S_pf_row_bits[11];
                        4'd5:  S_pf_on = S_pf_row_bits[10];
                        4'd6:  S_pf_on = S_pf_row_bits[9];
                        4'd7:  S_pf_on = S_pf_row_bits[8];
                        4'd8:  S_pf_on = S_pf_row_bits[7];
                        4'd9:  S_pf_on = S_pf_row_bits[6];
                        4'd10: S_pf_on = S_pf_row_bits[5];
                        4'd11: S_pf_on = S_pf_row_bits[4];
                        4'd12: S_pf_on = S_pf_row_bits[3];
                        4'd13: S_pf_on = S_pf_row_bits[2];
                        4'd14: S_pf_on = S_pf_row_bits[1];
                        4'd15: S_pf_on = S_pf_row_bits[0];
                        default: S_pf_on = 1'b0;
                    endcase
                    if(S_pf_on) begin
                        S_osd_hit   = 1'b1;
                        S_osd_color = I_lte_ok ? COLOR_LTE_OK : COLOR_LTE_BAD;
                    end
                end
                else begin
                    if(S_mode_x < 12'd48)      S_cn_char = I_lte_ok ? CN_YIJ : CN_WEI;
                    else if(S_mode_x < 12'd64) S_cn_char = CN_LIAN;
                    else                       S_cn_char = CN_JIE;
                    S_cn_col = S_mode_x[3:0];
                    S_cn_row = S_mode_y[3:0];
                    case(S_cn_col)
                        4'd0:  S_cn_on = S_cn_row_bits[15];
                        4'd1:  S_cn_on = S_cn_row_bits[14];
                        4'd2:  S_cn_on = S_cn_row_bits[13];
                        4'd3:  S_cn_on = S_cn_row_bits[12];
                        4'd4:  S_cn_on = S_cn_row_bits[11];
                        4'd5:  S_cn_on = S_cn_row_bits[10];
                        4'd6:  S_cn_on = S_cn_row_bits[9];
                        4'd7:  S_cn_on = S_cn_row_bits[8];
                        4'd8:  S_cn_on = S_cn_row_bits[7];
                        4'd9:  S_cn_on = S_cn_row_bits[6];
                        4'd10: S_cn_on = S_cn_row_bits[5];
                        4'd11: S_cn_on = S_cn_row_bits[4];
                        4'd12: S_cn_on = S_cn_row_bits[3];
                        4'd13: S_cn_on = S_cn_row_bits[2];
                        4'd14: S_cn_on = S_cn_row_bits[1];
                        4'd15: S_cn_on = S_cn_row_bits[0];
                        default: S_cn_on = 1'b0;
                    endcase
                    if(S_cn_on) begin
                        S_osd_hit   = 1'b1;
                        S_osd_color = I_lte_ok ? COLOR_LTE_OK : COLOR_LTE_BAD;
                    end
                end
            end

            if((!S_osd_hit) &&
               (S_x_2d >= WB_OSD_X) && (S_x_2d < (WB_OSD_X + 12'd64)) &&
               (S_y_2d >= WB_OSD_Y) && (S_y_2d < (WB_OSD_Y + 12'd16))) begin
                S_mode_x = S_x_2d - WB_OSD_X;
                S_mode_y = S_y_2d - WB_OSD_Y;
                if(S_mode_x < 12'd16)      S_cn_char = CN_BAI;
                else if(S_mode_x < 12'd32) S_cn_char = CN_PING;
                else if(S_mode_x < 12'd48) S_cn_char = CN_HENG;
                else                       S_cn_char = CN_KAI;
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_AE_TEXT;
                end
            end

            if((!S_osd_hit) &&
               (S_x_2d >= AE_OSD_X) && (S_x_2d < (AE_OSD_X + 12'd80)) &&
               (S_y_2d >= AE_OSD_Y) && (S_y_2d < (AE_OSD_Y + 12'd16))) begin
                S_mode_x = S_x_2d - AE_OSD_X;
                S_mode_y = S_y_2d - AE_OSD_Y;
                if(S_mode_x < 12'd16)      S_cn_char = CN_ZI;
                else if(S_mode_x < 12'd32) S_cn_char = CN_DONG;
                else if(S_mode_x < 12'd48) S_cn_char = CN_PU;
                else if(S_mode_x < 12'd64) S_cn_char = CN_GUANG;
                else                       S_cn_char = I_auto_ae_on ? CN_KAI : CN_GUAN;
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = I_auto_ae_on ? COLOR_AE_TEXT : COLOR_RED_TEXT;
                end
            end

            if((!S_osd_hit) &&
               (S_x_2d >= MOTION_OSD_X) && (S_x_2d < (MOTION_OSD_X + 12'd80)) &&
               (S_y_2d >= MOTION_OSD_Y) && (S_y_2d < (MOTION_OSD_Y + 12'd16))) begin
                S_mode_x = S_x_2d - MOTION_OSD_X;
                S_mode_y = S_y_2d - MOTION_OSD_Y;
                if(S_mode_x < 12'd16)      S_cn_char = CN_YUN;
                else if(S_mode_x < 12'd32) S_cn_char = CN_DONG;
                else if(S_mode_x < 12'd48) S_cn_char = CN_GEN;
                else if(S_mode_x < 12'd64) S_cn_char = CN_ZONG;
                else                       S_cn_char = I_motion_track_on ? CN_KAI : CN_GUAN;
                S_cn_col = S_mode_x[3:0];
                S_cn_row = S_mode_y[3:0];
                case(S_cn_col)
                    4'd0:  S_cn_on = S_cn_row_bits[15];
                    4'd1:  S_cn_on = S_cn_row_bits[14];
                    4'd2:  S_cn_on = S_cn_row_bits[13];
                    4'd3:  S_cn_on = S_cn_row_bits[12];
                    4'd4:  S_cn_on = S_cn_row_bits[11];
                    4'd5:  S_cn_on = S_cn_row_bits[10];
                    4'd6:  S_cn_on = S_cn_row_bits[9];
                    4'd7:  S_cn_on = S_cn_row_bits[8];
                    4'd8:  S_cn_on = S_cn_row_bits[7];
                    4'd9:  S_cn_on = S_cn_row_bits[6];
                    4'd10: S_cn_on = S_cn_row_bits[5];
                    4'd11: S_cn_on = S_cn_row_bits[4];
                    4'd12: S_cn_on = S_cn_row_bits[3];
                    4'd13: S_cn_on = S_cn_row_bits[2];
                    4'd14: S_cn_on = S_cn_row_bits[1];
                    4'd15: S_cn_on = S_cn_row_bits[0];
                    default: S_cn_on = 1'b0;
                endcase
                if(S_cn_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = I_motion_track_on ? COLOR_AE_TEXT : COLOR_RED_TEXT;
                end
            end

            if((!S_osd_hit) &&
               (S_x_2d >= SIGN_OSD_X) && (S_x_2d < (SIGN_OSD_X + SIGN_OSD_W)) &&
               (S_y_2d >= SIGN_OSD_Y) && (S_y_2d < (SIGN_OSD_Y + SIGN_OSD_H))) begin
                S_mode_x = S_x_2d - SIGN_OSD_X;
                S_mode_y = S_y_2d - SIGN_OSD_Y;
                case(S_mode_x[7:4])
                    4'd0:  S_pf_char = CHAR_M;
                    4'd1:  S_pf_char = CHAR_i;
                    4'd2:  S_pf_char = CHAR_c;
                    4'd3:  S_pf_char = CHAR_r;
                    4'd4:  S_pf_char = CHAR_o;
                    4'd5:  S_pf_char = CHAR_k;
                    4'd6:  S_pf_char = CHAR_o;
                    4'd7:  S_pf_char = CHAR_s;
                    4'd8:  S_pf_char = CHAR_m;
                    4'd9:  S_pf_char = CHAR_o;
                    4'd10: S_pf_char = CHAR_s;
                    default: S_pf_char = CHAR_SPACE;
                endcase
                S_pf_col = S_mode_x[3:0];
                S_pf_row = S_mode_y[3:0];
                case(S_pf_col)
                    4'd0:  S_pf_on = S_pf_row_bits[15];
                    4'd1:  S_pf_on = S_pf_row_bits[14];
                    4'd2:  S_pf_on = S_pf_row_bits[13];
                    4'd3:  S_pf_on = S_pf_row_bits[12];
                    4'd4:  S_pf_on = S_pf_row_bits[11];
                    4'd5:  S_pf_on = S_pf_row_bits[10];
                    4'd6:  S_pf_on = S_pf_row_bits[9];
                    4'd7:  S_pf_on = S_pf_row_bits[8];
                    4'd8:  S_pf_on = S_pf_row_bits[7];
                    4'd9:  S_pf_on = S_pf_row_bits[6];
                    4'd10: S_pf_on = S_pf_row_bits[5];
                    4'd11: S_pf_on = S_pf_row_bits[4];
                    4'd12: S_pf_on = S_pf_row_bits[3];
                    4'd13: S_pf_on = S_pf_row_bits[2];
                    4'd14: S_pf_on = S_pf_row_bits[1];
                    4'd15: S_pf_on = S_pf_row_bits[0];
                    default: S_pf_on = 1'b0;
                endcase
                if(S_pf_on) begin
                    S_osd_hit   = 1'b1;
                    S_osd_color = COLOR_SIGN;
                end
            end

        end
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            S_video_vsync_1d <= 1'b0;
            S_video_vsync_2d <= 1'b0;
            S_video_hsync_1d <= 1'b0;
            S_video_hsync_2d <= 1'b0;
            S_video_de_1d    <= 1'b0;
            S_video_de_2d    <= 1'b0;
            O_hdmi_vsync     <= 1'b0;
            O_hdmi_hsync     <= 1'b0;
            O_hdmi_de        <= 1'b0;
            O_hdmi_data      <= 24'd0;
        end
        else begin
            S_video_vsync_1d <= I_video_vsync;
            S_video_vsync_2d <= S_video_vsync_1d;
            O_hdmi_vsync     <= S_video_vsync_2d;

            S_video_hsync_1d <= I_video_hsync;
            S_video_hsync_2d <= S_video_hsync_1d;
            O_hdmi_hsync     <= S_video_hsync_2d;

            S_video_de_1d    <= I_video_de;
            S_video_de_2d    <= S_video_de_1d;
            O_hdmi_de        <= S_video_de_2d;
            S_video_data_1d  <= I_video_rd_data;
            S_video_data_2d  <= S_video_data_1d;

            if(DEBUG_MODE == 1) begin
                if(S_video_de_2d) begin
                    if(S_x < 12'd128)
                        O_hdmi_data <= 24'hff0000;
                    else if(S_x < 12'd256)
                        O_hdmi_data <= 24'h00ff00;
                    else if(S_x < 12'd384)
                        O_hdmi_data <= 24'h0000ff;
                    else if(S_x < 12'd512)
                        O_hdmi_data <= 24'hffff00;
                    else if(S_x < 12'd640)
                        O_hdmi_data <= 24'h00ffff;
                    else if(S_x < 12'd768)
                        O_hdmi_data <= 24'hff00ff;
                    else if(S_x < 12'd896)
                        O_hdmi_data <= 24'hffffff;
                    else
                        O_hdmi_data <= 24'h202020;
                end
                else begin
                    O_hdmi_data <= 24'd0;
                end
            end
            else if(DEBUG_MODE == 2) begin
                if(S_video_de_2d) begin
                    case (I_debug_status)
                        4'b0000: O_hdmi_data <= 24'h000000;
                        4'b0001: O_hdmi_data <= 24'hff0000;
                        4'b0011: O_hdmi_data <= 24'hffff00;
                        4'b0111: O_hdmi_data <= 24'h00ff00;
                        4'b1111: O_hdmi_data <= I_video_rd_data;
                        default: O_hdmi_data <= 24'h0000ff;
                    endcase
                end
                else begin
                    O_hdmi_data <= 24'd0;
                end
            end
            else if(DEBUG_MODE == 3) begin
                if(S_video_de_2d) begin
                    if(S_x < 12'd256)
                        O_hdmi_data <= I_debug_status[0] ? 24'hff8000 : 24'h201000;
                    else if(S_x < 12'd512)
                        O_hdmi_data <= I_debug_status[1] ? 24'hffff00 : 24'h202000;
                    else if(S_x < 12'd768)
                        O_hdmi_data <= I_debug_status[2] ? 24'hff0000 : 24'h200000;
                    else
                        O_hdmi_data <= I_debug_status[3] ? 24'h00ffff : 24'h002020;
                end
                else begin
                    O_hdmi_data <= 24'd0;
                end
            end
            else begin
                if(S_osd_hit)
                    O_hdmi_data <= S_osd_color;
                else
                    O_hdmi_data <= S_video_data_2d;
            end
        end
    end

endmodule
