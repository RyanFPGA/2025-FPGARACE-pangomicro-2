%% 将图片转为txt 以供modelsim读取
clc;
clear all;

%% 读取图像文件 换成自己图片的路径 bmp/png/jpg均可
image_rgb = imread('night1.bmp');

%% 显示图像
imshow(image_rgb);

%% 获取图像的尺寸信息
[image_height, image_width, num_channels] = size(image_rgb);

%% 打开文件以写入
file_id = fopen('img.txt', 'w+');

%% 遍历每一个像素并写入到文件中
for row_index = 1:image_height
    for col_index = 1:image_width 
        for channel_index = 1:num_channels
            % 将每个像素值写入文件，以十六进制格式表示
            fprintf(file_id, '%02x', image_rgb(row_index, col_index, channel_index));
        end
        % 每行像素结束后换行
        fprintf(file_id, '\n');
    end
end

%% 关闭文件
fclose(file_id);
