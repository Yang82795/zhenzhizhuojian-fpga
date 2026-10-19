// 115200-8-N-1 UART transmitter.
// On I_send it immediately drives the start bit, then 8 data bits (LSB first)
// and a full-length stop bit. O_busy stays high until the stop bit completes.
module uart_tx #(
    parameter CLK_FREQ = 52_000_000,
    parameter BAUD     = 115200
)(
    input  wire        I_clk,
    input  wire        I_rst_n,
    input  wire [7:0]  I_data,
    input  wire        I_send,
    output reg         O_tx,
    output reg         O_busy
);

    localparam BIT_DIV = CLK_FREQ / BAUD;

    reg [15:0] div_cnt;
    reg [3:0]  bit_cnt;
    reg [7:0]  shift_reg;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            O_tx      <= 1'b1;
            O_busy    <= 1'b0;
            div_cnt   <= 16'd0;
            bit_cnt   <= 4'd0;
            shift_reg <= 8'd0;
        end
        else begin
            if(I_send && !O_busy) begin
                O_busy    <= 1'b1;
                shift_reg <= I_data;
                bit_cnt   <= 4'd0;
                div_cnt   <= 16'd0;
                O_tx      <= 1'b0;          // start bit
            end
            else if(O_busy) begin
                if(div_cnt == BIT_DIV - 1) begin
                    div_cnt <= 16'd0;
                    if(bit_cnt == 4'd9) begin
                        // stop bit already held for one full bit time
                        O_busy <= 1'b0;
                    end
                    else if(bit_cnt == 4'd8) begin
                        O_tx    <= 1'b1;    // stop bit
                        bit_cnt <= 4'd9;
                    end
                    else begin
                        O_tx      <= shift_reg[0];  // data bit (LSB first)
                        shift_reg <= shift_reg >> 1;
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                end
                else begin
                    div_cnt <= div_cnt + 1'b1;
                end
            end
        end
    end

endmodule
