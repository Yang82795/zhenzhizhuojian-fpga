// 115200-8-N-1 UART receiver.
// Samples in the middle of each bit. O_valid pulses one cycle per received byte.
module uart_rx #(
    parameter CLK_FREQ = 52_000_000,
    parameter BAUD     = 115200
)(
    input  wire        I_clk,
    input  wire        I_rst_n,
    input  wire        I_rx,
    output reg  [7:0]  O_data,
    output reg         O_valid
);

    localparam BIT_DIV   = CLK_FREQ / BAUD;   // ~452
    localparam HALF_DIV  = BIT_DIV / 2;       // ~226

    reg        rx_d1;
    reg        rx_d2;
    reg [3:0]  bit_cnt;
    reg [15:0] div_cnt;
    reg [7:0]  shift_reg;
    reg        receiving;

    wire rx_fall = rx_d2 && !rx_d1;

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            rx_d1     <= 1'b1;
            rx_d2     <= 1'b1;
            bit_cnt   <= 4'd0;
            div_cnt   <= 16'd0;
            shift_reg <= 8'd0;
            receiving <= 1'b0;
            O_data    <= 8'd0;
            O_valid   <= 1'b0;
        end
        else begin
            rx_d1 <= I_rx;
            rx_d2 <= rx_d1;
            O_valid <= 1'b0;

            if(!receiving) begin
                if(rx_fall) begin
                    receiving <= 1'b1;
                    bit_cnt   <= 4'd0;
                    div_cnt   <= 16'd0;
                end
            end
            else begin
                if(div_cnt < BIT_DIV - 1)
                    div_cnt <= div_cnt + 1'b1;
                else
                    div_cnt <= 16'd0;

                // Sample near the middle of each bit period.
                if(div_cnt == HALF_DIV) begin
                    case(bit_cnt)
                        4'd0: begin  // start bit
                            if(rx_d1 == 1'b1)
                                receiving <= 1'b0; // glitch
                            bit_cnt <= 4'd1;
                        end
                        4'd1,4'd2,4'd3,4'd4,
                        4'd5,4'd6,4'd7,4'd8: begin
                            shift_reg <= {rx_d1, shift_reg[7:1]};
                            bit_cnt   <= bit_cnt + 1'b1;
                        end
                        4'd9: begin  // stop bit
                            O_data    <= shift_reg;
                            O_valid   <= 1'b1;
                            receiving <= 1'b0;
                            bit_cnt   <= 4'd0;
                        end
                        default: begin
                            receiving <= 1'b0;
                            bit_cnt   <= 4'd0;
                        end
                    endcase
                end
            end
        end
    end

endmodule
