//3x3矩阵生成
module	matrix_3x3_1bit
#(
	parameter	IMG_WIDTH	=	11'd1920	,
	parameter	IMG_HEIGHT	=	11'd1080	
)
(
	input	wire			video_clk		,
	input	wire			rst_n			,
		
	//	
	input	wire			video_vs		,
	input	wire			video_de		,
	input	wire			video_data		,
	
	//3x3矩阵输出	
	output	wire			matrix_de		,			
	output  reg 			matrix11		,	
	output  reg 		    matrix12		,
	output  reg 		    matrix13		,
						
	output  reg 			matrix21		,
	output  reg 		    matrix22		,
	output  reg 		    matrix23		,
						
	output  reg 			matrix31		,
	output  reg 		    matrix32		,
	output  reg 		    matrix33		


);

/**********************************************************
wire define
**********************************************************/
wire			line3_data;	//第三行数据
wire			line2_data;	//第二行数据
wire			line1_data;	//第一行数据

wire			wr_fifo_en;	//写FIFO使能	
wire			rd_fifo_en;	//读FIFO使能
/**********************************************************
reg define
**********************************************************/
reg	[11:0]	x_cnt;
reg	[11:0]	y_cnt;

//列计数
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		x_cnt	<=	11'd0;
	else	if(x_cnt == IMG_WIDTH - 1)//计数一行
		x_cnt	<=	11'd0;
	else	if(video_de)	//数据有效
		x_cnt	<=	x_cnt + 1'b1;
	else
		x_cnt	<=	x_cnt;
end

//行计数
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		y_cnt	<=	11'd0;
	else	if(y_cnt == IMG_HEIGHT - 1 && x_cnt == IMG_WIDTH - 1)//计数一帧
		y_cnt	<=	11'd0;
	else	if(x_cnt == IMG_WIDTH - 1)	//数据有效
		y_cnt	<=	y_cnt + 1'b1;
	else
		y_cnt	<=	y_cnt;
end

//3x3矩阵 第一行和最后一行无法构成
assign wr_fifo_en = video_de && (y_cnt < IMG_HEIGHT-1);
assign rd_fifo_en = video_de && (y_cnt > 0);
//延迟1clk
reg    wr_fifo_en_1d;
reg    video_data_1d;
always@(posedge video_clk or negedge rst_n)	begin
    if(!rst_n)
    begin
        wr_fifo_en_1d    <=    1'd0;
        video_data_1d    <=    1'd0;
    end
    else
    begin
	    wr_fifo_en_1d <= wr_fifo_en;
        video_data_1d <= video_data;
    end
end

//通过两个FIFO与当前的输入一起构成3x3矩阵
assign line3_data = video_data_1d;


//fifo1
fifo_line_buf_1bit fifo_line_buf_1bit1 (
  .wr_clk(video_clk),                // input
  .wr_rst(~rst_n),                // input
  .wr_en(wr_fifo_en),                  // input
  .wr_data(line3_data),              // input [0:0]
  .wr_full(),              // output
  .almost_full(),      // output
  
  .rd_clk(video_clk),                // input
  .rd_rst(~rst_n),                // input
  .rd_en(rd_fifo_en),                  // input
  .rd_data(line2_data),              // output [0:0]
  .rd_empty(u1_empty),            // output
  .almost_empty()     // output
);
//fifo2
fifo_line_buf_1bit fifo_line_buf_1bit2 (
  .wr_clk(video_clk),                // input
  .wr_rst(~rst_n),                // input
  .wr_en(wr_fifo_en_1d),                  // input
  .wr_data(line2_data),              // input [0:0]
  .wr_full(),              // output
  .almost_full(),      // output
  
  .rd_clk(video_clk),                // input
  .rd_rst(~rst_n),                // input
  .rd_en(rd_fifo_en),                  // input
  .rd_data(line1_data),              // output [0:0]
  .rd_empty(),            // output
  .almost_empty()     // output
);

//矩阵数据生成
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		{matrix11, matrix12, matrix13} <= 3'd0;
		{matrix21, matrix22, matrix23} <= 3'd0;
		{matrix31, matrix32, matrix33} <= 3'd0;
	end
	else	if(video_de_d0)
	begin
		{matrix11, matrix12, matrix13} <= {matrix12, matrix13, line1_data};
		{matrix21, matrix22, matrix23} <= {matrix22, matrix23, line2_data};
		{matrix31, matrix32, matrix33} <= {matrix32, matrix33, line3_data};
	end
	else
	begin
		{matrix11, matrix12, matrix13} <= 3'd0;
		{matrix21, matrix22, matrix23} <= 3'd0;
		{matrix31, matrix32, matrix33} <= 3'd0;
	end
end
	

//数据延迟 de延迟  vs可以不管
reg	video_de_d0;
reg	video_de_d1;
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin
		video_de_d0	<=	1'd0;
		video_de_d1	<=	1'd0;
	end
	else
	begin
		video_de_d0	<=	video_de;
		video_de_d1	<=	video_de_d0;
	end
end

//矩阵数据有效输出
assign matrix_de = video_de_d1;

endmodule