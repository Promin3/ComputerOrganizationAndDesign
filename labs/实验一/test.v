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
    input clk,//wire型导线
    input rstn,
    input[15:0]sw_i,
    output [15:0]led_o
    );

    parameter div_num = 24;
    wire clk_div2;//二分频时钟线
    wire clk_div29;//24分频时钟线
    
/// clk_div2
reg clk_div2_tmp;
always@(posedge clk or negedge rstn)//always语句块内不能对wire类型赋值，用reg clk_div2_tmp
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


// always 语句中不能出现wire左值
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
            ledset_flag = 1'b0; // 进入该语句前提条件是flag为1，既led未初始化，初始化时需要置为0
            led_tmp =16'b1000_0000_0000_0000;
        end
    else if(sw_i[4:1] == 4'b1010)
        begin
            led_tmp = {led_tmp[0],led_tmp[15:1]}; // flag == 0,分频时钟信号上升沿，led_tmp 更改值 
        end
    else //if ... else if ... else ...
        begin 
            led_tmp = 16'b0000_0000_0000_0000;
            ledset_flag = 1'b1;
        end
end

assign led_o[15:0] = led_tmp;// led_o为wire类型，故设计led_tmp reg值，assign语句和always语句并行执行

endmodule
