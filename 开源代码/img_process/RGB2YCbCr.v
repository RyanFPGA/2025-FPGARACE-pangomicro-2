module RGB2YCbCr
(
    //module clock
    input               clk             ,  
    input               rst_n           ,  


    input               vsync_in ,   // vsync信号
    input               hsync_in ,   // hsync信号
    input               de_in    ,   // 
    input       [4:0]   red         ,   
    input       [5:0]   green       ,   
    input       [4:0]   blue        ,   


    output              vsync_out,   // vsync信号
    output              hsync_out,   // hsync信号
    output              de_out   ,   // data enable信号
    output      [7:0]   y           ,  
    output      [7:0]   cb          ,  
    output      [7:0]   cr             
);

//reg define
reg  [15:0]   rgb_r_m0, rgb_r_m1, rgb_r_m2;
reg  [15:0]   rgb_g_m0, rgb_g_m1, rgb_g_m2;
reg  [15:0]   rgb_b_m0, rgb_b_m1, rgb_b_m2;
reg  [15:0]   y0 ;
reg  [15:0]   cb0;
reg  [15:0]   cr0;
reg  [ 7:0]   y1 ;
reg  [ 7:0]   cb1;
reg  [ 7:0]   cr1;
reg  [ 2:0]   vsync_in_d;
reg  [ 2:0]   hsync_in_d;
reg  [ 2:0]   de_in_d   ;

//wire define
wire [ 7:0]   rgb888_r;
wire [ 7:0]   rgb888_g;
wire [ 7:0]   rgb888_b;


//RGB565 to RGB 888
assign rgb888_r         = {red  , red[4:2]  };
assign rgb888_g         = {green, green[5:4]};
assign rgb888_b         = {blue , blue[4:2] };


assign vsync_out = vsync_in_d[2]      ;
assign hsync_out = hsync_in_d[2]      ;
assign de_out    = de_in_d[2]         ;
assign y            = hsync_out ? y1 : 8'd0;
assign cb           = hsync_out ? cb1: 8'd0;
assign cr           = hsync_out ? cr1: 8'd0;

//--------------------------------------------
//RGB 888 to YCbCr

/********************************************************
            RGB888 to YCbCr
 Y  = 0.299R +0.587G + 0.114B
 Cb = 0.568(B-Y) + 128 = -0.172R-0.339G + 0.511B + 128
 CR = 0.713(R-Y) + 128 = 0.511R-0.428G -0.083B + 128

 Y  = (77 *R    +    150*G    +    29 *B)>>8
 Cb = (-43*R    -    85 *G    +    128*B)>>8 + 128
 Cr = (128*R    -    107*G    -    21 *B)>>8 + 128

 Y  = (77 *R    +    150*G    +    29 *B        )>>8
 Cb = (-43*R    -    85 *G    +    128*B + 32768)>>8
 Cr = (128*R    -    107*G    -    21 *B + 32768)>>8
*********************************************************/

//step1 pipeline mult
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rgb_r_m0 <= 16'd0;
        rgb_r_m1 <= 16'd0;
        rgb_r_m2 <= 16'd0;
        rgb_g_m0 <= 16'd0;
        rgb_g_m1 <= 16'd0;
        rgb_g_m2 <= 16'd0;
        rgb_b_m0 <= 16'd0;
        rgb_b_m1 <= 16'd0;
        rgb_b_m2 <= 16'd0;
    end
    else begin
        rgb_r_m0 <= rgb888_r * 8'd77 ;
        rgb_r_m1 <= rgb888_r * 8'd43 ;
        rgb_r_m2 <= rgb888_r << 3'd7 ;
        rgb_g_m0 <= rgb888_g * 8'd150;
        rgb_g_m1 <= rgb888_g * 8'd85 ;
        rgb_g_m2 <= rgb888_g * 8'd107;
        rgb_b_m0 <= rgb888_b * 8'd29 ;
        rgb_b_m1 <= rgb888_b << 3'd7 ;
        rgb_b_m2 <= rgb888_b * 8'd21 ;
    end
end

//step2 pipeline add
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        y0  <= 16'd0;
        cb0 <= 16'd0;
        cr0 <= 16'd0;
    end
    else begin
        y0  <= rgb_r_m0 + rgb_g_m0 + rgb_b_m0;
        cb0 <= rgb_b_m1 - rgb_r_m1 - rgb_g_m1 + 16'd32768;
        cr0 <= rgb_r_m2 - rgb_g_m2 - rgb_b_m2 + 16'd32768;
    end

end

//step3 pipeline div
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        y1  <= 8'd0;
        cb1 <= 8'd0;
        cr1 <= 8'd0;
    end
    else begin
        y1  <= y0 [15:8];
        cb1 <= cb0[15:8];
        cr1 <= cr0[15:8];
    end
end

//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        vsync_in_d <= 3'd0;
        hsync_in_d <= 3'd0;
        de_in_d    <= 3'd0;
    end
    else begin
        vsync_in_d <= {vsync_in_d[1:0], vsync_in};
        hsync_in_d <= {hsync_in_d[1:0], hsync_in};
        de_in_d    <= {de_in_d[1:0]   , de_in   };
    end
end

endmodule
