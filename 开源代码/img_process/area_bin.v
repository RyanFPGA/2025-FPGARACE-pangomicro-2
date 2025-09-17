//局部二值化
module	area_bin
(
	input	wire			video_clk		,
	input	wire			rst_n			,
		
	//矩阵数据输入	
	input	wire			matrix_de		,
	input	wire			matrix_vs		,
	input	wire	[7:0]	matrix11 		,	
	input	wire	[7:0]   matrix12 		,
	input	wire	[7:0]   matrix13 		,
	
	input	wire	[7:0]	matrix21 		,
	input	wire	[7:0]   matrix22 		,
	input	wire	[7:0]   matrix23 		,
											
	input	wire	[7:0]	matrix31 		,
	input	wire	[7:0]   matrix32 		,
	input	wire	[7:0]   matrix33 		,

	output	wire			area_bin_vs		,
	output	wire			area_bin_de		,
	output	wire			area_bin_data	

);

/************************************************************
step1 每行相加	delay:1clk
************************************************************/
reg	[9:0]	line1_sum;
reg	[9:0]	line2_sum;
reg	[9:0]	line3_sum;
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
reg	[11:0]	data_sum;
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		data_sum	<=	12'd0;
	else
		data_sum	<=	line1_sum + line2_sum + line3_sum;
end

/************************************************************
step3 求均值 /9 delay:1clk
************************************************************/
//除法转乘法   *113>>10
reg	[17:0]	thre_data	;	//均值当作阈值

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		thre_data	<=	18'd0;
	else
		thre_data	<=	data_sum * 113;	//后续要>>10
end



/************************************************************
step4 中心像素点与阈值进行比较   delay:1clk
************************************************************/
reg	bin_data;
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		bin_data	<=	1'd0;
	else	if(matrix22 >= thre_data[17:10])
		bin_data	<=	1'd1;	
	else
		bin_data	<=	1'd0;
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

assign	area_bin_de 	= 	video_de_reg[3]	;
assign	area_bin_vs 	= 	video_vs_reg[3]	;
assign	area_bin_data	=	bin_data		;	




endmodule