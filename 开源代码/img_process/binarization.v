module binarization(

    input               clk             ,   
    input               rst_n           ,   

    input               vsync_in     ,   // vs in
    input               hsync_in     ,   // hs in
    input               de_in        ,   // de i
    input   [7:0]       y_in       ,


    output              vsync_out      ,   // vs o
    output              hsync_out      ,   // hs o
    output              de_out         ,   // de o
    output   reg        pix            
);

//reg define
reg    vsync_in_d;
reg    hsync_in_d;
reg    de_in_d   ;

parameter Binar_THRESHOLD = 128;

assign  vsync_out = vsync_in_d  ;
assign  hsync_out = hsync_in_d  ;
assign  de_out    = de_in_d     ;

//二值化
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pix <= 1'b0;
    else if(y_in > Binar_THRESHOLD)  //阈值
        pix <= 1'b1;
    else
        pix <= 1'b0;
end

//延时1拍以同步时钟信号
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        vsync_in_d <= 1'd0;
        hsync_in_d <= 1'd0;
        de_in_d    <= 1'd0;
    end
    else begin
        vsync_in_d <= vsync_in;
        hsync_in_d <= hsync_in;
        de_in_d    <= de_in   ;
    end
end

endmodule 