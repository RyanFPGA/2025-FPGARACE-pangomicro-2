//dilate 膨胀
module	dilate
(
	input	wire			video_clk	,	//像素时钟
	input	wire			rst_n		,
	
	//输入二值化数据
	input	wire			bin_vs		,
	input	wire			bin_de		,
	input	wire			bin_data_11	,
	input	wire			bin_data_12	,
	input	wire			bin_data_13	,
	input	wire			bin_data_21	,
	input	wire			bin_data_22	,
	input	wire			bin_data_23	,
	input	wire			bin_data_31	,
	input	wire			bin_data_32	,
	input	wire			bin_data_33	,

	output	wire			dilate_vs	,
	output	wire			dilate_de	,
	output	wire			dilate_data	

);

/**********************************************************
wire define
**********************************************************/


/**********************************************************
reg define
**********************************************************/
reg	dilate_vs_d	;	
reg	dilate_vs_d1	;	
reg	dilate_de_d	;
reg	dilate_de_d1	;
reg	dilate_data_d	;
reg dilate_line0   ;
reg dilate_line1   ;
reg dilate_line2   ;
// 1clk  行膨胀 相或
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
    begin
         dilate_line0    <=    1'd0;
         dilate_line1    <=    1'd0;
         dilate_line2    <=    1'd0;
    end
    else    if(bin_de)
    begin
        dilate_line0    <=    bin_data_11 || bin_data_12 || bin_data_13;
        dilate_line1    <=    bin_data_21 || bin_data_22 || bin_data_23;
        dilate_line2    <=    bin_data_31 || bin_data_32 || bin_data_33;
    end
end

// 1clk  膨胀 相或
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		dilate_data_d	<=	1'd0;
    else
		dilate_data_d	<=	dilate_line0 || dilate_line1 || dilate_line2;
end



// 延迟2clk
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin	
		dilate_vs_d	<=	1'd0;
        dilate_vs_d1   <=  1'd0;  
        dilate_de_d	<=	1'd0;
        dilate_de_d1   <=  1'd0;
         
	end
	else
	begin	
		dilate_vs_d		<=	bin_vs;
        dilate_vs_d1    <=  dilate_vs_d; 
        dilate_de_d		<=	bin_de;
        dilate_de_d1   	<=  dilate_de_d;    
	end
end
assign 	dilate_data 	= dilate_data_d;
						  
assign	dilate_vs		= dilate_vs_d1	;	
assign  dilate_de		= dilate_de_d1	;

endmodule