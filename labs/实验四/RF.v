`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/03 18:19:48
// Design Name: 
// Module Name: RF
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

module RF(
input clk,
input rstn,
input RFWr,
input [15:0] sw_i,
input [2:0] A1,A2,A3,
input [31:0] WD,
output reg[31:0] RD1, RD2
    );
    

reg [31:0] rf[31:0];
integer i;

initial begin
 for(i = 0;i < 32;i = i+1) rf[i] = i; end

always@(posedge clk)
 begin
    if(RFWr && (!sw_i[1]))rf[A3] <= WD; //非调试模式，可以修改对应寄存器数值
end

always@(*)begin
    RD1 = rf[A1]; 
    RD2 = rf[A2]; 
end
    
endmodule