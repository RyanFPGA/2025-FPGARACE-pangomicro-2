//仿真使用，用来读取图片数据
//读取彩色图像
//默认1280*720 @60hz
module	video_data_gen
#(
	//同步+后沿+有效+前沿 = 总
    parameter   DATA_WIDTH      =   8           , 
	parameter	TOTAL_WIDTH		=	12'd1650	,	//总宽度
	parameter	IMG_WIDTH		=	12'd1280	,	//有效宽度
	parameter	H_SYNC			=	12'd40		,	//同步
	parameter	H_BP			=	12'd220		,	//后沿
	parameter	H_FP			=	12'd110		,	//前沿
	
	parameter	TOTAL_HEIGHT	=	12'd750		,	//总高度
	parameter	IMG_HEIGHT		=	12'd720		,	//有效高度
	parameter	V_SYNC			=	12'd5		,	//同步
	parameter	V_BP			=	12'd20		,	//后沿
	parameter	V_FP			=	12'd5			//前沿
)
(
	input	wire			        video_clk	,    //50MHZ 100MHZ
	input	wire			        rst_n		,
		                            
	//输出	                        
	output	wire			        video_vs	,    //场同步信号 低电平有效
	output	wire			        video_de	,
	output	wire	[DATA_WIDTH-1:0]	video_data	

);
//存放图像数据的数组  默认640*480 避免仿真过长   1280*720
reg	[DATA_WIDTH-1:0]	img_data_reg	[IMG_WIDTH*IMG_HEIGHT];

integer i;
//读取图像数据
initial
begin
	$readmemh("D:/2L676demo/img_sim_prj/img_sim_prj/sim/img.txt",img_data_reg);
end

//统计一帧图片 包括行场同步信号这些  只要 不超过总的行场就行
reg	[11:0]	x_cnt;
reg	[11:0]	y_cnt;

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		x_cnt	<=	12'd0;
		y_cnt	<=	12'd0;
	end
	else	if(x_cnt == TOTAL_WIDTH-1 && y_cnt == TOTAL_HEIGHT-1)	//一帧
	begin
		x_cnt	<=	12'd0;
		y_cnt	<=	12'd0;		
	end
	else	if(x_cnt == TOTAL_WIDTH-1)
	begin
		x_cnt	<=	12'd0;
		y_cnt	<=	y_cnt + 1'b1;		
	end
	else
		x_cnt	<=	x_cnt + 1'b1;
end

//输出有行场信号 和有效信号  随便取一个数都行

reg	video_vs_d;
reg	video_hs_d;
//video_vs_d的上升沿就是一帧的开始   下降沿就是一帧结束 
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		video_vs_d	<=	1'd0;
	else	if(y_cnt > (V_SYNC - 1) && y_cnt <= (V_SYNC+V_BP+IMG_HEIGHT+V_FP- 1))
		video_vs_d	<=	1'd1;
	else
		video_vs_d	<=	1'd0;
end


always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		video_hs_d	<=	1'd0;
	else	if(x_cnt > (H_SYNC - 1) && x_cnt <=  (H_SYNC+H_BP+IMG_WIDTH+H_FP - 1))
		video_hs_d	<=	1'd1;
	else
		video_hs_d	<=	1'd0;
end


wire    video_de_d;//有效信号
assign  video_de_d = (x_cnt > (H_SYNC+H_BP - 1) && x_cnt <=  (H_SYNC+H_BP+IMG_WIDTH - 1) && y_cnt > (V_SYNC+V_BP-1) && y_cnt <= (V_SYNC+V_BP+IMG_HEIGHT-1))?1'b1:1'b0;

//数组坐标计数
reg	[31:0]	img_index;    ///数组的索引

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		img_index	<=	32'd0;
	else	if(img_index == IMG_WIDTH*IMG_HEIGHT - 1)    //读完一帧
		img_index	<=	32'd0;
	else	if(video_de_d)
		img_index	<=	img_index + 1'b1;
	else
		img_index	<=	img_index;
end


//图像数据读出
reg	[DATA_WIDTH-1:0]	video_data_reg;
always@(posedge video_clk or negedge rst_n)	begin
	if(video_de_d)    //当读数据有效
		video_data_reg	<=	img_data_reg[img_index];
	else
		video_data_reg	<=	'd0;
end
//数据延迟video_de_d一个clk
reg	video_de_delay;

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		video_de_delay	<=	1'd0;
	else
		video_de_delay	<=	video_de_d;
end

assign video_vs  = video_vs_d		;
assign video_de  = video_de_delay	;
assign video_data= video_data_reg	;


endmodule