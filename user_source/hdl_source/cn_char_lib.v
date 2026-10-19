// 16x16 Chinese bitmap font for the trash-can labels.
// Codes: A0=可 A1=回 A2=收 A3=垃 A4=圾 A5=桶 A6=有 A7=害 A8=厨 A9=余
module cn_char_lib (
    input  wire [7:0] I_char,
    input  wire [3:0] I_row,
    output reg  [15:0] O_row_bits
);

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
    localparam CN_QI2   = 8'hB2;   // 其
    localparam CN_TA    = 8'hB3;   // 他
    localparam CN_WU    = 8'hB4;   // 物
    localparam CN_YUN   = 8'hB5;   // 运
    localparam CN_GEN   = 8'hB6;   // 跟
    localparam CN_ZONG  = 8'hB7;   // 踪
    localparam CN_MU    = 8'hB8;   // 目
    localparam CN_BIAO  = 8'hB9;   // 标
    localparam CN_JIAN  = 8'hBA;   // 检
    localparam CN_CE    = 8'hBB;   // 测
    localparam CN_ZHONG = 8'hBC;   // 中
    localparam CN_DOT   = 8'hBD;   // ...
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

    always @(*) begin
        case(I_char)
            CN_KE: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h7FFE;
                4'd2:  O_row_bits = 16'h0018;
                4'd3:  O_row_bits = 16'h0018;
                4'd4:  O_row_bits = 16'h1F98;
                4'd5:  O_row_bits = 16'h1198;
                4'd6:  O_row_bits = 16'h1098;
                4'd7:  O_row_bits = 16'h1098;
                4'd8:  O_row_bits = 16'h1098;
                4'd9:  O_row_bits = 16'h1F98;
                4'd10: O_row_bits = 16'h1098;
                4'd11: O_row_bits = 16'h1018;
                4'd12: O_row_bits = 16'h0018;
                4'd13: O_row_bits = 16'h0070;
                4'd14: O_row_bits = 16'h0020;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_HUI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0000;
                4'd2:  O_row_bits = 16'h3FFC;
                4'd3:  O_row_bits = 16'h2004;
                4'd4:  O_row_bits = 16'h2004;
                4'd5:  O_row_bits = 16'h27E4;
                4'd6:  O_row_bits = 16'h2464;
                4'd7:  O_row_bits = 16'h2424;
                4'd8:  O_row_bits = 16'h2424;
                4'd9:  O_row_bits = 16'h27E4;
                4'd10: O_row_bits = 16'h23C4;
                4'd11: O_row_bits = 16'h2004;
                4'd12: O_row_bits = 16'h2004;
                4'd13: O_row_bits = 16'h3FFC;
                4'd14: O_row_bits = 16'h2004;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_SHOU: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0C40;
                4'd2:  O_row_bits = 16'h0C40;
                4'd3:  O_row_bits = 16'h4CC0;
                4'd4:  O_row_bits = 16'h4CFE;
                4'd5:  O_row_bits = 16'h4D88;
                4'd6:  O_row_bits = 16'h4D88;
                4'd7:  O_row_bits = 16'h4FC8;
                4'd8:  O_row_bits = 16'h4C48;
                4'd9:  O_row_bits = 16'h4C50;
                4'd10: O_row_bits = 16'h7C70;
                4'd11: O_row_bits = 16'h0C30;
                4'd12: O_row_bits = 16'h0C70;
                4'd13: O_row_bits = 16'h0CDC;
                4'd14: O_row_bits = 16'h0F86;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_LA: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0040;
                4'd2:  O_row_bits = 16'h1060;
                4'd3:  O_row_bits = 16'h1020;
                4'd4:  O_row_bits = 16'h13FE;
                4'd5:  O_row_bits = 16'h1000;
                4'd6:  O_row_bits = 16'h7C04;
                4'd7:  O_row_bits = 16'h110C;
                4'd8:  O_row_bits = 16'h1088;
                4'd9:  O_row_bits = 16'h1088;
                4'd10: O_row_bits = 16'h10C8;
                4'd11: O_row_bits = 16'h1C50;
                4'd12: O_row_bits = 16'h7050;
                4'd13: O_row_bits = 16'h4030;
                4'd14: O_row_bits = 16'h03FE;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_JI: case(I_row)
                4'd0:  O_row_bits = 16'h13F8;
                4'd1:  O_row_bits = 16'h13F8;
                4'd2:  O_row_bits = 16'h1188;
                4'd3:  O_row_bits = 16'h1198;
                4'd4:  O_row_bits = 16'h7D9C;
                4'd5:  O_row_bits = 16'h1184;
                4'd6:  O_row_bits = 16'h1184;
                4'd7:  O_row_bits = 16'h11CC;
                4'd8:  O_row_bits = 16'h1148;
                4'd9:  O_row_bits = 16'h1F38;
                4'd10: O_row_bits = 16'h7230;
                4'd11: O_row_bits = 16'h4638;
                4'd12: O_row_bits = 16'h0C6C;
                4'd13: O_row_bits = 16'h0986;
                4'd14: O_row_bits = 16'h0100;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_TONG: case(I_row)
                4'd0:  O_row_bits = 16'h1000;
                4'd1:  O_row_bits = 16'h13FC;
                4'd2:  O_row_bits = 16'h1008;
                4'd3:  O_row_bits = 16'h7C70;
                4'd4:  O_row_bits = 16'h31FE;
                4'd5:  O_row_bits = 16'h3326;
                4'd6:  O_row_bits = 16'h3B22;
                4'd7:  O_row_bits = 16'h3FFE;
                4'd8:  O_row_bits = 16'h7322;
                4'd9:  O_row_bits = 16'h5326;
                4'd10: O_row_bits = 16'h13FE;
                4'd11: O_row_bits = 16'h1322;
                4'd12: O_row_bits = 16'h1326;
                4'd13: O_row_bits = 16'h132C;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_YOU: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0100;
                4'd2:  O_row_bits = 16'h0100;
                4'd3:  O_row_bits = 16'h3FFE;
                4'd4:  O_row_bits = 16'h0200;
                4'd5:  O_row_bits = 16'h0600;
                4'd6:  O_row_bits = 16'h0FFC;
                4'd7:  O_row_bits = 16'h0C0C;
                4'd8:  O_row_bits = 16'h1C0C;
                4'd9:  O_row_bits = 16'h67FC;
                4'd10: O_row_bits = 16'h440C;
                4'd11: O_row_bits = 16'h07FC;
                4'd12: O_row_bits = 16'h040C;
                4'd13: O_row_bits = 16'h040C;
                4'd14: O_row_bits = 16'h0418;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_HAI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0180;
                4'd2:  O_row_bits = 16'h3FFC;
                4'd3:  O_row_bits = 16'h6186;
                4'd4:  O_row_bits = 16'h2186;
                4'd5:  O_row_bits = 16'h1FF8;
                4'd6:  O_row_bits = 16'h0180;
                4'd7:  O_row_bits = 16'h1FF8;
                4'd8:  O_row_bits = 16'h0180;
                4'd9:  O_row_bits = 16'h7FFC;
                4'd10: O_row_bits = 16'h0180;
                4'd11: O_row_bits = 16'h1FF8;
                4'd12: O_row_bits = 16'h1818;
                4'd13: O_row_bits = 16'h1818;
                4'd14: O_row_bits = 16'h1FF8;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_CHU: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h3FFE;
                4'd2:  O_row_bits = 16'h2000;
                4'd3:  O_row_bits = 16'h2F8C;
                4'd4:  O_row_bits = 16'h200C;
                4'd5:  O_row_bits = 16'h27BE;
                4'd6:  O_row_bits = 16'h2D8C;
                4'd7:  O_row_bits = 16'h288C;
                4'd8:  O_row_bits = 16'h2FAC;
                4'd9:  O_row_bits = 16'h203C;
                4'd10: O_row_bits = 16'h2D8C;
                4'd11: O_row_bits = 16'h650C;
                4'd12: O_row_bits = 16'h45CC;
                4'd13: O_row_bits = 16'h5E18;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_YU: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0180;
                4'd2:  O_row_bits = 16'h0380;
                4'd3:  O_row_bits = 16'h0640;
                4'd4:  O_row_bits = 16'h0430;
                4'd5:  O_row_bits = 16'h181C;
                4'd6:  O_row_bits = 16'h3FE6;
                4'd7:  O_row_bits = 16'h6180;
                4'd8:  O_row_bits = 16'h0180;
                4'd9:  O_row_bits = 16'h1FF8;
                4'd10: O_row_bits = 16'h1FF8;
                4'd11: O_row_bits = 16'h0180;
                4'd12: O_row_bits = 16'h0990;
                4'd13: O_row_bits = 16'h3188;
                4'd14: O_row_bits = 16'h2388;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_ZI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0300;
                4'd2:  O_row_bits = 16'h0300;
                4'd3:  O_row_bits = 16'h1FF8;
                4'd4:  O_row_bits = 16'h1FF8;
                4'd5:  O_row_bits = 16'h1008;
                4'd6:  O_row_bits = 16'h1008;
                4'd7:  O_row_bits = 16'h1FF8;
                4'd8:  O_row_bits = 16'h1008;
                4'd9:  O_row_bits = 16'h1008;
                4'd10: O_row_bits = 16'h1FF8;
                4'd11: O_row_bits = 16'h1008;
                4'd12: O_row_bits = 16'h1008;
                4'd13: O_row_bits = 16'h1FF8;
                4'd14: O_row_bits = 16'h1008;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_DONG: case(I_row)
                4'd0:  O_row_bits = 16'h0030;
                4'd1:  O_row_bits = 16'h0030;
                4'd2:  O_row_bits = 16'h3E30;
                4'd3:  O_row_bits = 16'h0030;
                4'd4:  O_row_bits = 16'h00FE;
                4'd5:  O_row_bits = 16'h7E32;
                4'd6:  O_row_bits = 16'h7E22;
                4'd7:  O_row_bits = 16'h1022;
                4'd8:  O_row_bits = 16'h1222;
                4'd9:  O_row_bits = 16'h2222;
                4'd10: O_row_bits = 16'h2362;
                4'd11: O_row_bits = 16'h7D46;
                4'd12: O_row_bits = 16'h00C6;
                4'd13: O_row_bits = 16'h019C;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_PU: case(I_row)
                4'd0:  O_row_bits = 16'h01FC;
                4'd1:  O_row_bits = 16'h7904;
                4'd2:  O_row_bits = 16'h49FC;
                4'd3:  O_row_bits = 16'h4904;
                4'd4:  O_row_bits = 16'h49FC;
                4'd5:  O_row_bits = 16'h79FC;
                4'd6:  O_row_bits = 16'h68D8;
                4'd7:  O_row_bits = 16'h4BFE;
                4'd8:  O_row_bits = 16'h48D8;
                4'd9:  O_row_bits = 16'h49AC;
                4'd10: O_row_bits = 16'h7FA6;
                4'd11: O_row_bits = 16'h68F8;
                4'd12: O_row_bits = 16'h49AC;
                4'd13: O_row_bits = 16'h0262;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_GUANG: case(I_row)
                4'd0:  O_row_bits = 16'h0180;
                4'd1:  O_row_bits = 16'h0180;
                4'd2:  O_row_bits = 16'h1188;
                4'd3:  O_row_bits = 16'h1998;
                4'd4:  O_row_bits = 16'h0D90;
                4'd5:  O_row_bits = 16'h0180;
                4'd6:  O_row_bits = 16'h7FFE;
                4'd7:  O_row_bits = 16'h0240;
                4'd8:  O_row_bits = 16'h0240;
                4'd9:  O_row_bits = 16'h0640;
                4'd10: O_row_bits = 16'h0440;
                4'd11: O_row_bits = 16'h0C42;
                4'd12: O_row_bits = 16'h1846;
                4'd13: O_row_bits = 16'h707C;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_KAI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h3FFC;
                4'd2:  O_row_bits = 16'h0620;
                4'd3:  O_row_bits = 16'h0620;
                4'd4:  O_row_bits = 16'h0620;
                4'd5:  O_row_bits = 16'h0620;
                4'd6:  O_row_bits = 16'h7FFE;
                4'd7:  O_row_bits = 16'h7FFE;
                4'd8:  O_row_bits = 16'h0620;
                4'd9:  O_row_bits = 16'h0420;
                4'd10: O_row_bits = 16'h0C20;
                4'd11: O_row_bits = 16'h0C20;
                4'd12: O_row_bits = 16'h1820;
                4'd13: O_row_bits = 16'h3020;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_QI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0180;
                4'd2:  O_row_bits = 16'h0080;
                4'd3:  O_row_bits = 16'h1FFC;
                4'd4:  O_row_bits = 16'h100C;
                4'd5:  O_row_bits = 16'h100C;
                4'd6:  O_row_bits = 16'h1FFC;
                4'd7:  O_row_bits = 16'h1FF8;
                4'd8:  O_row_bits = 16'h1000;
                4'd9:  O_row_bits = 16'h17F8;
                4'd10: O_row_bits = 16'h140C;
                4'd11: O_row_bits = 16'h340C;
                4'd12: O_row_bits = 16'h240C;
                4'd13: O_row_bits = 16'h67FC;
                4'd14: O_row_bits = 16'h440C;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_GUAN: case(I_row)
                4'd0:  O_row_bits = 16'h0020;
                4'd1:  O_row_bits = 16'h0420;
                4'd2:  O_row_bits = 16'h0660;
                4'd3:  O_row_bits = 16'h1FFC;
                4'd4:  O_row_bits = 16'h1FF8;
                4'd5:  O_row_bits = 16'h0180;
                4'd6:  O_row_bits = 16'h0180;
                4'd7:  O_row_bits = 16'h0180;
                4'd8:  O_row_bits = 16'h3FFE;
                4'd9:  O_row_bits = 16'h0180;
                4'd10: O_row_bits = 16'h0340;
                4'd11: O_row_bits = 16'h0670;
                4'd12: O_row_bits = 16'h0C1C;
                4'd13: O_row_bits = 16'h300E;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_BI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h1000;
                4'd2:  O_row_bits = 16'h19FE;
                4'd3:  O_row_bits = 16'h0806;
                4'd4:  O_row_bits = 16'h2046;
                4'd5:  O_row_bits = 16'h6046;
                4'd6:  O_row_bits = 16'h6FF6;
                4'd7:  O_row_bits = 16'h61C6;
                4'd8:  O_row_bits = 16'h61C6;
                4'd9:  O_row_bits = 16'h6346;
                4'd10: O_row_bits = 16'h6646;
                4'd11: O_row_bits = 16'h6C46;
                4'd12: O_row_bits = 16'h78C6;
                4'd13: O_row_bits = 16'h61C6;
                4'd14: O_row_bits = 16'h600C;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_QI2: case(I_row)
                4'd0:  O_row_bits = 16'h0810;
                4'd1:  O_row_bits = 16'h0830;
                4'd2:  O_row_bits = 16'h3FFC;
                4'd3:  O_row_bits = 16'h0C30;
                4'd4:  O_row_bits = 16'h0C30;
                4'd5:  O_row_bits = 16'h0FF0;
                4'd6:  O_row_bits = 16'h0830;
                4'd7:  O_row_bits = 16'h0FF0;
                4'd8:  O_row_bits = 16'h0830;
                4'd9:  O_row_bits = 16'h0C30;
                4'd10: O_row_bits = 16'h0000;
                4'd11: O_row_bits = 16'h0C20;
                4'd12: O_row_bits = 16'h1818;
                4'd13: O_row_bits = 16'h300C;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_TA: case(I_row)
                4'd0:  O_row_bits = 16'h0860;
                4'd1:  O_row_bits = 16'h0860;
                4'd2:  O_row_bits = 16'h1860;
                4'd3:  O_row_bits = 16'h1264;
                4'd4:  O_row_bits = 16'h327C;
                4'd5:  O_row_bits = 16'h33E4;
                4'd6:  O_row_bits = 16'h7F64;
                4'd7:  O_row_bits = 16'h5264;
                4'd8:  O_row_bits = 16'h126C;
                4'd9:  O_row_bits = 16'h1278;
                4'd10: O_row_bits = 16'h1260;
                4'd11: O_row_bits = 16'h1202;
                4'd12: O_row_bits = 16'h1306;
                4'd13: O_row_bits = 16'h11FC;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_WU: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0840;
                4'd2:  O_row_bits = 16'h08C0;
                4'd3:  O_row_bits = 16'h28FE;
                4'd4:  O_row_bits = 16'h69FE;
                4'd5:  O_row_bits = 16'h7F6A;
                4'd6:  O_row_bits = 16'h494A;
                4'd7:  O_row_bits = 16'h484A;
                4'd8:  O_row_bits = 16'h08DA;
                4'd9:  O_row_bits = 16'h1E92;
                4'd10: O_row_bits = 16'h7912;
                4'd11: O_row_bits = 16'h0826;
                4'd12: O_row_bits = 16'h0866;
                4'd13: O_row_bits = 16'h08C6;
                4'd14: O_row_bits = 16'h099C;
                4'd15: O_row_bits = 16'h0800;
                default: O_row_bits = 16'h0000;
            endcase
            CN_YUN: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h33F8;
                4'd2:  O_row_bits = 16'h1000;
                4'd3:  O_row_bits = 16'h0000;
                4'd4:  O_row_bits = 16'h0000;
                4'd5:  O_row_bits = 16'h37FC;
                4'd6:  O_row_bits = 16'h3880;
                4'd7:  O_row_bits = 16'h1890;
                4'd8:  O_row_bits = 16'h1908;
                4'd9:  O_row_bits = 16'h1B1C;
                4'd10: O_row_bits = 16'h1BE4;
                4'd11: O_row_bits = 16'h1800;
                4'd12: O_row_bits = 16'h3E00;
                4'd13: O_row_bits = 16'h43FE;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_GEN: case(I_row)
                4'd0:  O_row_bits = 16'h00FC;
                4'd1:  O_row_bits = 16'h3D8C;
                4'd2:  O_row_bits = 16'h2584;
                4'd3:  O_row_bits = 16'h25FC;
                4'd4:  O_row_bits = 16'h3D84;
                4'd5:  O_row_bits = 16'h0984;
                4'd6:  O_row_bits = 16'h09FC;
                4'd7:  O_row_bits = 16'h29A0;
                4'd8:  O_row_bits = 16'h2DA4;
                4'd9:  O_row_bits = 16'h2998;
                4'd10: O_row_bits = 16'h2990;
                4'd11: O_row_bits = 16'h2F98;
                4'd12: O_row_bits = 16'h79CC;
                4'd13: O_row_bits = 16'h4186;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_ZONG: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0020;
                4'd2:  O_row_bits = 16'h7C30;
                4'd3:  O_row_bits = 16'h65FE;
                4'd4:  O_row_bits = 16'h6502;
                4'd5:  O_row_bits = 16'h7C00;
                4'd6:  O_row_bits = 16'h18F8;
                4'd7:  O_row_bits = 16'h0800;
                4'd8:  O_row_bits = 16'h49FE;
                4'd9:  O_row_bits = 16'h4DFE;
                4'd10: O_row_bits = 16'h4820;
                4'd11: O_row_bits = 16'h48A0;
                4'd12: O_row_bits = 16'h5DA4;
                4'd13: O_row_bits = 16'h7B22;
                4'd14: O_row_bits = 16'h4260;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_MU: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0000;
                4'd2:  O_row_bits = 16'h1FF8;
                4'd3:  O_row_bits = 16'h1008;
                4'd4:  O_row_bits = 16'h1008;
                4'd5:  O_row_bits = 16'h1FF8;
                4'd6:  O_row_bits = 16'h1FF8;
                4'd7:  O_row_bits = 16'h1008;
                4'd8:  O_row_bits = 16'h1008;
                4'd9:  O_row_bits = 16'h1FF8;
                4'd10: O_row_bits = 16'h1008;
                4'd11: O_row_bits = 16'h1008;
                4'd12: O_row_bits = 16'h1008;
                4'd13: O_row_bits = 16'h1FF8;
                4'd14: O_row_bits = 16'h1008;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_BIAO: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h1000;
                4'd2:  O_row_bits = 16'h11FC;
                4'd3:  O_row_bits = 16'h1000;
                4'd4:  O_row_bits = 16'h7C00;
                4'd5:  O_row_bits = 16'h7C00;
                4'd6:  O_row_bits = 16'h13FE;
                4'd7:  O_row_bits = 16'h3820;
                4'd8:  O_row_bits = 16'h3C20;
                4'd9:  O_row_bits = 16'h35AC;
                4'd10: O_row_bits = 16'h51A4;
                4'd11: O_row_bits = 16'h5126;
                4'd12: O_row_bits = 16'h1322;
                4'd13: O_row_bits = 16'h1220;
                4'd14: O_row_bits = 16'h10E0;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_JIAN: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h1040;
                4'd2:  O_row_bits = 16'h1060;
                4'd3:  O_row_bits = 16'h10F0;
                4'd4:  O_row_bits = 16'h7C90;
                4'd5:  O_row_bits = 16'h110C;
                4'd6:  O_row_bits = 16'h13F6;
                4'd7:  O_row_bits = 16'h3200;
                4'd8:  O_row_bits = 16'h3C44;
                4'd9:  O_row_bits = 16'h776C;
                4'd10: O_row_bits = 16'h5128;
                4'd11: O_row_bits = 16'h11A8;
                4'd12: O_row_bits = 16'h1010;
                4'd13: O_row_bits = 16'h1018;
                4'd14: O_row_bits = 16'h13FE;
                4'd15: O_row_bits = 16'h1000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_CE: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0002;
                4'd2:  O_row_bits = 16'h27C6;
                4'd3:  O_row_bits = 16'h1456;
                4'd4:  O_row_bits = 16'h0456;
                4'd5:  O_row_bits = 16'h4556;
                4'd6:  O_row_bits = 16'h6556;
                4'd7:  O_row_bits = 16'h2556;
                4'd8:  O_row_bits = 16'h0556;
                4'd9:  O_row_bits = 16'h1556;
                4'd10: O_row_bits = 16'h3756;
                4'd11: O_row_bits = 16'h2216;
                4'd12: O_row_bits = 16'h2286;
                4'd13: O_row_bits = 16'h4646;
                4'd14: O_row_bits = 16'h4C4E;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_ZHONG: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0180;
                4'd2:  O_row_bits = 16'h0180;
                4'd3:  O_row_bits = 16'h0180;
                4'd4:  O_row_bits = 16'h3FFC;
                4'd5:  O_row_bits = 16'h218C;
                4'd6:  O_row_bits = 16'h2184;
                4'd7:  O_row_bits = 16'h2184;
                4'd8:  O_row_bits = 16'h2184;
                4'd9:  O_row_bits = 16'h3FFC;
                4'd10: O_row_bits = 16'h2184;
                4'd11: O_row_bits = 16'h0180;
                4'd12: O_row_bits = 16'h0180;
                4'd13: O_row_bits = 16'h0180;
                4'd14: O_row_bits = 16'h0180;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_DOT: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0000;
                4'd2:  O_row_bits = 16'h0000;
                4'd3:  O_row_bits = 16'h0000;
                4'd4:  O_row_bits = 16'h0000;
                4'd5:  O_row_bits = 16'h0000;
                4'd6:  O_row_bits = 16'h0000;
                4'd7:  O_row_bits = 16'h1998;
                4'd8:  O_row_bits = 16'h1998;
                4'd9:  O_row_bits = 16'h0000;
                4'd10: O_row_bits = 16'h0000;
                4'd11: O_row_bits = 16'h0000;
                4'd12: O_row_bits = 16'h0000;
                4'd13: O_row_bits = 16'h0000;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_BAI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0300;
                4'd2:  O_row_bits = 16'h0200;
                4'd3:  O_row_bits = 16'h0600;
                4'd4:  O_row_bits = 16'h3FFC;
                4'd5:  O_row_bits = 16'h3004;
                4'd6:  O_row_bits = 16'h3004;
                4'd7:  O_row_bits = 16'h3004;
                4'd8:  O_row_bits = 16'h3FFC;
                4'd9:  O_row_bits = 16'h3004;
                4'd10: O_row_bits = 16'h3004;
                4'd11: O_row_bits = 16'h3004;
                4'd12: O_row_bits = 16'h300C;
                4'd13: O_row_bits = 16'h3FFC;
                4'd14: O_row_bits = 16'h3004;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_PING: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0000;
                4'd2:  O_row_bits = 16'h3FFC;
                4'd3:  O_row_bits = 16'h0180;
                4'd4:  O_row_bits = 16'h1188;
                4'd5:  O_row_bits = 16'h1998;
                4'd6:  O_row_bits = 16'h0D90;
                4'd7:  O_row_bits = 16'h05A0;
                4'd8:  O_row_bits = 16'h0180;
                4'd9:  O_row_bits = 16'h7FFE;
                4'd10: O_row_bits = 16'h0180;
                4'd11: O_row_bits = 16'h0180;
                4'd12: O_row_bits = 16'h0180;
                4'd13: O_row_bits = 16'h0180;
                4'd14: O_row_bits = 16'h0180;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_HENG: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0100;
                4'd2:  O_row_bits = 16'h1300;
                4'd3:  O_row_bits = 16'h36CE;
                4'd4:  O_row_bits = 16'h6480;
                4'd5:  O_row_bits = 16'h17E0;
                4'd6:  O_row_bits = 16'h15BE;
                4'd7:  O_row_bits = 16'h37E4;
                4'd8:  O_row_bits = 16'h77A4;
                4'd9:  O_row_bits = 16'h33E4;
                4'd10: O_row_bits = 16'h3184;
                4'd11: O_row_bits = 16'h37E4;
                4'd12: O_row_bits = 16'h3184;
                4'd13: O_row_bits = 16'h3664;
                4'd14: O_row_bits = 16'h3C2C;
                4'd15: O_row_bits = 16'h0008;
                default: O_row_bits = 16'h0000;
            endcase
            CN_YAN: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0008;
                4'd2:  O_row_bits = 16'h79F8;
                4'd3:  O_row_bits = 16'h1920;
                4'd4:  O_row_bits = 16'h1020;
                4'd5:  O_row_bits = 16'h3120;
                4'd6:  O_row_bits = 16'h213C;
                4'd7:  O_row_bits = 16'h3920;
                4'd8:  O_row_bits = 16'h0920;
                4'd9:  O_row_bits = 16'h4920;
                4'd10: O_row_bits = 16'h3920;
                4'd11: O_row_bits = 16'h31FC;
                4'd12: O_row_bits = 16'h3800;
                4'd13: O_row_bits = 16'h2E00;
                4'd14: O_row_bits = 16'h43FE;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_CHI: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h0000;
                4'd2:  O_row_bits = 16'h31FC;
                4'd3:  O_row_bits = 16'h1104;
                4'd4:  O_row_bits = 16'h1104;
                4'd5:  O_row_bits = 16'h0104;
                4'd6:  O_row_bits = 16'h01FC;
                4'd7:  O_row_bits = 16'h7104;
                4'd8:  O_row_bits = 16'h1120;
                4'd9:  O_row_bits = 16'h1330;
                4'd10: O_row_bits = 16'h1218;
                4'd11: O_row_bits = 16'h160C;
                4'd12: O_row_bits = 16'h1400;
                4'd13: O_row_bits = 16'h3E00;
                4'd14: O_row_bits = 16'h63FE;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_ZHEN: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h1020;
                4'd2:  O_row_bits = 16'h103E;
                4'd3:  O_row_bits = 16'h1020;
                4'd4:  O_row_bits = 16'h7E20;
                4'd5:  O_row_bits = 16'h56FC;
                4'd6:  O_row_bits = 16'h5784;
                4'd7:  O_row_bits = 16'h5724;
                4'd8:  O_row_bits = 16'h5724;
                4'd9:  O_row_bits = 16'h5724;
                4'd10: O_row_bits = 16'h5524;
                4'd11: O_row_bits = 16'h5D24;
                4'd12: O_row_bits = 16'h5068;
                4'd13: O_row_bits = 16'h10CC;
                4'd14: O_row_bits = 16'h1182;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_YIJ: case(I_row)
                4'd0:  O_row_bits = 16'h0000;
                4'd1:  O_row_bits = 16'h3FF8;
                4'd2:  O_row_bits = 16'h0008;
                4'd3:  O_row_bits = 16'h0008;
                4'd4:  O_row_bits = 16'h3008;
                4'd5:  O_row_bits = 16'h3008;
                4'd6:  O_row_bits = 16'h3FF8;
                4'd7:  O_row_bits = 16'h3008;
                4'd8:  O_row_bits = 16'h3000;
                4'd9:  O_row_bits = 16'h3000;
                4'd10: O_row_bits = 16'h3000;
                4'd11: O_row_bits = 16'h3006;
                4'd12: O_row_bits = 16'h3006;
                4'd13: O_row_bits = 16'h1FFC;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_LIAN: case(I_row)
                4'd0:  O_row_bits = 16'h0040;
                4'd1:  O_row_bits = 16'h6080;
                4'd2:  O_row_bits = 16'h37FE;
                4'd3:  O_row_bits = 16'h1100;
                4'd4:  O_row_bits = 16'h0120;
                4'd5:  O_row_bits = 16'h0220;
                4'd6:  O_row_bits = 16'h73FC;
                4'd7:  O_row_bits = 16'h1020;
                4'd8:  O_row_bits = 16'h1020;
                4'd9:  O_row_bits = 16'h17FE;
                4'd10: O_row_bits = 16'h1020;
                4'd11: O_row_bits = 16'h1020;
                4'd12: O_row_bits = 16'h3820;
                4'd13: O_row_bits = 16'h47FE;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_JIE: case(I_row)
                4'd0:  O_row_bits = 16'h1020;
                4'd1:  O_row_bits = 16'h13FE;
                4'd2:  O_row_bits = 16'h7C88;
                4'd3:  O_row_bits = 16'h1088;
                4'd4:  O_row_bits = 16'h1010;
                4'd5:  O_row_bits = 16'h17FE;
                4'd6:  O_row_bits = 16'h1C40;
                4'd7:  O_row_bits = 16'h73FE;
                4'd8:  O_row_bits = 16'h1088;
                4'd9:  O_row_bits = 16'h1198;
                4'd10: O_row_bits = 16'h10F0;
                4'd11: O_row_bits = 16'h1078;
                4'd12: O_row_bits = 16'h73C6;
                4'd13: O_row_bits = 16'h0200;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            CN_WEI: case(I_row)
                4'd0:  O_row_bits = 16'h0100;
                4'd1:  O_row_bits = 16'h0100;
                4'd2:  O_row_bits = 16'h3FF8;
                4'd3:  O_row_bits = 16'h0100;
                4'd4:  O_row_bits = 16'h0100;
                4'd5:  O_row_bits = 16'h7FFE;
                4'd6:  O_row_bits = 16'h0380;
                4'd7:  O_row_bits = 16'h0740;
                4'd8:  O_row_bits = 16'h0D60;
                4'd9:  O_row_bits = 16'h1930;
                4'd10: O_row_bits = 16'h311C;
                4'd11: O_row_bits = 16'h6106;
                4'd12: O_row_bits = 16'h0100;
                4'd13: O_row_bits = 16'h0000;
                4'd14: O_row_bits = 16'h0000;
                4'd15: O_row_bits = 16'h0000;
                default: O_row_bits = 16'h0000;
            endcase
            default: O_row_bits = 16'h0000;
        endcase
    end

endmodule
