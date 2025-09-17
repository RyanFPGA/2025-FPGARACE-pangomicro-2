//图像处理仿真模块
//后续的图像处理都基于该平台
`timescale 1ns/1ns
module	img_process_tb();

//图片高度宽度 
//仿真需要改小视频大小 避免太大

//时序参考模板  仿真中不需要严格按照vesa时序标准
parameter IMG_WIDTH = 16'd1280;//有效区域           
parameter H_FP = 16'd110;    //前沿            
parameter H_SYNC = 16'd40;   //同步            
parameter H_BP = 16'd220 ;   //后沿
parameter TOTAL_WIDTH = IMG_WIDTH  + H_FP  +H_SYNC + H_BP; 
  
parameter IMG_HEIGHT = 16'd720; //有效区域           
parameter V_FP  = 16'd5;      //前沿               
parameter V_SYNC  = 16'd5;    //同步               
parameter V_BP  = 16'd20;     //后沿           
parameter TOTAL_HEIGHT = IMG_HEIGHT + V_FP + + V_SYNC + V_BP;            

localparam	HREF_DELAY	=	5;
localparam	VSYNC_DELAY	=	5;

reg	video_clk	;
reg	rst_n		;


wire			video_vs;
wire			video_de;
wire	[23:0]	video_data;

//定义处理后的文件
integer	output_file;
initial
begin
	video_clk	=	1'd0;
	rst_n		=	1'd0;
	#20
	rst_n		=	1'd1;
	output_file	=	$fopen("D:/2L676demo/img_sim_prj/img_sim_prj/sim/img_process.txt","w");
end
//生成 100MHZ
always#5 video_clk = ~video_clk;

//读取图片数据

video_data_gen#(
    .DATA_WIDTH   ( 24          ),
    .TOTAL_WIDTH  ( TOTAL_WIDTH ),
    .IMG_WIDTH    ( IMG_WIDTH   ),
    .H_SYNC       ( H_SYNC      ),
    .H_BP         ( H_BP        ),
    .H_FP         ( H_FP        ),
    .TOTAL_HEIGHT ( TOTAL_HEIGHT),
    .IMG_HEIGHT   ( IMG_HEIGHT  ),
    .V_SYNC       ( V_SYNC      ),
    .V_BP         ( V_BP        ),
    .V_FP         ( V_FP        )
)u_video_data_gen (
    .video_clk    ( video_clk    ),
    .rst_n        ( rst_n        ),
    .video_vs     ( video_vs     ),
    .video_de     ( video_de     ),
    .video_data   ( video_data   )
);


GTP_GRS GRS_INST(
    .GRS_N(1'b1)
    ) ;



//写数据
reg	video_vs_d	;	//打拍寄存
reg	img_done	;	
wire    frame_flag;


always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		video_vs_d	<=	1'd0;
	else
		video_vs_d	<=	video_vs;
end

assign frame_flag = ~video_vs & video_vs_d;    //下降沿

reg    [7:0]    img_done_cnt    ;

//备用 用来第二帧再写入
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
        img_done_cnt    <=    8'd0;
	else if(frame_flag)    //下降沿 判断一帧结束
		img_done_cnt <= img_done_cnt + 1'b1;
	else
		img_done_cnt <= img_done_cnt;
end


always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		img_done <= 1'b0;
	else if(frame_flag)    //下降沿 判断一帧结束
		img_done <= 1'b1;
	else
		img_done <= img_done;
end


always@(posedge video_clk or negedge rst_n)	begin
	if(img_done)
	begin
        $display("finish to write img in txt!");
		$stop;    //停止仿真
	end  	
	else if(video_de)    //写入数据
	begin
		$fdisplay(output_file,"%h\t%h\t%h",video_data[23:16],video_data[15:8],video_data[7:0]);    //16进制写入  
	end
end

endmodule