//高斯滤波
module	gauss_filter
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

	output	wire			gauss_filter_vs	,
	output	wire			gauss_filter_de	,
	output	wire	[7:0]   gauss_filter_data	

);
/*
高斯核
| 1 2 1 |
| 2 4 2 |         sum高斯核 = 16  ->   sum/16=sum>>4
| 1 2 1 |
*/

/************************************************************
step1 每行相加	delay:1clk
************************************************************/
reg	[11:0]	line1_sum;
reg	[11:0]	line2_sum;
reg	[11:0]	line3_sum;
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		line1_sum	<=	12'd0;
        line2_sum	<=	12'd0;
        line3_sum	<=	12'd0;	
	end
	else	if(matrix_de)
	begin
		line1_sum	<=	matrix11 + matrix12*2 + matrix13	;
        line2_sum	<=	matrix21*2 + matrix22*4 + matrix23*2	;
        line3_sum	<=	matrix31 + matrix32*2 + matrix33	;
	end
	else
	begin
		line1_sum	<=	12'd0;
        line2_sum	<=	12'd0;
        line3_sum	<=	12'd0;	
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
step3 右移4位 delay:1clk
************************************************************/
//移位实现/16
reg	[7:0]	gauss_filter_reg	;	//均值

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		gauss_filter_reg	<=	8'd0;
	else
		gauss_filter_reg	<=	data_sum[11:4];	//
end


/************************************************************
时钟延迟 一共延迟 3clk
************************************************************/
reg	[2:0]	video_de_reg;
reg	[2:0]	video_vs_reg;

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		video_de_reg	<=	3'd0;
        video_vs_reg	<=	3'd0;
	end
	else
	begin
		video_de_reg	<=	{video_de_reg[1:0],matrix_de};
        video_vs_reg	<=	{video_vs_reg[1:0],matrix_vs};
	end
end

assign	gauss_filter_vs		= 	video_vs_reg[2]	;
assign	gauss_filter_de		= 	video_de_reg[2]	;
assign	gauss_filter_data	=	gauss_filter_reg	;	


endmodule