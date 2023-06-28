`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/03 18:19:48
// Design Name: 
// Module Name: sccomp
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



module sccomp(
input clk,
input rstn,
input [15:0] sw_i,
output [7:0] disp_an_o, disp_seg_o,
output [15:0] led_o
);

reg [31:0] clkdiv;
wire Clk_CPU;

always@(posedge clk, negedge rstn) begin
    if(!rstn)
        clkdiv <= 0;
    else
        clkdiv <= clkdiv + 1'b1;
end

assign Clk_CPU = (sw_i[15])?clkdiv[27]:clkdiv[25]; 
reg [63:0]  display_data;    
reg [5:0]   led_data_addr;
reg [63:0]  led_disp_data;
parameter   LED_DATA_NUM = 19, ROM_DATA_NUM = 12;
reg [63:0]  LED_DATA[18:0];

initial begin
    LED_DATA[0] = 64'hC6F6F6F0C6F6F6F0;
    LED_DATA[1] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[2] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[3] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[4] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[5] = 64'hFFFFA3FFFFFFA3FF;
    LED_DATA[6] = 64'hFFFF9CFFFFFF9CFF;
    LED_DATA[7] = 64'hFF9EBCFFFF9EBCFF;
    LED_DATA[8] = 64'hFF9CFFFFFFC0FFFF;
    LED_DATA[9] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[10] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[11] = 64'hFFA7B3FFFFA7B3FF;
    LED_DATA[12] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[13] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[14] = 64'h9EBEBEBC9EBEBEBC;
    LED_DATA[15] = 64'h2737373327373733;
    LED_DATA[16] = 64'h505454EC505454EC;
    LED_DATA[17] = 64'h744454F8744454F8;
    LED_DATA[18] = 64'h0062080000620800;
end

always@(posedge Clk_CPU or negedge rstn) begin
    if(!rstn) begin 
        led_data_addr = 6'd0;
        led_disp_data = 64'b0;
    end
    else if(sw_i[0] == 1'b1)  //sw_i[0] == 1 显示矩阵变换 图形模式
        begin
            if(led_data_addr == LED_DATA_NUM) 
              begin
                led_data_addr = 6'b0;
                led_disp_data = 64'b0;
              end
            led_disp_data = LED_DATA[led_data_addr];
            led_data_addr = led_data_addr + 1'b1;
        end
    else
        led_data_addr = led_data_addr;
end


wire [31:0] instr;
reg [31:0]  reg_data;
reg [31:0]  alu_disp_data;
//reg [31:0]  dmem_data;

always@(sw_i) begin
    if(sw_i[0] == 0) begin
       case(sw_i[14:12]) 
            3'b100: display_data = instr;// SW[14] = 1 显示ROM
            3'b010: display_data = reg_data; // SW[13] = 1 显示RF
            3'b001: display_data = alu_disp_data; // sw[12] = 1 显示ALU A B C Zero  
            default: display_data = 32'b0; // 其他情况
        endcase
    end
    else begin
        display_data = led_disp_data;
    end
end

reg[31:0] rom_addr;

always@(posedge Clk_CPU or negedge rstn) begin
    if(!rstn) begin 
        rom_addr = 32'b0;
    end
    else if(sw_i[14] == 1'b1) begin
        if(rom_addr == ROM_DATA_NUM)rom_addr = 32'b0;
        else rom_addr = rom_addr + 1'b1;end
    else
        rom_addr = rom_addr;
end



//RF
reg RegWright;
reg[2:0] rs1,rs2,rd;
reg [31:0] WD;
wire [31:0]RD1,RD2;
reg [4:0] reg_addr;
    always @ (*) begin
        RegWright = sw_i[2];
    end  
always@(posedge Clk_CPU or negedge rstn) begin
        if(!rstn) reg_addr = 5'b0;
        else if(sw_i[11] == 1'b1) begin // 任务2
            if(RegWright == 0)              //sw[2]=0 ,	写寄存器使能信号无效，不能修改寄存器，只能读寄存器
              begin             
                rs1 = sw_i[10:8];   
                rs2 = sw_i[7:5];
              end
            else                            //  sw[2]=1 ,	写寄存器使能信号有效，可以修改寄存器 
              begin                          
                if(sw_i[1] == 1'b0)                     //sw[1]=0, 非调试模式，可以修改对应寄存器数值
                  begin                           
                    rd = sw_i[10:8];
                    if(sw_i[7]==1)
                        begin WD={29'b1111_1111_1111_1111_1111_1111_1111_1,sw_i[7:5]}; end
                    else
                        begin WD={29'b0,sw_i[7:5]}; end     
                  end         
                else                                    // sw[1] =1, 调试模式，不能修改对应寄存器数值
                  begin  reg_addr = reg_addr + 1'b1;  reg_data = U_RF.rf[reg_addr]; end      
              end    
        end
    end

RF U_RF(.clk(clk),.rstn(rstn),.RFWr(RegWright),.sw_i(sw_i),.A1(rs1),.A2(rs2),.A3(rd),.WD(WD),.RD1(RD1),.RD2(RD2));



reg[31:0] A;
reg[31:0] B;
reg[4:0]ALUOp;
    always@(posedge Clk_CPU or negedge rstn)
    begin
      if(!rstn)
            begin A = 1'b0; B = 1'b0; end
      else if(sw_i[12] == 1'b1)begin   // 显示A B C Zero
      if(sw_i[11]==0 ) // 任务1
        begin
            A={{28{sw_i[10]}},sw_i[10:7]};
            B={{28{sw_i[6]}},sw_i[6:3]};
            ALUOp={4'b0000,sw_i[2]};   // 00000 ADD; 00001 sub
        end
      else  // sw_i[11]==1 任务2 
        begin
            A= RD1;
            B= RD2;
            ALUOp={3'b000,sw_i[4:3]};
        end
    end 
end
    alu U_alu(.A(A),.B(B),.ALUOp(ALUOp),  .C(C),.Zero(Zero));


reg [2:0] alu_addr;
always@(posedge Clk_CPU or negedge rstn)  // 循环显示alu A B C Zero
begin
    if(!rstn)
        begin alu_addr=1'b0;end
    else if(sw_i[1] && sw_i[12])
        begin
            alu_addr=alu_addr+1'b1;
            case(alu_addr)
                3'b001:alu_disp_data=U_alu.A;              
                3'b010:alu_disp_data=U_alu.B;
                3'b011:alu_disp_data=U_alu.C;
                3'b100:alu_disp_data=U_alu.Zero;
                default:alu_disp_data=32'hFFFFFFFF;
            endcase
            if(alu_addr==3'b101)begin alu_addr=1'b0;end
        end
end

assign led_o=sw_i;

seg7x16 u_seg7x16(
    .clk(clk),
    .rstn(rstn),
    .i_data(display_data),
    .disp_mode(sw_i[0]),
    .o_seg(disp_seg_o),
    .o_sel(disp_an_o)
);

dist_mem_im U_IM(
    .a(rom_addr),
    .spo(instr)
);


endmodule
