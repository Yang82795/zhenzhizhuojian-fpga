

module design_top_wrapper (
    input wire        I_sys_clk,
    input wire        I_rst_n,
    input wire [1:0]  I_sw_mode,
    input wire        I_sw_ae,
    input wire        I_sw_motion,
      
    output wire       O_cam_scl,
    inout  wire       IO_cam_sda,
    output wire       O_cam_24m,
    output wire       O_cam_rst,
      
    inout wire [1:0]  I_button,

    output wire       O_screen_pwm,
    output wire [3:0] O_dbg_led,
    output wire       O_buzzer,
    output wire       O_uart_tx,
    input  wire       I_uart_rx,
    output wire       O_4g_rst,
    output wire       O_tmds_ch0_p,
    output wire       O_tmds_ch1_p,
    output wire       O_tmds_ch2_p,
    output wire       O_tmds_clk_p,

    inout wire        IO_rx_clk_pad_n, 
    inout wire        IO_rx_clk_pad_p, 
    inout wire[3:0]   IO_rx_data_pad_n,
    inout wire[3:0]   IO_rx_data_pad_p,

    output wire[12:0] ddr_addr,
    output wire[ 1:0] ddr_ba,
    output wire[ 0:0] ddr_cke,
    output wire[ 0:0] ddr_odt,
    output wire[ 0:0] ddr_cs_n,
    output wire       ddr_ras_n,
    output wire       ddr_cas_n,
    output wire       ddr_we_n,
    output wire[ 0:0] ddr_ck_p,
    output wire[ 0:0] ddr_ck_n,
    inout wire[1:0]   ddr_dm,
    inout wire[15:0]  ddr_dq,
    inout wire[1:0]   ddr_dqs_p,
    inout wire[1:0]   ddr_dqs_n   
);


    wire        	S_100m_clk;
    wire        	S_24m_clk;
    wire        	S_aux_50m_clk;
	wire        	S_10m_clk;
		
    wire        	S_pll_lock;
    wire        	S_rst_n;
    wire [1:0]  	S_video_mode;
    reg  [1:0]  	S_video_mode_isp_sync1;
    reg  [1:0]  	S_video_mode_isp_sync2;
    reg  [1:0]  	S_video_mode_hdmi_sync1;
    reg  [1:0]  	S_video_mode_hdmi_sync2;
    reg         	S_auto_ae_on_hdmi_sync1;
    reg         	S_auto_ae_on_hdmi_sync2;
    reg         	S_motion_on_hdmi_sync1;
    reg         	S_motion_on_hdmi_sync2;
    reg         	S_ae_req_led;
    reg         	S_sw_ae_d;
	
	wire [15:0] 	S_ae;
    wire [15:0] 	S_ag;
    wire 			S_cam_cfg_done;
    wire 			S_ae_cfg_done;
    wire 			S_ae_req; 

    reg  [1:0]  	S_bright_status;
    reg         	S_bright_toggle;
    reg  [1:0]  	S_bright_status_sync1;
    reg  [1:0]  	S_bright_status_sync2;
    reg         	S_toggle_sync1;
    reg         	S_toggle_sync2;
    reg         	S_toggle_sync3;
    wire        	S_frame_tick;
    reg  [15:0] 	S_auto_ae;
    reg  [15:0] 	S_auto_ag;
    reg         	S_auto_ae_req;
    reg  [27:0] 	S_bright_sum;
    reg  [15:0] 	S_ae_auto_r;
    reg  [15:0] 	S_ag_auto_r;
    reg  [15:0] 	S_new_ae;
    reg  [15:0] 	S_new_ag;
    wire [15:0] 	S_ae_sel;
    wire [15:0] 	S_ag_sel;
    wire        	S_ae_req_sel;
	
	wire        	S_csi_rx_clk;  
    wire        	S_hs_rx_valid;  
    wire[15:0]  	S_hs_rx_data;   
	wire[1:0]   	S_lane_error;
	
	wire        	S_csi_frame_start;       
	wire        	S_csi_frame_end;         
	wire        	S_csi_valid;             
	wire[31:0]  	S_csi_data;  
		
	wire        	S_raw10_frame_start; 
	wire        	S_raw10_frame_end;   
	wire        	S_raw10_valid;       
	wire [39:0] 	S_raw10_data;
		
	wire 			S_axis_tlast;  
	wire 			S_axis_tuser;  
	wire [39:0]		S_axis_tdata;  
	wire 			S_axis_tvalid; 
	
	wire [39:0]		S_raw_tdata ;
	wire			S_raw_tlast ;
	wire 			S_raw_tvalid;
	wire 			S_raw_tuser ;
	
	wire			S_ISP_O_tready;
	wire [127:0]	S_ISP_O_tdata ;
	wire 			S_ISP_O_tlast ;
	wire 			S_ISP_O_tuser ;
	wire 			S_ISP_O_tvalid; 
	

    wire        S_ddr_clk;
    wire        S_hdmi_pixel_clk;
    wire        S_hdmi_serial_clk;
    wire        S_hdmi_rst_n;
    wire        S_video_out_rst_n;


    wire        S_vi_128b_frame_start;
    wire        S_vi_128b_valid;      
    wire[127:0] S_vi_128b_data;    
    
    wire        S_video_out_rd_busy;
    wire        S_video_in_wr_busy; 
    wire[1:0]   S_video_out_rp;     

    wire        S_ddr_user_wr_en;       
    wire        S_ddr_user_rd_en;       
    wire[24:0]  S_ddr_user_addr;        
    wire[127:0] S_ddr_user_wr_data;     
    wire        S_ddr_user_ready;       
    wire        S_ddr_user_rd_valid;    
    wire[127:0] S_ddr_user_rd_data;     

    wire        S_vi_ddr_wr_en;   
    wire[24:0]  S_vi_ddr_wr_addr; 
    wire[127:0] S_vi_ddr_wr_data;
    wire        S_vi_ddr_wr_ready;

    wire        S_vo_ddr_rd_en;   
    wire[24:0]  S_vo_ddr_rd_addr; 
    wire        S_vo_ddr_rd_ready;
    wire        S_vo_dbg_fifo_rst;
    wire        S_vo_dbg_ddr_rd_valid;
    wire        S_vo_dbg_fifo_rd_en;
    wire        S_vo_dbg_fifo_empty;

    wire        S_init_calib_complete; 
    wire[24:0]  S_mc_app_addr;          
    wire[2:0]   S_mc_app_cmd;           
    wire        S_mc_app_en;            
    wire[127:0] S_mc_app_wdf_data;      
    wire        S_mc_app_wdf_end;       
    wire[15:0]  S_mc_app_wdf_mask;      
    wire        S_mc_app_wdf_wren;      
    wire[127:0] S_mc_app_rd_data;       
    wire        S_mc_app_rd_data_end;   
    wire        S_mc_app_rd_data_valid; 
    wire        S_mc_app_rdy;           
    wire        S_mc_app_wdf_rdy;       
    wire        S_mc_dbg_fifo_afull;
    wire        S_mc_dbg_app_rdy;
    wire        S_mc_dbg_wdf_rdy;
    wire        S_mc_dbg_cmd_pop;

    wire        S_hdmi_vsync;
    wire        S_hdmi_hsync;
    wire        S_hdmi_de;
    wire        S_hdmi_user;
    wire        S_hdmi_last;
    wire        S_video_out_vsync;
    wire        S_hdmi_window_rd_en;
    wire        S_hdmi_out_vsync;
    wire        S_hdmi_out_hsync;
    wire        S_hdmi_out_de;
    wire[23:0]  S_hdmi_out_data;

    wire[23:0]  S_video_rd_data;
    wire        S_blue_valid;
    wire [10:0] S_blue_x0, S_blue_y0, S_blue_x1, S_blue_y1;
    wire        S_red_valid;
    wire [10:0] S_red_x0, S_red_y0, S_red_x1, S_red_y1;
    wire        S_green_valid;
    wire [10:0] S_green_x0, S_green_y0, S_green_x1, S_green_y1;
    wire [10:0] S_blue_cx  = (S_blue_x0  + S_blue_x1)  >> 1;
    wire [10:0] S_blue_cy  = (S_blue_y0  + S_blue_y1)  >> 1;
    wire [10:0] S_red_cx   = (S_red_x0   + S_red_x1)   >> 1;
    wire [10:0] S_red_cy   = (S_red_y0   + S_red_y1)   >> 1;
    wire [10:0] S_green_cx = (S_green_x0 + S_green_x1) >> 1;
    wire [10:0] S_green_cy = (S_green_y0 + S_green_y1) >> 1;

    wire        S_motion_valid;
    wire [10:0] S_motion_x0, S_motion_y0, S_motion_x1, S_motion_y1;
    wire        S_any_target_valid = S_track_blue_valid || S_track_red_valid || S_track_green_valid;
    wire        S_motion_valid_gated = S_motion_valid && S_motion_on_hdmi_sync2 && S_any_target_valid;
    reg  [5:0]  S_motion_hold_cnt;
    wire        S_motion_valid_held = S_motion_valid_gated || (S_motion_hold_cnt != 6'd0);
    wire        S_motion_fullscreen = (S_motion_x0 == 11'd0) && (S_motion_y0 == 11'd0) &&
                                      (S_motion_x1 >= 11'd1023) && (S_motion_y1 >= 11'd599);

    wire        S_track_blue_valid;
    wire [10:0] S_track_blue_x0, S_track_blue_y0, S_track_blue_x1, S_track_blue_y1;
    wire [10:0] S_track_blue_cx, S_track_blue_cy;
    wire        S_track_red_valid;
    wire [10:0] S_track_red_x0, S_track_red_y0, S_track_red_x1, S_track_red_y1;
    wire [10:0] S_track_red_cx, S_track_red_cy;
    wire        S_track_green_valid;
    wire [10:0] S_track_green_x0, S_track_green_y0, S_track_green_x1, S_track_green_y1;
    wire [10:0] S_track_green_cx, S_track_green_cy;
    localparam  BUZZER_CNT_MAX = 26'd51999999;
    localparam  BUZZER_COOLDOWN_MAX = 32'd1560000000;   // 30 s at 52 MHz
    wire        S_buzzer_cond = S_track_red_valid && S_motion_valid_held;
    reg         S_buzzer_cond_d;
    reg  [25:0] S_buzzer_cnt;
    reg         S_buzzer_on;
    reg  [31:0] S_buzzer_cooldown;
    reg  [13:0] S_buzzer_tone_cnt;
    reg         S_buzzer_tone;
    reg         S_isp_tuser_d;
    reg         S_isp_fs_toggle;
    reg         S_isp_fs_toggle_hdmi1;
    reg         S_isp_fs_toggle_hdmi2;
    reg         S_isp_fs_toggle_hdmi3;
    reg  [31:0] S_isp_frame_cnt_hdmi;
    reg  [31:0] S_hdmi_frame_cnt;
    reg  [15:0] S_latency_frames;
    reg         S_latency_valid;
    reg         S_dbg_raw_seen;
    reg         S_dbg_isp_seen;
    reg         S_dbg_ddr_wr_seen;
    reg         S_dbg_ddr_rd_seen;
    reg         S_dbg_cam_cfg_seen;
    reg         S_dbg_hs_seen;
    reg         S_dbg_csi_seen;
    reg         S_dbg_raw10_seen;
    reg         S_dbg_isp_fs_seen;
    reg         S_dbg_isp_valid_seen;
    reg         S_dbg_ddr_req_seen;
    reg         S_dbg_ddr_ready_seen;
    reg [1:0]   S_dbg_raw_seen_sync;
    reg [1:0]   S_dbg_isp_seen_sync;
    reg [1:0]   S_dbg_ddr_wr_seen_sync;
    reg [1:0]   S_dbg_ddr_rd_seen_sync;
    reg [1:0]   S_dbg_cam_cfg_seen_sync;
    reg [1:0]   S_dbg_hs_seen_sync;
    reg [1:0]   S_dbg_csi_seen_sync;
    reg [1:0]   S_dbg_raw10_seen_sync;
    reg [1:0]   S_dbg_isp_fs_seen_sync;
    reg [1:0]   S_dbg_isp_valid_seen_sync;
    reg [1:0]   S_dbg_ddr_req_seen_sync;
    reg [1:0]   S_dbg_ddr_ready_seen_sync;
    reg         S_dbg_video_nonzero_seen;
    reg         S_dbg_rd_req_seen;
    reg         S_dbg_rd_valid_seen;
    reg         S_dbg_rd_nonzero_seen;
    reg [1:0]   S_dbg_rd_req_seen_sync;
    reg [1:0]   S_dbg_rd_valid_seen_sync;
    reg [1:0]   S_dbg_rd_nonzero_seen_sync;
    reg         S_dbg_mc_init_seen;
    reg         S_dbg_mc_app_rdy_seen;
    reg         S_dbg_mc_wdf_rdy_seen;
    reg         S_dbg_mc_cmd_pop_seen;
    reg [1:0]   S_dbg_mc_init_seen_sync;
    reg [1:0]   S_dbg_mc_app_rdy_seen_sync;
    reg [1:0]   S_dbg_mc_wdf_rdy_seen_sync;
    reg [1:0]   S_dbg_mc_cmd_pop_seen_sync;
    wire[3:0]   S_hdmi_debug_status;
    wire        S_lane_error_any;
    wire        S_sms_sending;
    wire        S_sms_tx;
    wire        S_lte_tx;
    wire        S_lte_ok;
    wire        S_lte_polling;

    // Free-running counter for basic clock/reset sanity check.
    reg [25:0] S_dbg_cnt;
    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n)
            S_dbg_cnt <= 26'd0;
        else
            S_dbg_cnt <= S_dbg_cnt + 1'b1;
    end

    assign O_screen_pwm = 1'b1;
    assign O_buzzer     = S_buzzer_on ? ~S_buzzer_tone : 1'b1;
    assign S_video_out_vsync = ~S_hdmi_vsync;
	
	
    assign S_rst_n 		= S_pll_lock;
    assign S_hdmi_rst_n = S_pll_lock;

    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_raw_seen <= 1'b0;
        else if(S_raw10_frame_start | S_axis_tvalid)
            S_dbg_raw_seen <= 1'b1;
    end

    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_isp_seen <= 1'b0;
        else if(S_ISP_O_tuser | S_ISP_O_tvalid)
            S_dbg_isp_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_ddr_wr_seen <= 1'b0;
        else if(S_vi_ddr_wr_en)
            S_dbg_ddr_wr_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_ddr_rd_seen <= 1'b0;
        else if(S_ddr_user_rd_valid)
            S_dbg_ddr_rd_seen <= 1'b1;
    end

    always @(posedge S_24m_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_cam_cfg_seen <= 1'b0;
        else if(S_cam_cfg_done)
            S_dbg_cam_cfg_seen <= 1'b1;
    end

    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_hs_seen <= 1'b0;
        else if(S_hs_rx_valid)
            S_dbg_hs_seen <= 1'b1;
    end

    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_csi_seen <= 1'b0;
        else if(S_csi_frame_start | S_csi_valid)
            S_dbg_csi_seen <= 1'b1;
    end

    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_raw10_seen <= 1'b0;
        else if(S_raw10_frame_start | S_raw10_valid)
            S_dbg_raw10_seen <= 1'b1;
    end

    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_isp_fs_seen <= 1'b0;
        else if(S_ISP_O_tuser)
            S_dbg_isp_fs_seen <= 1'b1;
    end

    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_isp_valid_seen <= 1'b0;
        else if(S_ISP_O_tvalid)
            S_dbg_isp_valid_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_ddr_req_seen <= 1'b0;
        else if(S_vi_ddr_wr_en)
            S_dbg_ddr_req_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_ddr_ready_seen <= 1'b0;
        else if(S_ddr_user_ready)
            S_dbg_ddr_ready_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_video_out_rst_n) begin
        if(!S_video_out_rst_n)
            S_dbg_rd_req_seen <= 1'b0;
        else if(S_video_out_vsync)
            S_dbg_rd_req_seen <= 1'b0;
        else if(S_vo_ddr_rd_en)
            S_dbg_rd_req_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_video_out_rst_n) begin
        if(!S_video_out_rst_n)
            S_dbg_rd_valid_seen <= 1'b0;
        else if(S_video_out_vsync)
            S_dbg_rd_valid_seen <= 1'b0;
        else if(S_ddr_user_rd_valid)
            S_dbg_rd_valid_seen <= 1'b1;
    end

    always @(posedge S_hdmi_pixel_clk or negedge S_video_out_rst_n) begin
        if(!S_video_out_rst_n)
            S_dbg_rd_nonzero_seen <= 1'b0;
        else if(S_video_out_vsync)
            S_dbg_rd_nonzero_seen <= 1'b0;
        else if(S_hdmi_window_rd_en && (S_video_rd_data != 24'd0))
            S_dbg_rd_nonzero_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_mc_init_seen <= 1'b0;
        else if(S_init_calib_complete)
            S_dbg_mc_init_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_mc_app_rdy_seen <= 1'b0;
        else if(S_mc_dbg_app_rdy)
            S_dbg_mc_app_rdy_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_mc_wdf_rdy_seen <= 1'b0;
        else if(S_mc_dbg_wdf_rdy)
            S_dbg_mc_wdf_rdy_seen <= 1'b1;
    end

    always @(posedge S_ddr_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_dbg_mc_cmd_pop_seen <= 1'b0;
        else if(S_mc_dbg_cmd_pop)
            S_dbg_mc_cmd_pop_seen <= 1'b1;
    end

    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_dbg_cam_cfg_seen_sync <= 2'b00;
            S_dbg_hs_seen_sync      <= 2'b00;
            S_dbg_csi_seen_sync     <= 2'b00;
            S_dbg_raw10_seen_sync   <= 2'b00;
            S_dbg_raw_seen_sync    <= 2'b00;
            S_dbg_isp_seen_sync    <= 2'b00;
            S_dbg_ddr_wr_seen_sync <= 2'b00;
            S_dbg_ddr_rd_seen_sync <= 2'b00;
            S_dbg_isp_fs_seen_sync  <= 2'b00;
            S_dbg_isp_valid_seen_sync <= 2'b00;
            S_dbg_ddr_req_seen_sync <= 2'b00;
            S_dbg_ddr_ready_seen_sync <= 2'b00;
            S_dbg_video_nonzero_seen <= 1'b0;
            S_dbg_rd_req_seen_sync <= 2'b00;
            S_dbg_rd_valid_seen_sync <= 2'b00;
            S_dbg_rd_nonzero_seen_sync <= 2'b00;
            S_dbg_mc_init_seen_sync <= 2'b00;
            S_dbg_mc_app_rdy_seen_sync <= 2'b00;
            S_dbg_mc_wdf_rdy_seen_sync <= 2'b00;
            S_dbg_mc_cmd_pop_seen_sync <= 2'b00;
        end
        else begin
            S_dbg_cam_cfg_seen_sync <= {S_dbg_cam_cfg_seen_sync[0], S_dbg_cam_cfg_seen};
            S_dbg_hs_seen_sync      <= {S_dbg_hs_seen_sync[0],      S_dbg_hs_seen};
            S_dbg_csi_seen_sync     <= {S_dbg_csi_seen_sync[0],     S_dbg_csi_seen};
            S_dbg_raw10_seen_sync   <= {S_dbg_raw10_seen_sync[0],   S_dbg_raw10_seen};
            S_dbg_raw_seen_sync    <= {S_dbg_raw_seen_sync[0],    S_dbg_raw_seen};
            S_dbg_isp_seen_sync    <= {S_dbg_isp_seen_sync[0],    S_dbg_isp_seen};
            S_dbg_ddr_wr_seen_sync <= {S_dbg_ddr_wr_seen_sync[0], S_dbg_ddr_wr_seen};
            S_dbg_ddr_rd_seen_sync <= {S_dbg_ddr_rd_seen_sync[0], S_dbg_ddr_rd_seen};
            S_dbg_isp_fs_seen_sync  <= {S_dbg_isp_fs_seen_sync[0],  S_dbg_isp_fs_seen};
            S_dbg_isp_valid_seen_sync <= {S_dbg_isp_valid_seen_sync[0], S_dbg_isp_valid_seen};
            S_dbg_ddr_req_seen_sync <= {S_dbg_ddr_req_seen_sync[0], S_dbg_ddr_req_seen};
            S_dbg_ddr_ready_seen_sync <= {S_dbg_ddr_ready_seen_sync[0], S_dbg_ddr_ready_seen};
            S_dbg_rd_req_seen_sync <= {S_dbg_rd_req_seen_sync[0], S_dbg_rd_req_seen};
            S_dbg_rd_valid_seen_sync <= {S_dbg_rd_valid_seen_sync[0], S_dbg_rd_valid_seen};
            S_dbg_rd_nonzero_seen_sync <= {S_dbg_rd_nonzero_seen_sync[0], S_dbg_rd_nonzero_seen};
            S_dbg_mc_init_seen_sync <= {S_dbg_mc_init_seen_sync[0], S_dbg_mc_init_seen};
            S_dbg_mc_app_rdy_seen_sync <= {S_dbg_mc_app_rdy_seen_sync[0], S_dbg_mc_app_rdy_seen};
            S_dbg_mc_wdf_rdy_seen_sync <= {S_dbg_mc_wdf_rdy_seen_sync[0], S_dbg_mc_wdf_rdy_seen};
            S_dbg_mc_cmd_pop_seen_sync <= {S_dbg_mc_cmd_pop_seen_sync[0], S_dbg_mc_cmd_pop_seen};
            if(S_hdmi_window_rd_en && (S_video_rd_data != 24'd0))
                S_dbg_video_nonzero_seen <= 1'b1;
        end
    end

    assign S_lane_error_any = |S_lane_error;

    assign S_vo_dbg_fifo_rst = 1'b0;
    assign S_vo_dbg_ddr_rd_valid = 1'b0;
    assign S_vo_dbg_fifo_rd_en = 1'b0;
    assign S_vo_dbg_fifo_empty = 1'b0;
    assign S_mc_dbg_fifo_afull = 1'b0;
    assign S_mc_dbg_app_rdy = 1'b0;
    assign S_mc_dbg_wdf_rdy = 1'b0;
    assign S_mc_dbg_cmd_pop = 1'b0;

    assign S_hdmi_debug_status = {
        (|S_ddr_user_rd_data),
        S_ddr_user_rd_valid,
        S_vo_ddr_rd_en,
        S_vi_ddr_wr_en
    };
	
	assign O_cam_rst 	= 1'b1;
    assign O_cam_24m 	= S_24m_clk;
	
	
	
	
    PLL u_PLL(
        .refclk      ( I_sys_clk         ),
        .reset    	 ( ~I_rst_n          ),
        
        .clk0_out    ( S_100m_clk        ),
        .clk1_out    ( S_24m_clk         ),

        .clk4_out    ( S_hdmi_pixel_clk  ),
        .clk5_out    ( S_hdmi_serial_clk ),

        .lock        ( S_pll_lock        )

    );

    assign S_video_mode = I_sw_mode;

    // Synchronize the mode register into the ISP (MIPI byte) clock domain.
    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n) begin
            S_video_mode_isp_sync1 <= 2'd0;
            S_video_mode_isp_sync2 <= 2'd0;
        end
        else begin
            S_video_mode_isp_sync1 <= S_video_mode;
            S_video_mode_isp_sync2 <= S_video_mode_isp_sync1;
        end
    end

    // Synchronize the mode register into the HDMI pixel clock domain.
    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_video_mode_hdmi_sync1 <= 2'd0;
            S_video_mode_hdmi_sync2 <= 2'd0;
        end
        else begin
            S_video_mode_hdmi_sync1 <= S_video_mode;
            S_video_mode_hdmi_sync2 <= S_video_mode_hdmi_sync1;
        end
    end

    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_auto_ae_on_hdmi_sync1 <= 1'b0;
            S_auto_ae_on_hdmi_sync2 <= 1'b0;
        end
        else begin
            S_auto_ae_on_hdmi_sync1 <= I_sw_ae;
            S_auto_ae_on_hdmi_sync2 <= S_auto_ae_on_hdmi_sync1;
        end
    end

    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_motion_on_hdmi_sync1 <= 1'b0;
            S_motion_on_hdmi_sync2 <= 1'b0;
        end
        else begin
            S_motion_on_hdmi_sync1 <= I_sw_motion;
            S_motion_on_hdmi_sync2 <= S_motion_on_hdmi_sync1;
        end
    end

    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_motion_hold_cnt <= 6'd0;
        end
        else if(S_hdmi_user) begin
            if(S_motion_valid_gated)
                S_motion_hold_cnt <= 6'd30;
            else if(S_motion_hold_cnt != 6'd0)
                S_motion_hold_cnt <= S_motion_hold_cnt - 1'b1;
        end
    end

    // Buzzer one-shot: red trash can detected and motion tracking is triggered.
    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_buzzer_cond_d <= 1'b0;
            S_buzzer_cnt    <= 26'd0;
            S_buzzer_on     <= 1'b0;
            S_buzzer_tone_cnt <= 14'd0;
            S_buzzer_tone     <= 1'b0;
            S_buzzer_cooldown <= 32'd0;
        end
        else begin
            S_buzzer_cond_d <= S_buzzer_cond;
            if(S_buzzer_cooldown != 32'd0)
                S_buzzer_cooldown <= S_buzzer_cooldown - 1'b1;

            if(S_buzzer_cond && !S_buzzer_cond_d && (S_buzzer_cooldown == 32'd0)) begin
                S_buzzer_on  <= 1'b1;
                S_buzzer_cnt <= 26'd0;
                S_buzzer_tone_cnt <= 14'd0;
                S_buzzer_tone     <= 1'b0;
                S_buzzer_cooldown <= BUZZER_COOLDOWN_MAX;
            end
            else if(S_buzzer_on) begin
                if(S_buzzer_cnt >= BUZZER_CNT_MAX) begin
                    S_buzzer_on  <= 1'b0;
                    S_buzzer_cnt <= 26'd0;
                    S_buzzer_tone_cnt <= 14'd0;
                    S_buzzer_tone     <= 1'b0;
                end
                else begin
                    S_buzzer_cnt <= S_buzzer_cnt + 1'b1;
                    if(S_buzzer_tone_cnt >= 14'd12999) begin
                        S_buzzer_tone_cnt <= 14'd0;
                        S_buzzer_tone     <= ~S_buzzer_tone;
                    end
                    else begin
                        S_buzzer_tone_cnt <= S_buzzer_tone_cnt + 1'b1;
                    end
                end
            end
        end
    end

    // Frame-sequence propagation latency measurement.
    // The ISP frame-start pulse toggles a flag in the MIPI byte-clock domain;
    // that flag is synchronized to the HDMI pixel domain where both the ISP
    // frame counter and the HDMI frame counter can be compared directly.
    always @(posedge S_csi_rx_clk or negedge S_rst_n) begin
        if(!S_rst_n) begin
            S_isp_tuser_d <= 1'b0;
            S_isp_fs_toggle <= 1'b0;
        end
        else begin
            S_isp_tuser_d <= S_ISP_O_tuser;
            if(S_ISP_O_tuser && !S_isp_tuser_d)
                S_isp_fs_toggle <= ~S_isp_fs_toggle;
        end
    end

    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_isp_fs_toggle_hdmi1 <= 1'b0;
            S_isp_fs_toggle_hdmi2 <= 1'b0;
            S_isp_fs_toggle_hdmi3 <= 1'b0;
        end
        else begin
            S_isp_fs_toggle_hdmi1 <= S_isp_fs_toggle;
            S_isp_fs_toggle_hdmi2 <= S_isp_fs_toggle_hdmi1;
            S_isp_fs_toggle_hdmi3 <= S_isp_fs_toggle_hdmi2;
        end
    end

    wire S_isp_fs_edge = S_isp_fs_toggle_hdmi2 ^ S_isp_fs_toggle_hdmi3;

    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_isp_frame_cnt_hdmi <= 32'd0;
            S_hdmi_frame_cnt     <= 32'd0;
            S_latency_frames     <= 16'd0;
            S_latency_valid      <= 1'b0;
        end
        else begin
            if(S_isp_fs_edge)
                S_isp_frame_cnt_hdmi <= S_isp_frame_cnt_hdmi + 1'b1;

            if(S_hdmi_user) begin
                S_hdmi_frame_cnt <= S_hdmi_frame_cnt + 1'b1;
                if(S_isp_frame_cnt_hdmi != 32'd0) begin
                    if(S_hdmi_frame_cnt >= S_isp_frame_cnt_hdmi) begin
                        S_latency_frames <= S_hdmi_frame_cnt - S_isp_frame_cnt_hdmi;
                        S_latency_valid  <= 1'b1;
                    end
                    else begin
                        S_latency_frames <= 16'd0;
                        S_latency_valid  <= 1'b0;
                    end
                end
            end
        end
    end

  
  ae_set u_ae_set (
      .I_clk(S_24m_clk),
      .I_rst(~S_rst_n),
      .I_btn({I_button,2'b11}),
      .I_cam_cfg_done(S_cam_cfg_done),
      .I_ae_cfg_done(S_ae_cfg_done),
      .O_ae_req(S_ae_req),
      .O_ae(S_ae),
      .O_ag(S_ag)
  );

    // Inline frame-brightness measurement (HDMI pixel clock domain).
    always @(posedge S_hdmi_pixel_clk or negedge S_hdmi_rst_n) begin
        if(!S_hdmi_rst_n) begin
            S_bright_sum <= 28'd0;
            S_bright_status <= 2'b00;
            S_bright_toggle <= 1'b0;
        end
        else if(S_hdmi_user) begin
            if(S_bright_sum < 27'd61440000)
                S_bright_status <= 2'b01;
            else if(S_bright_sum > 27'd98304000)
                S_bright_status <= 2'b10;
            else
                S_bright_status <= 2'b00;
            S_bright_toggle <= ~S_bright_toggle;
            S_bright_sum <= 28'd0;
        end
        else if(S_hdmi_de) begin
            S_bright_sum <= S_bright_sum + {20'd0, S_video_rd_data[15:8]};
        end
    end

    // Synchronize the once-per-frame brightness status into the 24 MHz domain.
    always @(posedge S_24m_clk or negedge S_rst_n) begin
        if(!S_rst_n) begin
            S_bright_status_sync1 <= 2'b00;
            S_bright_status_sync2 <= 2'b00;
            S_toggle_sync1 <= 1'b0;
            S_toggle_sync2 <= 1'b0;
            S_toggle_sync3 <= 1'b0;
        end
        else begin
            S_bright_status_sync1 <= S_bright_status;
            S_bright_status_sync2 <= S_bright_status_sync1;
            S_toggle_sync1 <= S_bright_toggle;
            S_toggle_sync2 <= S_toggle_sync1;
            S_toggle_sync3 <= S_toggle_sync2;
        end
    end
    assign S_frame_tick = S_toggle_sync2 ^ S_toggle_sync3;

    // Inline automatic exposure controller (24 MHz clock domain).
    always @(*) begin
        case(S_bright_status_sync2)
            2'b01: begin
                S_new_ae = (S_ae_auto_r < 16'd3900) ? S_ae_auto_r + 16'd32 : S_ae_auto_r;
                S_new_ag = (S_ag_auto_r < 16'd89)   ? S_ag_auto_r + 16'd1   : S_ag_auto_r;
            end
            2'b10: begin
                S_new_ae = (S_ae_auto_r > 16'd16) ? S_ae_auto_r - 16'd32 : S_ae_auto_r;
                S_new_ag = (S_ag_auto_r > 16'd16) ? S_ag_auto_r - 16'd1   : S_ag_auto_r;
            end
            default: begin
                S_new_ae = S_ae_auto_r;
                S_new_ag = S_ag_auto_r;
            end
        endcase
    end

    always @(posedge S_24m_clk or negedge S_rst_n) begin
        if(!S_rst_n) begin
            S_ae_auto_r <= 16'd3000;
            S_ag_auto_r <= 16'd80;
            S_auto_ae <= 16'd3000;
            S_auto_ag <= 16'd80;
            S_auto_ae_req <= 1'b0;
        end
        else begin
            S_auto_ae_req <= 1'b0;
            if(S_frame_tick) begin
                S_auto_ae <= S_new_ae;
                S_auto_ag <= S_new_ag;
                if((S_new_ae != S_ae_auto_r) || (S_new_ag != S_ag_auto_r))
                    S_auto_ae_req <= 1'b1;
                S_ae_auto_r <= S_new_ae;
                S_ag_auto_r <= S_new_ag;
            end
        end
    end

    always @(posedge S_24m_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_ae_req_led <= 1'b0;
        else if(S_auto_ae_req)
            S_ae_req_led <= ~S_ae_req_led;
    end

    always @(posedge S_24m_clk or negedge S_rst_n) begin
        if(!S_rst_n)
            S_sw_ae_d <= 1'b0;
        else
            S_sw_ae_d <= I_sw_ae;
    end
    wire S_sw_ae_rise = I_sw_ae && !S_sw_ae_d;

    // LED0/LED1: free-running counter (blink ~0.6s / ~0.3s) to verify clock.
    // LED2: SMS sending. LED3: 4G status polling.
    assign O_dbg_led[0] = S_dbg_cnt[25];
    assign O_dbg_led[1] = S_dbg_cnt[24];
    assign O_dbg_led[2] = S_sms_sending;
    assign O_dbg_led[3] = S_lte_polling;

    assign S_ae_sel     = I_sw_ae ? S_auto_ae : S_ae;
    assign S_ag_sel     = I_sw_ae ? S_auto_ag : S_ag;
    assign S_ae_req_sel = I_sw_ae ? (S_auto_ae_req | S_sw_ae_rise) : S_ae_req;
  
    uicfgcs500 #(
      .CLK_DIV(24000000 / 100000 - 1)
  ) u_uicfgcs500 (
      .I_clk(S_24m_clk),  //系统时钟输入
      .I_rst_n(S_rst_n),  //系统复位输入
      .I_ae_req(S_ae_req_sel),
      .I_ae(S_ae_sel),
      .I_ag(S_ag_sel),
      .O_cam_scl(O_cam_scl),  //I2C总线，SCL时钟
      .IO_cam_sda(IO_cam_sda),  //I2C总线，SDA数据
      .O_cfg_done(S_cam_cfg_done),  //摄像头寄存器初始化完成
      .O_ae_cfg_done(S_ae_cfg_done)  //AE配置完成
  );
	
    mipi_dphy_rx_ph1p_mipiio_wrapper#(
        .DPHY_RX_LOCATION      ( "DPHY0" ),
        .HS_EQUALIZER          ( "0dB"   ),//"0dB","1.5dB","3dB","4.5dB","6dB","7.5dB","9dB","10.5dB"
        .HS_VGA_GAIN           ( "8dB" ),//"-3dB","-1.5dB","0dB","1.5dB","3dB","4.5dB","6dB","7.5dB"
        .LANE_NUM              ( 2       ),
        .BYTE_NUM              ( 1       )
    )u_mipi_dphy_rx_ph1p_mipiio_wrapper(
        .I_lp_clk              ( S_100m_clk       ),
        .I_rst                 ( ~S_rst_n         ),

        .I_clk_lane_in_delay   ( 6'd0             ),
        .I_data_lane0_in_delay ( 6'd0             ),
        .I_data_lane1_in_delay ( 6'd0             ),
        .I_data_lane2_in_delay ( 6'd0             ),
        .I_data_lane3_in_delay ( 6'd0             ),

        .I_lane_invert         ( 4'b0000          ),
     
        .O_hs_rx_clk           ( S_csi_rx_clk     ),
        .O_hs_rx_valid         ( S_hs_rx_valid    ),
        .O_hs_rx_data          ( S_hs_rx_data     ),
      
        .O_lp_rx_lane0_p       (  ),
        .O_lp_rx_lane0_n       (  ),
      
        .I_lp_tx_en            ( 1'b0             ),
        .I_lp_tx_lane0_p       ( 1'b1             ),
        .I_lp_tx_lane0_n       ( 1'b1             ),
      
        .O_lane_match_error    (                  ),
        .O_lane_error          ( S_lane_error     ),
      
        .IO_rx_clk_pad_n       ( IO_rx_clk_pad_n  ),
        .IO_rx_clk_pad_p       ( IO_rx_clk_pad_p  ),
        .IO_rx_data_pad_n      ( IO_rx_data_pad_n ),
        .IO_rx_data_pad_p      ( IO_rx_data_pad_p )
    );
	
	
 //  cwc cwc_inst
 //(
 //    .probe0(S_hs_rx_valid),
 //    .probe1(S_hs_rx_data),
 //    .probe2(S_lane_error),
 //    .clk(S_csi_rx_clk)
 //);

 //csi 解码为RAW数据
csi_unpacket_2lane u_csi_unpacket(
.I_clk                 ( S_csi_rx_clk       ),
.I_rst_n               ( S_rst_n        	),
.I_hs_valid            ( S_hs_rx_valid     ),
.I_hs_data             ( S_hs_rx_data      ),

.O_csi_frame_start     ( S_csi_frame_start ),
.O_csi_frame_end       ( S_csi_frame_end   ),
.O_csi_valid           ( S_csi_valid       ),
.O_csi_data            ( S_csi_data        )
);


//解码为RAW8
raw10_unpacket_2lane u_raw10_unpacket (
.I_clk  (S_csi_rx_clk),
.I_rst_n(S_rst_n),

.I_csi_frame_start(S_csi_frame_start),
.I_csi_frame_end  (S_csi_frame_end),
.I_csi_valid      (S_csi_valid),
.I_csi_data       (S_csi_data),

.O_raw10_frame_start(S_raw10_frame_start),
.O_raw10_frame_end  (S_raw10_frame_end),
.O_raw10_valid      (S_raw10_valid),
.O_raw10_data       (S_raw10_data)
  );


//将数据转为stream流
uial2axis #(
.IMG_WIDTH(1024),
.IMG_HEIGHT(600),
.INPUT_DATA_WIDTH(40)
) 
u_uial2axis (
.I_native_clk(S_csi_rx_clk),
.I_rst_n     (S_rst_n),
.I_data      (S_raw10_data       ),
.I_data_valid(S_raw10_valid      ),
.I_data_start(S_raw10_frame_start),
.I_data_end  (S_raw10_frame_end  ),
.axis_tvalid (S_axis_tvalid),
.axis_tdata  (S_axis_tdata ),
.axis_tuser  (S_axis_tuser ),
.axis_tlast  (S_axis_tlast )
);
	

image_correction #(
    .DATA_WIDTH(40)
)(
    .I_clk   		(S_csi_rx_clk),
    .I_rst_n 		(S_rst_n),
					
    .I_raw_data 	(S_axis_tdata),
    .I_raw_frame_end 	(S_axis_tlast),
    .I_raw_valid	(S_axis_tvalid),
    .I_raw_frame_start 	(S_axis_tuser),
					
    .O_raw_tdata 	(S_raw_tdata ),
    .O_raw_tlast 	(S_raw_tlast ),
    .O_raw_tvalid	(S_raw_tvalid),
    .O_raw_tuser 	(S_raw_tuser )
);


//cwc1 cwc1_Inst
//  (
//      .probe0(S_axis_tuser),
//      .probe1(S_axis_tvalid),
//      .probe2(S_axis_tlast),
//      .probe3(S_axis_tdata),
//      .probe4(S_ISP_O_tuser),
//      .probe5(S_ISP_O_tvalid),
//      .probe6(S_ISP_O_tlast),
//      .probe7(S_ISP_O_tdata),
//      .probe8 (S_raw_tdata ),
//      .probe9 (S_raw_tlast ),
//      .probe10(S_raw_tvalid),
//      .probe11(S_raw_tuser ),
//      .clk(S_csi_rx_clk)
//  );


//ISP算法顶层模块
isp_top u_isp_top (
.axi4s_video_aclk(S_csi_rx_clk),
.I_rst_n         (S_rst_n),
.I_tlast         (S_raw_tlast	),
.I_tuser         (S_raw_tuser	),
.I_tdata         (S_raw_tdata	),
.I_tvalid        (S_raw_tvalid	),
.I_tdest         (),
.I_video_mode    (S_video_mode_isp_sync2),
.O_tready        (S_ISP_O_tready),
.O_tdata         (S_ISP_O_tdata ),
.O_tlast         (S_ISP_O_tlast ),
.O_tuser         (S_ISP_O_tuser ),
.O_tvalid        (S_ISP_O_tvalid),
.I_tready        ()
  );


    video_in u_video_in(
        .I_rst_n              (  S_rst_n             ),

        .I_camera_clk         ( S_csi_rx_clk          ),
        .I_camera_frame_start ( S_ISP_O_tuser  ),
        .I_camera_valid       ( S_ISP_O_tvalid ),
        .I_camera_data        ( S_ISP_O_tdata  ),
        .I_mipi_rx_error      ( 1'b0			      ),

        .I_ddr_clk            ( S_ddr_clk             ),
		.I_display_pause      ( 1'b0                  ),
        .I_video_out_rd_busy  ( S_video_out_rd_busy   ),
        .O_video_in_wr_busy   ( S_video_in_wr_busy    ),
        .O_video_out_rp       ( S_video_out_rp        ),

        .O_ddr_user_wr_en     ( S_vi_ddr_wr_en        ),
        .O_ddr_user_addr      ( S_vi_ddr_wr_addr      ),
        .O_ddr_user_wr_data   ( S_vi_ddr_wr_data      ),
        .I_ddr_user_ready     ( S_ddr_user_ready      )
    );



    assign S_ddr_user_wr_en    = S_vi_ddr_wr_en;

    assign S_ddr_user_rd_en    = S_vo_ddr_rd_en;

    assign S_ddr_user_addr     = S_vi_ddr_wr_en ? S_vi_ddr_wr_addr :
                                 S_vo_ddr_rd_en ? S_vo_ddr_rd_addr : 'd0;

    assign S_ddr_user_wr_data  = S_vi_ddr_wr_data;


    assign S_video_out_rst_n = S_hdmi_rst_n;

    video_out u_video_out(
        .I_rst_n             ( S_video_out_rst_n    ),
        .I_ddr_clk           ( S_ddr_clk            ),
 
        .O_video_out_rd_busy ( S_video_out_rd_busy  ),
        .I_video_in_wr_busy  ( S_video_in_wr_busy   ),
        .I_video_out_rp      ( S_video_out_rp       ),
 
        .O_ddr_user_rd_en    ( S_vo_ddr_rd_en       ),
        .O_ddr_user_addr     ( S_vo_ddr_rd_addr     ),
        .I_ddr_user_ready    ( S_ddr_user_ready     ),
        .I_ddr_user_rd_valid ( S_ddr_user_rd_valid  ),
        .I_ddr_user_rd_data  ( S_ddr_user_rd_data   ),

        .I_dsi_clk           ( S_hdmi_pixel_clk     ),
        .I_video_vsync       ( S_video_out_vsync    ),
        .I_video_rd_en       ( S_hdmi_window_rd_en  ),
        .O_vdieo_data        ( S_video_rd_data      )
    );

    mc_to_user_interface u_mc_to_user_interface(
        .I_clk                   ( S_ddr_clk               ),
        .I_rst_n                 ( S_rst_n                 ),

        .I_ddr_user_wr_en        ( S_ddr_user_wr_en        ),
        .I_ddr_user_rd_en        ( S_ddr_user_rd_en        ),
        .I_ddr_user_addr         ( S_ddr_user_addr         ),
        .I_ddr_user_wr_data      ( S_ddr_user_wr_data      ),
        .O_ddr_user_ready        ( S_ddr_user_ready        ),
        .O_ddr_user_rd_valid     ( S_ddr_user_rd_valid     ),
        .O_ddr_user_rd_data      ( S_ddr_user_rd_data      ),
            
        .O_mc_app_en             ( S_mc_app_en             ),
        .O_mc_app_addr           ( S_mc_app_addr           ),
        .O_mc_app_cmd            ( S_mc_app_cmd            ),
        .I_mc_app_rdy            ( S_mc_app_rdy            ),
        .O_mc_app_wdf_wren       ( S_mc_app_wdf_wren       ),
        .O_mc_app_wdf_data       ( S_mc_app_wdf_data       ),
        .O_mc_app_wdf_end        ( S_mc_app_wdf_end        ),
        .O_mc_app_wdf_mask       ( S_mc_app_wdf_mask       ),
        .I_mc_app_wdf_rdy        ( S_mc_app_wdf_rdy        ),
        .I_mc_app_rd_data        ( S_mc_app_rd_data        ),
        .I_mc_app_rd_data_end    ( S_mc_app_rd_data_end    ),
        .I_mc_app_rd_data_valid  ( S_mc_app_rd_data_valid  )
    );



    ph1p35_324_ddr_wrapper u_ph1p35_324_ddr_wrapper(
        .I_sys_clk              ( I_sys_clk              ),
        .I_sys_rst_n            ( S_rst_n                ),

        .O_ddr_clk              ( S_ddr_clk              ),
        .O_init_calib_complete  ( S_init_calib_complete  ),
        .I_mc_app_addr          ( S_mc_app_addr          ),
        .I_mc_app_cmd           ( S_mc_app_cmd           ),
        .I_mc_app_en            ( S_mc_app_en            ),
        .I_mc_app_wdf_data      ( S_mc_app_wdf_data      ),
        .I_mc_app_wdf_end       ( S_mc_app_wdf_end       ),
        .I_mc_app_wdf_mask      ( S_mc_app_wdf_mask      ),
        .I_mc_app_wdf_wren      ( S_mc_app_wdf_wren      ),
        .O_mc_app_rd_data       ( S_mc_app_rd_data       ),
        .O_mc_app_rd_data_end   ( S_mc_app_rd_data_end   ),
        .O_mc_app_rd_data_valid ( S_mc_app_rd_data_valid ),
        .O_mc_app_rdy           ( S_mc_app_rdy           ),
        .O_mc_app_wdf_rdy       ( S_mc_app_wdf_rdy       ),

        .ddr_addr               ( ddr_addr               ),
        .ddr_ba                 ( ddr_ba                 ),
        .ddr_cke                ( ddr_cke                ),
        .ddr_odt                ( ddr_odt                ),
        .ddr_cs_n               ( ddr_cs_n               ),
        .ddr_ras_n              ( ddr_ras_n              ),
        .ddr_cas_n              ( ddr_cas_n              ),
        .ddr_we_n               ( ddr_we_n               ),
        .ddr_ck_p               ( ddr_ck_p               ),
        .ddr_ck_n               ( ddr_ck_n               ),
        .ddr_dm                 ( ddr_dm                 ),
        .ddr_dq                 ( ddr_dq                 ),
        .ddr_dqs_p              ( ddr_dqs_p              ),
        .ddr_dqs_n              ( ddr_dqs_n              )
    );



    uivtc #(
        .H_ActiveSize ( 1024 ),
        .H_FrameSize  ( 1344 ),
        .H_SyncStart  ( 1184 ),
        .H_SyncEnd    ( 1208 ),
        .V_ActiveSize ( 600  ),
        .V_FrameSize  ( 635  ),
        .V_SyncStart  ( 612  ),
        .V_SyncEnd    ( 614  )
    )u_hdmi_vtc(
        .I_vtc_rstn    ( S_hdmi_rst_n    ),
        .I_vtc_clk     ( S_hdmi_pixel_clk ),
        .O_vtc_vs      ( S_hdmi_vsync     ),
        .O_vtc_hs      ( S_hdmi_hsync     ),
        .O_vtc_de_valid( S_hdmi_de        ),
        .O_vtc_user    ( S_hdmi_user      ),
        .O_vtc_last    ( S_hdmi_last      )
    );

    trash_detect #(
        .IMG_WIDTH ( 1024 ),
        .IMG_HEIGHT( 600  ),
        .BLUE_TH   ( 8'd28 ),
        .RED_TH    ( 8'd28 ),
        .GREEN_TH  ( 8'd12 ),
        .MIN_AREA  ( 17'd1200 )
    ) u_trash_detect (
        .I_clk          ( S_hdmi_pixel_clk ),
        .I_rst_n        ( S_hdmi_rst_n     ),
        .I_fstart       ( S_hdmi_user      ),
        .I_de           ( S_hdmi_de        ),
        .I_data         ( S_video_rd_data  ),
        .O_blue_valid   ( S_blue_valid     ),
        .O_blue_x0      ( S_blue_x0        ),
        .O_blue_y0      ( S_blue_y0        ),
        .O_blue_x1      ( S_blue_x1        ),
        .O_blue_y1      ( S_blue_y1        ),
        .O_red_valid    ( S_red_valid      ),
        .O_red_x0       ( S_red_x0         ),
        .O_red_y0       ( S_red_y0         ),
        .O_red_x1       ( S_red_x1         ),
        .O_red_y1       ( S_red_y1         ),
        .O_green_valid  ( S_green_valid    ),
        .O_green_x0     ( S_green_x0       ),
        .O_green_y0     ( S_green_y0       ),
        .O_green_x1     ( S_green_x1       ),
        .O_green_y1     ( S_green_y1       )
    );

    target_tracker #(
        .LOST_TH ( 8'd10 )
    ) u_target_tracker (
        .I_clk          ( S_hdmi_pixel_clk ),
        .I_rst_n        ( S_hdmi_rst_n     ),
        .I_fstart       ( S_hdmi_user      ),
        .I_blue_valid   ( S_blue_valid     ),
        .I_blue_x0      ( S_blue_x0        ),
        .I_blue_y0      ( S_blue_y0        ),
        .I_blue_x1      ( S_blue_x1        ),
        .I_blue_y1      ( S_blue_y1        ),
        .I_red_valid    ( S_red_valid      ),
        .I_red_x0       ( S_red_x0         ),
        .I_red_y0       ( S_red_y0         ),
        .I_red_x1       ( S_red_x1         ),
        .I_red_y1       ( S_red_y1         ),
        .I_green_valid  ( S_green_valid    ),
        .I_green_x0     ( S_green_x0       ),
        .I_green_y0     ( S_green_y0       ),
        .I_green_x1     ( S_green_x1       ),
        .I_green_y1     ( S_green_y1       ),
        .O_blue_valid   ( S_track_blue_valid  ),
        .O_blue_x0      ( S_track_blue_x0     ),
        .O_blue_y0      ( S_track_blue_y0     ),
        .O_blue_x1      ( S_track_blue_x1     ),
        .O_blue_y1      ( S_track_blue_y1     ),
        .O_blue_cx      ( S_track_blue_cx     ),
        .O_blue_cy      ( S_track_blue_cy     ),
        .O_red_valid    ( S_track_red_valid   ),
        .O_red_x0       ( S_track_red_x0      ),
        .O_red_y0       ( S_track_red_y0      ),
        .O_red_x1       ( S_track_red_x1      ),
        .O_red_y1       ( S_track_red_y1      ),
        .O_red_cx       ( S_track_red_cx      ),
        .O_red_cy       ( S_track_red_cy      ),
        .O_green_valid  ( S_track_green_valid ),
        .O_green_x0     ( S_track_green_x0    ),
        .O_green_y0     ( S_track_green_y0    ),
        .O_green_x1     ( S_track_green_x1    ),
        .O_green_y1     ( S_track_green_y1    ),
        .O_green_cx     ( S_track_green_cx    ),
        .O_green_cy     ( S_track_green_cy    )
    );

    motion_detect #(
        .IMG_WIDTH  ( 1024 ),
        .IMG_HEIGHT ( 600  ),
        .BLOCK      ( 32   ),
        .MOTION_TH  ( 18'd12000 ),
        .MIN_AREA   ( 17'd1 )
    ) u_motion_detect (
        .I_clk          ( S_hdmi_pixel_clk ),
        .I_rst_n        ( S_hdmi_rst_n     ),
        .I_fstart       ( S_hdmi_user      ),
        .I_de           ( S_hdmi_de        ),
        .I_data         ( S_video_rd_data  ),
        .O_motion_valid ( S_motion_valid   ),
        .O_box_x0       ( S_motion_x0      ),
        .O_box_y0       ( S_motion_y0      ),
        .O_box_x1       ( S_motion_x1      ),
        .O_box_y1       ( S_motion_y1      )
    );

    hdmi_mixer #(
        .H_OFFSET   ( 0    ),
        .V_OFFSET   ( 0    ),
        .IMG_WIDTH  ( 1024 ),
        .IMG_HEIGHT ( 600  ),
        .DEBUG_MODE ( 0    )
    )u_hdmi_mixer(
        .I_clk           ( S_hdmi_pixel_clk   ),
        .I_rst_n         ( S_hdmi_rst_n       ),
        .I_video_vsync   ( S_hdmi_vsync       ),
        .I_video_hsync   ( S_hdmi_hsync       ),
        .I_video_de      ( S_hdmi_de          ),
        .I_video_user    ( S_hdmi_user        ),
        .I_video_last    ( S_hdmi_last        ),
        .I_debug_status  ( S_hdmi_debug_status),
        .I_video_mode    ( S_video_mode_hdmi_sync2 ),
        .I_blue_valid    ( S_track_blue_valid  ),
        .I_blue_x0       ( S_track_blue_x0     ),
        .I_blue_y0       ( S_track_blue_y0     ),
        .I_blue_x1       ( S_track_blue_x1     ),
        .I_blue_y1       ( S_track_blue_y1     ),
        .I_red_valid     ( S_track_red_valid   ),
        .I_red_x0        ( S_track_red_x0      ),
        .I_red_y0        ( S_track_red_y0      ),
        .I_red_x1        ( S_track_red_x1      ),
        .I_red_y1        ( S_track_red_y1      ),
        .I_green_valid   ( S_track_green_valid ),
        .I_green_x0      ( S_track_green_x0    ),
        .I_green_y0      ( S_track_green_y0    ),
        .I_green_x1      ( S_track_green_x1    ),
        .I_green_y1      ( S_track_green_y1    ),
        .I_blue_cx       ( S_track_blue_cx     ),
        .I_blue_cy       ( S_track_blue_cy     ),
        .I_red_cx        ( S_track_red_cx      ),
        .I_red_cy        ( S_track_red_cy      ),
        .I_green_cx      ( S_track_green_cx    ),
        .I_green_cy      ( S_track_green_cy    ),
        .I_auto_ae_on    ( S_auto_ae_on_hdmi_sync2 ),
        .I_motion_track_on ( S_motion_on_hdmi_sync2 ),
        .I_motion_valid  ( S_motion_valid_held ),
        .I_motion_x0     ( S_motion_x0         ),
        .I_motion_y0     ( S_motion_y0         ),
        .I_motion_x1     ( S_motion_x1         ),
        .I_motion_y1     ( S_motion_y1         ),
        .I_latency_frames( S_latency_frames    ),
        .I_lte_ok        ( S_lte_ok            ),
        .O_video_rd_en   ( S_hdmi_window_rd_en),
        .I_video_rd_data ( S_video_rd_data    ),
        .O_hdmi_vsync    ( S_hdmi_out_vsync   ),
        .O_hdmi_hsync    ( S_hdmi_out_hsync   ),
        .O_hdmi_de       ( S_hdmi_out_de      ),
        .O_hdmi_data     ( S_hdmi_out_data    )
    );

    hdmi_tx u_hdmi_tx(
        .I_pixel_clk        ( S_hdmi_pixel_clk  ),
        .I_serial_clk       ( S_hdmi_serial_clk ),
        .I_rst              ( ~S_hdmi_rst_n     ),
        .I_key_in           ( 1'b0              ),
        .I_edid_read_trig   ( 1'b0              ),
        .O_edid_read_valid  (                   ),
        .O_edid_read_data   (                   ),
        .I_video_rgb_enable ( 1'b1              ),
        .I_video_in_vs      ( S_hdmi_out_vsync  ),
        .I_video_in_de      ( S_hdmi_out_de     ),
        .I_video_in_user    ( 1'b0              ),
        .I_video_in_valid   ( 1'b0              ),
        .I_video_in_last    ( 1'b0              ),
        .O_video_in_ready   (                   ),
        .I_video_in_data    ( S_hdmi_out_data   ),
        .I_audio_valid      ( 1'b0              ),
        .I_audio_left_data  ( 24'd0             ),
        .I_audio_right_data ( 24'd0             ),
        .I_i2s_BCLK         ( 1'b0              ),
        .I_i2s_LRCK         ( 1'b0              ),
        .I_i2s_DOUT         ( 1'b0              ),
        .O_ddc_scl          (                   ),
        .O_hdmi_clk_p       (                   ),
        .O_hdmi_tx_p        (                   ),
        .O_tmds_ch0_p       ( O_tmds_ch0_p      ),
        .O_tmds_ch1_p       ( O_tmds_ch1_p      ),
        .O_tmds_ch2_p       ( O_tmds_ch2_p      ),
        .O_tmds_clk_p       ( O_tmds_clk_p      )
    );

    // SMS alert path: when a red trash can is detected while moving, send the
    // preconfigured AT command sequence to the C100m 4G module over UART.
    // The module reset line is held low for now; wire it to a reset pulse
    // controller later if remote recovery is needed.
    assign O_4g_rst = 1'b0;

    sms_sender u_sms_sender (
        .I_clk     ( S_hdmi_pixel_clk ),
        .I_rst_n   ( S_hdmi_rst_n     ),
        .I_trig    ( S_buzzer_cond    ),
        .I_uart_rx ( I_uart_rx        ),
        .O_uart_tx ( S_sms_tx         ),
        .O_sending ( S_sms_sending    )
    );

    lte_status u_lte_status (
        .I_clk      ( S_hdmi_pixel_clk ),
        .I_rst_n    ( S_hdmi_rst_n     ),
        .I_rx       ( I_uart_rx        ),
        .I_tx_busy  ( S_sms_sending    ),
        .O_tx       ( S_lte_tx         ),
        .O_lte_ok   ( S_lte_ok         ),
        .O_polling  ( S_lte_polling    )
    );

    // Shared UART TX: SMS sender wins the line while it is sending; otherwise
    // the 4G status poller drives it.
    assign O_uart_tx = S_sms_sending ? S_sms_tx : S_lte_tx;


    
endmodule
