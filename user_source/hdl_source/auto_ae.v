// Simple closed-loop automatic exposure controller.
// Runs in the 24 MHz domain and adjusts AE/AG once per frame based on the
// synchronized brightness status from brightness_measure.
module auto_ae (
    input  wire        I_clk,
    input  wire        I_rst_n,
    input  wire [1:0]  I_status,
    input  wire        I_frame_tick,
    output reg  [15:0] O_ae,
    output reg  [15:0] O_ag,
    output reg         O_ae_req
);

    reg [15:0] ae;
    reg [15:0] ag;
    reg [15:0] new_ae;
    reg [15:0] new_ag;

    always @(*) begin
        case(I_status)
            2'b01: begin
                new_ae = (ae < 16'd2246) ? ae + 16'd8  : ae;
                new_ag = (ag < 16'd89)   ? ag + 16'd1  : ag;
            end
            2'b10: begin
                new_ae = (ae > 16'd2) ? ae - 16'd8 : ae;
                new_ag = (ag > 16'd16) ? ag - 16'd1 : ag;
            end
            default: begin
                new_ae = ae;
                new_ag = ag;
            end
        endcase
    end

    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            ae <= 16'd3000;
            ag <= 16'd80;
            O_ae <= 16'd3000;
            O_ag <= 16'd80;
            O_ae_req <= 1'b0;
        end
        else begin
            O_ae_req <= 1'b0;
            if(I_frame_tick) begin
                O_ae <= new_ae;
                O_ag <= new_ag;
                if((new_ae != ae) || (new_ag != ag))
                    O_ae_req <= 1'b1;
                ae <= new_ae;
                ag <= new_ag;
            end
        end
    end

endmodule
