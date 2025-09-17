//均值滤波
module	aver_filter
(
	input	wire			video_clk		/*synthesis PAP_MARK_DEBUG="1"*/,
	input	wire			rst_n			,
		
	//矩阵数据输入	
	input	wire			matrix_de		/*synthesis PAP_MARK_DEBUG="1"*/,
	input	wire			matrix_vs		/*synthesis PAP_MARK_DEBUG="1"*/,
	input	wire	[7:0]	matrix11 		,	
	input	wire	[7:0]   matrix12 		,
	input	wire	[7:0]   matrix13 		,
	
	input	wire	[7:0]	matrix21 		,
	input	wire	[7:0]   matrix22 		,
	input	wire	[7:0]   matrix23 		,
											
	input	wire	[7:0]	matrix31 		,
	input	wire	[7:0]   matrix32 		,
	input	wire	[7:0]   matrix33 		,

	output	wire			aver_filter_vs	,
	output	wire			aver_filter_de	,
	output	wire	[7:0]   aver_filter_data	

);

/************************************************************
step1 每行相加	delay:1clk
************************************************************/
reg	[18:0]	line1_sum;
reg	[18:0]	line2_sum;
reg	[18:0]	line3_sum;
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		line1_sum	<=	10'd0;
        line2_sum	<=	10'd0;
        line3_sum	<=	10'd0;	
	end
	else	if(matrix_de)
	begin
		line1_sum	<=	matrix11 + matrix12 + matrix13	;
        line2_sum	<=	matrix21 + matrix22 + matrix23	;
        line3_sum	<=	matrix31 + matrix32 + matrix33	;
	end
	else
	begin
		line1_sum	<=	10'd0;
        line2_sum	<=	10'd0;
        line3_sum	<=	10'd0;	
	end
end

/************************************************************
step2 矩阵总和 delay:1clk
************************************************************/
reg	[18:0]	data_sum;
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		data_sum	<=	12'd0;
	else
		data_sum	<=	line1_sum + line2_sum + line3_sum;
end

/************************************************************
step3 求均值 /9 delay:1clk
************************************************************/
//除法转乘法   *228>>11
reg	[18:0]	aver_filter_mux	;	//均值

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		aver_filter_mux	<=	19'd0;
	else
		aver_filter_mux	<=	data_sum * 228;	//后续要>>11
end



/************************************************************
step4 中心像素点与阈值进行比较   delay:1clk
************************************************************/
reg	[7:0]	aver_filter_reg;
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		aver_filter_reg	<=	1'd0;
	else
		aver_filter_reg	<=	aver_filter_mux[18:11];	
end




/************************************************************
时钟延迟 一共延迟 4clk
************************************************************/
reg	[3:0]	video_de_reg;
reg	[3:0]	video_vs_reg;

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		video_de_reg	<=	4'd0;
        video_vs_reg	<=	4'd0;
	end
	else
	begin
		video_de_reg	<=	{video_de_reg[2:0],matrix_de};
        video_vs_reg	<=	{video_vs_reg[2:0],matrix_vs};
	end
end

assign	aver_filter_vs		= 	video_vs_reg[3]	;
assign	aver_filter_de		= 	video_de_reg[3]	;
assign	aver_filter_data	=	aver_filter_reg	;	




endmodule