`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/18 09:54:58
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test(
    input clk,//wire�͵���
    input rstn,
    input[15:0]sw_i,
    output [15:0]led_o
    );

    parameter div_num = 24;
    wire clk_div2;//����Ƶʱ����
    wire clk_div29;//24��Ƶʱ����
    
/// clk_div2
reg clk_div2_tmp;
always@(posedge clk or negedge rstn)//always�����ڲ��ܶ�wire���͸�ֵ����reg clk_div2_tmp
    begin
        if(! rstn)
            clk_div2_tmp = 1'b0;
        else
            clk_div2_tmp = ~clk_div2;
    end
assign clk_div2 = clk_div2_tmp;

/// clk_div29
reg [31:0] clk_cnt;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)
            clk_cnt <= 32'b0;
        else
            clk_cnt <= clk_cnt + 1'b1;
    end
assign clk_div29 = clk_cnt[div_num];


// always ����в��ܳ���wire��ֵ
reg [15:0]led_tmp;
reg ledset_flag;

always@(posedge clk_div29 or negedge rstn)
begin
    if(!rstn)
        begin
        ledset_flag = 1'b1;
        led_tmp = 16'b0000_0000_0000_0000;
        end
    else if((ledset_flag == 1'b1) && (sw_i[4:1] == 4'b1010))
        begin 
            ledset_flag = 1'b0; // ��������ǰ��������flagΪ1����ledδ��ʼ������ʼ��ʱ��Ҫ��Ϊ0
            led_tmp =16'b1000_0000_0000_0000;
        end
    else if(sw_i[4:1] == 4'b1010)
        begin
            led_tmp = {led_tmp[0],led_tmp[15:1]}; // flag == 0,��Ƶʱ���ź������أ�led_tmp ����ֵ 
        end
    else //if ... else if ... else ...
        begin 
            led_tmp = 16'b0000_0000_0000_0000;
            ledset_flag = 1'b1;
        end
end

assign led_o[15:0] = led_tmp;// led_oΪwire���ͣ������led_tmp regֵ��assign����always��䲢��ִ��

endmodule
