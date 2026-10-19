// SMS alert sender for the C100m (Air780EPM, AT firmware).
//
// Sends a Chinese SMS in PDU mode (UCS2) on a rising edge of I_trig:
//   AT+CMGF=0                 (PDU mode)
//   AT+CMGS=48                (TPDU length, 48 bytes)
//   <49-byte PDU as ASCII hex> (SMSC 00 + TPDU: dest 18168092177,
//                                DCS=UCS2, body in Chinese) + Ctrl-Z
//
// Message body: "警告！警告！有害垃圾桶发生非法移动！"
// A 30-second cooldown prevents message storms.
module sms_sender #(
    parameter CLK_FREQ     = 52_000_000,
    parameter BAUD         = 115200,
    parameter COOLDOWN_SEC = 30
)(
    input  wire       I_clk,
    input  wire       I_rst_n,
    input  wire       I_trig,
    input  wire       I_uart_rx,   // reserved for future response parsing
    output wire       O_uart_tx,
    output reg        O_sending
);

    localparam DELAY_CNT      = CLK_FREQ / 5;          // ~200 ms per AT step
    localparam CMGS_DELAY_CNT = CLK_FREQ / 2;         // ~500 ms before PDU body
    localparam COOLDOWN_CNT   = CLK_FREQ * COOLDOWN_SEC;

    reg        trig_d;
    reg [3:0]  state;
    reg [7:0]  idx;
    reg [7:0]  byte_out;
    reg        tx_send;
    wire       tx_busy;
    reg [31:0] delay_cnt;
    reg [31:0] cooldown_cnt;

    localparam S_IDLE   = 4'd0;
    localparam S_CMGF   = 4'd1;
    localparam S_DELAY1 = 4'd2;
    localparam S_CMGS   = 4'd3;
    localparam S_DELAY3 = 4'd4;
    localparam S_BODY   = 4'd5;
    localparam S_DONE   = 4'd6;

    // Return one byte of a command stream.
    function [7:0] cmd_byte;
        input [3:0] st;
        input [7:0] i;
        begin
            case(st)
                S_CMGF: begin
                    // "AT+CMGF=0\r\n"
                    case(i)
                        8'd0:  cmd_byte = "A";
                        8'd1:  cmd_byte = "T";
                        8'd2:  cmd_byte = "+";
                        8'd3:  cmd_byte = "C";
                        8'd4:  cmd_byte = "M";
                        8'd5:  cmd_byte = "G";
                        8'd6:  cmd_byte = "F";
                        8'd7:  cmd_byte = "=";
                        8'd8:  cmd_byte = "0";
                        8'd9:  cmd_byte = 8'h0D;
                        8'd10: cmd_byte = 8'h0A;
                        default: cmd_byte = 8'h00;
                    endcase
                end
                S_CMGS: begin
                    // "AT+CMGS=48\r\n"
                    case(i)
                        8'd0:  cmd_byte = "A";
                        8'd1:  cmd_byte = "T";
                        8'd2:  cmd_byte = "+";
                        8'd3:  cmd_byte = "C";
                        8'd4:  cmd_byte = "M";
                        8'd5:  cmd_byte = "G";
                        8'd6:  cmd_byte = "S";
                        8'd7:  cmd_byte = "=";
                        8'd8:  cmd_byte = "4";
                        8'd9:  cmd_byte = "8";
                        8'd10: cmd_byte = 8'h0D;
                        8'd11: cmd_byte = 8'h0A;
                        default: cmd_byte = 8'h00;
                    endcase
                end
                S_BODY: begin
                    // PDU (49 bytes as ASCII hex) + Ctrl-Z.
                    // 0011000B818159915062F60008AA228B66544AFF018B66544AFF0167095BB35783573E687653D1751F975E6CD579FB52A8
                    case(i)
                        8'd0:  cmd_byte = "0";
                        8'd1:  cmd_byte = "0";
                        8'd2:  cmd_byte = "1";
                        8'd3:  cmd_byte = "1";
                        8'd4:  cmd_byte = "0";
                        8'd5:  cmd_byte = "0";
                        8'd6:  cmd_byte = "0";
                        8'd7:  cmd_byte = "B";
                        8'd8:  cmd_byte = "8";
                        8'd9:  cmd_byte = "1";
                        8'd10: cmd_byte = "8";
                        8'd11: cmd_byte = "1";
                        8'd12: cmd_byte = "5";
                        8'd13: cmd_byte = "9";
                        8'd14: cmd_byte = "9";
                        8'd15: cmd_byte = "1";
                        8'd16: cmd_byte = "5";
                        8'd17: cmd_byte = "0";
                        8'd18: cmd_byte = "6";
                        8'd19: cmd_byte = "2";
                        8'd20: cmd_byte = "F";
                        8'd21: cmd_byte = "6";
                        8'd22: cmd_byte = "0";
                        8'd23: cmd_byte = "0";
                        8'd24: cmd_byte = "0";
                        8'd25: cmd_byte = "8";
                        8'd26: cmd_byte = "A";
                        8'd27: cmd_byte = "A";
                        8'd28: cmd_byte = "2";
                        8'd29: cmd_byte = "2";
                        8'd30: cmd_byte = "8";
                        8'd31: cmd_byte = "B";
                        8'd32: cmd_byte = "6";
                        8'd33: cmd_byte = "6";
                        8'd34: cmd_byte = "5";
                        8'd35: cmd_byte = "4";
                        8'd36: cmd_byte = "4";
                        8'd37: cmd_byte = "A";
                        8'd38: cmd_byte = "F";
                        8'd39: cmd_byte = "F";
                        8'd40: cmd_byte = "0";
                        8'd41: cmd_byte = "1";
                        8'd42: cmd_byte = "8";
                        8'd43: cmd_byte = "B";
                        8'd44: cmd_byte = "6";
                        8'd45: cmd_byte = "6";
                        8'd46: cmd_byte = "5";
                        8'd47: cmd_byte = "4";
                        8'd48: cmd_byte = "4";
                        8'd49: cmd_byte = "A";
                        8'd50: cmd_byte = "F";
                        8'd51: cmd_byte = "F";
                        8'd52: cmd_byte = "0";
                        8'd53: cmd_byte = "1";
                        8'd54: cmd_byte = "6";
                        8'd55: cmd_byte = "7";
                        8'd56: cmd_byte = "0";
                        8'd57: cmd_byte = "9";
                        8'd58: cmd_byte = "5";
                        8'd59: cmd_byte = "B";
                        8'd60: cmd_byte = "B";
                        8'd61: cmd_byte = "3";
                        8'd62: cmd_byte = "5";
                        8'd63: cmd_byte = "7";
                        8'd64: cmd_byte = "8";
                        8'd65: cmd_byte = "3";
                        8'd66: cmd_byte = "5";
                        8'd67: cmd_byte = "7";
                        8'd68: cmd_byte = "3";
                        8'd69: cmd_byte = "E";
                        8'd70: cmd_byte = "6";
                        8'd71: cmd_byte = "8";
                        8'd72: cmd_byte = "7";
                        8'd73: cmd_byte = "6";
                        8'd74: cmd_byte = "5";
                        8'd75: cmd_byte = "3";
                        8'd76: cmd_byte = "D";
                        8'd77: cmd_byte = "1";
                        8'd78: cmd_byte = "7";
                        8'd79: cmd_byte = "5";
                        8'd80: cmd_byte = "1";
                        8'd81: cmd_byte = "F";
                        8'd82: cmd_byte = "9";
                        8'd83: cmd_byte = "7";
                        8'd84: cmd_byte = "5";
                        8'd85: cmd_byte = "E";
                        8'd86: cmd_byte = "6";
                        8'd87: cmd_byte = "C";
                        8'd88: cmd_byte = "D";
                        8'd89: cmd_byte = "5";
                        8'd90: cmd_byte = "7";
                        8'd91: cmd_byte = "9";
                        8'd92: cmd_byte = "F";
                        8'd93: cmd_byte = "B";
                        8'd94: cmd_byte = "5";
                        8'd95: cmd_byte = "2";
                        8'd96: cmd_byte = "A";
                        8'd97: cmd_byte = "8";
                        8'd98: cmd_byte = 8'h1A; // Ctrl-Z
                        default: cmd_byte = 8'h00;
                    endcase
                end
                default: cmd_byte = 8'h00;
            endcase
        end
    endfunction

    // Number of bytes in each command stream.
    function [7:0] cmd_len;
        input [3:0] st;
        begin
            case(st)
                S_CMGF: cmd_len = 8'd11;
                S_CMGS: cmd_len = 8'd12;
                S_BODY: cmd_len = 8'd99;
                default: cmd_len = 8'd0;
            endcase
        end
    endfunction

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            trig_d       <= 1'b0;
            state        <= S_IDLE;
            idx          <= 8'd0;
            byte_out     <= 8'd0;
            tx_send      <= 1'b0;
            delay_cnt    <= 32'd0;
            cooldown_cnt <= 32'd0;
            O_sending    <= 1'b0;
        end
        else begin
            trig_d <= I_trig;

            case(state)
                S_IDLE: begin
                    tx_send   <= 1'b0;
                    O_sending <= 1'b0;
                    if(cooldown_cnt != 32'd0)
                        cooldown_cnt <= cooldown_cnt - 1'b1;
                    else if(I_trig && !trig_d) begin
                        state <= S_CMGF;
                        idx   <= 8'd0;
                    end
                end

                S_CMGF, S_CMGS, S_BODY: begin
                    O_sending <= 1'b1;
                    if(!tx_busy && !tx_send) begin
                        if(idx < cmd_len(state)) begin
                            byte_out <= cmd_byte(state, idx);
                            tx_send  <= 1'b1;
                            idx      <= idx + 1'b1;
                        end
                        else begin
                            tx_send <= 1'b0;
                            case(state)
                                S_CMGF: state <= S_DELAY1;
                                S_CMGS: state <= S_DELAY3;
                                S_BODY: state <= S_DONE;
                                default: state <= S_IDLE;
                            endcase
                            idx       <= 8'd0;
                            delay_cnt <= 32'd0;
                        end
                    end
                    else if(tx_busy) begin
                        tx_send <= 1'b0;
                    end
                end

                S_DELAY1: begin
                    if(delay_cnt < DELAY_CNT) begin
                        delay_cnt <= delay_cnt + 1'b1;
                    end
                    else begin
                        state <= S_CMGS;
                        idx   <= 8'd0;
                    end
                end

                S_DELAY3: begin
                    if(delay_cnt < CMGS_DELAY_CNT) begin
                        delay_cnt <= delay_cnt + 1'b1;
                    end
                    else begin
                        state <= S_BODY;
                        idx   <= 8'd0;
                    end
                end

                S_DONE: begin
                    O_sending    <= 1'b0;
                    cooldown_cnt <= COOLDOWN_CNT;
                    state        <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD    (BAUD)
    ) u_uart_tx (
        .I_clk   (I_clk),
        .I_rst_n (I_rst_n),
        .I_data  (byte_out),
        .I_send  (tx_send),
        .O_tx    (O_uart_tx),
        .O_busy  (tx_busy)
    );

endmodule
