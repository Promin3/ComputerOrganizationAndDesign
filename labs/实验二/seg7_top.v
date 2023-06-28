`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/18 11:46:49
// Design Name: 
// Module Name: seg7_top
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
module top_seg(
    input clk,
    input rstn,
    output [7:0]disp_seg_o,
    output [7:0]disp_an_o
    );
    
    reg[31:0] i_data;
    seg7x16 u_seg7x16(.clk(clk),.rstn(rstn),.i_data(i_data),.o_seg(disp_seg_o),.o_sel(disp_an_o));
    
    initial begin
    i_data = 32'b0111_0110_0101_0100_0011_0010_0001_0000;
    end
    
endmodule