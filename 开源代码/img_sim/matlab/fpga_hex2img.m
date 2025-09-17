%% 处理RGB三通道
clear all;
clc;
close;
%% 定义图像分辨率
image_width  = 1280;
image_height = 720;

%% 读取文本数据 16进制 三通道
[hex1, hex2, hex3] = textread('img_process.txt', '%s %s %s');
%单通道
%[hex1] = textread('img_process.txt', '%s');

%% 16进制转10进制
image_data_dec = hex2dec([hex1, hex2, hex3]);   % 16进制转10进制
%image_data_dec = hex2dec([hex1]);   % 16进制转10进制

%% 根据分辨率构建图像矩阵
image_matrix = reshape(image_data_dec, image_width, image_height, 3);
%image_matrix = reshape(image_data_dec, image_width, image_height, 1);
%% 转为无符号8bit
image_uint8 = uint8(image_matrix);

%% 旋转 使图像正常显示
rotated_image = imrotate(image_uint8, -90);

%% 将图片进行水平翻转
flipped_image = flip(rotated_image, 2);

%% 显示部分
%% 保存图片
imwrite(flipped_image, 'modelsim_process.bmp');
%% 显示Modelsim处理后的图片
imshow('modelsim_process.bmp');
title('modelsim仿真图像')





