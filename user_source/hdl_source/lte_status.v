// 4G module status checker.
//
// Every POLL_INTERVAL ticks it sends "AT\r\n" and waits for "OK" on the RX
// line. O_lte_ok stays high while OK responses keep arriving; it goes low if
// no OK is received within TIMEOUT ticks.
//
// It pauses polling while I_tx_busy is high so it does not collide with the
// SMS sender sharing the UART.
module lte_status #(
    parameter CLK_FREQ      = 52_000_000,
    parameter POLL_INTERVAL = 2,          // seconds between polls (debug)
    parameter TIMEOUT       = 10          // seconds to wait for OK before showing "disconnected"
)(
    input  wire       I_clk,
    input  wire       I_rst_n,
    input  wire       I_rx,
    input  wire       I_tx_busy,          // from SMS sender, hold off while set
    output wire       O_tx,
    output reg        O_lte_ok,
    output reg        O_polling           // debug: high while sending AT / waiting OK
);

    localparam BAUD     = 115200;
    localparam BIT_DIV  = CLK_FREQ / BAUD;
    localparam POLL_CNT = CLK_FREQ * POLL_INTERVAL;
    localparam TMO_CNT  = CLK_FREQ * TIMEOUT;

    reg [31:0] timer;
    reg [31:0] tmo;
    reg        waiting;

    // RX receiver outputs
    wire [7:0] rx_data;
    wire       rx_valid;

    // AT sequence sender (minimal, one command only).
    reg [7:0]  tx_byte;
    reg        tx_send;
    wire       tx_busy;
    reg [3:0]  state;
    reg [7:0]  idx;

    // RX parser: detect 'O' followed by 'K'.
    reg        saw_o;

    localparam T_IDLE   = 4'd0;
    localparam T_SEND   = 4'd1;
    localparam T_WAIT   = 4'd2;

    function [7:0] at_byte;
        input [7:0] i;
        begin
            case(i)
                8'd0: at_byte = "A";
                8'd1: at_byte = "T";
                8'd2: at_byte = 8'h0D;
                8'd3: at_byte = 8'h0A;
                default: at_byte = 8'h00;
            endcase
        end
    endfunction

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            O_lte_ok <= 1'b0;
            O_polling <= 1'b0;
            timer    <= 32'd0;
            tmo      <= 32'd0;
            waiting  <= 1'b0;
            saw_o    <= 1'b0;
            state    <= T_IDLE;
            idx      <= 8'd0;
            tx_byte  <= 8'd0;
            tx_send  <= 1'b0;
        end
        else begin
            O_polling <= (state == T_SEND) || (state == T_WAIT);

            // RX parse
            if(rx_valid) begin
                if(rx_data == "O") saw_o <= 1'b1;
                else if(rx_data == "K" && saw_o) begin
                    O_lte_ok <= 1'b1;
                    tmo      <= 32'd0;
                    saw_o    <= 1'b0;
                    waiting  <= 1'b0;
                end
                else saw_o <= 1'b0;
            end

            // timeout resets lte_ok
            if(waiting) begin
                if(tmo < TMO_CNT)
                    tmo <= tmo + 1'b1;
                else begin
                    O_lte_ok <= 1'b0;
                    waiting  <= 1'b0;
                end
            end

            case(state)
                T_IDLE: begin
                    if(timer < POLL_CNT && !I_tx_busy)
                        timer <= timer + 1'b1;
                    else if(!I_tx_busy) begin
                        state <= T_SEND;
                        idx   <= 8'd0;
                        timer <= 32'd0;
                        tmo   <= 32'd0;
                    end
                end

                T_SEND: begin
                    if(!tx_busy && !tx_send) begin
                        if(idx < 8'd4) begin
                            tx_byte <= at_byte(idx);
                            tx_send <= 1'b1;
                            idx     <= idx + 1'b1;
                        end
                        else begin
                            tx_send <= 1'b0;
                            state   <= T_WAIT;
                            waiting <= 1'b1;
                        end
                    end
                    else if(tx_busy)
                        tx_send <= 1'b0;
                end

                T_WAIT: begin
                    if(!waiting) state <= T_IDLE;
                end

                default: state <= T_IDLE;
            endcase
        end
    end

    // RX receiver + a small TX instance
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD    (BAUD)
    ) u_uart_rx (
        .I_clk   (I_clk),
        .I_rst_n (I_rst_n),
        .I_rx    (I_rx),
        .O_data  (rx_data),
        .O_valid (rx_valid)
    );

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD    (BAUD)
    ) u_uart_tx (
        .I_clk   (I_clk),
        .I_rst_n (I_rst_n),
        .I_data  (tx_byte),
        .I_send  (tx_send),
        .O_tx    (O_tx),
        .O_busy  (tx_busy)
    );

endmodule
