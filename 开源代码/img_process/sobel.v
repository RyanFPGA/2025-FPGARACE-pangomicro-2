//不开方根 3clk
module	sobel  
#(
	parameter	SOBEL_THRESHOLD = 28
)
(
	input		wire				video_clk		,
	input		wire				rst_n			,
		
	//矩阵数据输入	
	input		wire				matrix_de		,
	input		wire				matrix_vs		,
	input		wire	[7:0]		matrix11 		,	
	input		wire	[7:0]   	matrix12 		,
	input		wire	[7:0]   	matrix13 		,
			
	input		wire	[7:0]		matrix21 		,
	input		wire	[7:0]   	matrix22 		,
	input		wire	[7:0]   	matrix23 		,
													
	input		wire	[7:0]		matrix31 		,
	input		wire	[7:0]   	matrix32 		,
	input		wire	[7:0]   	matrix33 		,	
	//sobel数据输出
	output		wire				sobel_vs		,
	output		wire				sobel_de		,
	output		wire	[7:0]		sobel_data


);



/****************************************************************
%      -1   0  +1    %      +1   2  +1
% gx = -2   0  +2    % gy =  0   0  0
%      -1   0  +1    %      -1  -2  -1
****************************************************************/

/****************************************************************
wire define
****************************************************************/



/****************************************************************
reg define
****************************************************************/
reg	[9:0]	gx_temp1;
reg	[9:0]	gx_temp2;
reg	[9:0]	gy_temp1;
reg	[9:0]	gy_temp2;



/****************************************************************
step1 计算卷积
****************************************************************/
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		gx_temp1	<=	9'd0;
        gx_temp2	<=	9'd0;
	end
	else	if(matrix_de)
	begin
		gx_temp1	<=	matrix13 + 2*matrix23 + matrix33;
		gx_temp2	<=	matrix11 + 2*matrix21 + matrix31;
	end
	else
	begin
		gx_temp1	<=	9'd0;
        gx_temp2	<=	9'd0;
	end
end

	
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		gy_temp1	<=	9'd0;
        gy_temp2	<=	9'd0;
	end
	else	if(matrix_de)
	begin
		gy_temp1	<=	matrix13 + 2*matrix23 + matrix33;
		gy_temp2	<=	matrix11 + 2*matrix21 + matrix31;
	end
	else
	begin
		gy_temp1	<=	9'd0;
        gy_temp2	<=	9'd0;
	end
end

/****************************************************************
step2 求卷积和
****************************************************************/
reg	[9:0]	gx_data;
reg	[9:0]	gy_data;
	
	
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		gx_data	<=	10'd0;
	else	if(gx_temp1 >= gx_temp2)
		gx_data	<=	gx_temp1 - gx_temp2;
	else
		gx_data	<=	gx_temp2 - gx_temp1;
end

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		gy_data	<=	10'd0;
	else	if(gy_temp1 >= gy_temp2)
		gy_data	<=	gy_temp1 - gy_temp2;
	else
		gy_data	<=	gy_temp2 - gy_temp1;
end
	
/****************************************************************
step3 绝对值相加   
****************************************************************/
reg	[10:0]	sobel_data_reg;

always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		sobel_data_reg	<=	11'd0;
	else
		sobel_data_reg	<=	gx_data + gy_data;
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

assign	sobel_vs		= 	video_vs_reg[2]			;
assign	sobel_de		= 	video_de_reg[2]			;
assign	sobel_data		=	(sobel_data_reg>=SOBEL_THRESHOLD)?8'd255:8'd0	;	

endmodule