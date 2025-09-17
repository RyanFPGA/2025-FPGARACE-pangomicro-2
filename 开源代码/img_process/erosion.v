//erosion 腐蚀
module	erosion
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

	output	wire			erosion_vs	,
	output	wire			erosion_de	,
	output	wire			erosion_data	

);

/**********************************************************
wire define
**********************************************************/


/**********************************************************
reg define
**********************************************************/
reg	erosion_vs_d	;	
reg	erosion_vs_d1	;	
reg	erosion_de_d	;
reg	erosion_de_d1	;
reg	erosion_data_d	;
reg erosion_line0   ;
reg erosion_line1   ;
reg erosion_line2   ;
// 1clk  行腐蚀 相与
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
    begin
         erosion_line0    <=    1'd0;
         erosion_line1    <=    1'd0;
         erosion_line2    <=    1'd0;
    end
    else    if(bin_de)
    begin
         erosion_line0    <=    bin_data_11 && bin_data_12 && bin_data_13;
         erosion_line1    <=    bin_data_21 && bin_data_22 && bin_data_23;
         erosion_line2    <=    bin_data_31 && bin_data_32 && bin_data_33;
    end
end





// 1clk  腐蚀 相与
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
		erosion_data_d	<=	1'd0;
    else
		erosion_data_d	<=	erosion_line0 && erosion_line1 && erosion_line2;
end



// 延迟2clk
always@(posedge video_clk or negedge rst_n)	begin
	if(!rst_n)
	begin	
		erosion_vs_d	<=	1'd0;
        erosion_vs_d1   <=  1'd0;  
        erosion_de_d	<=	1'd0;
        erosion_de_d1   <=  1'd0;
         
	end
	else
	begin	
		erosion_vs_d	<=	bin_vs;
        erosion_vs_d1   <=  erosion_vs_d; 
        erosion_de_d	<=	bin_de;
        erosion_de_d1   <=  erosion_de_d;    
	end
end
assign 	erosion_data 	= erosion_data_d;

assign	erosion_vs		= erosion_vs_d1	;	
assign  erosion_de		= erosion_de_d1	;

endmodule