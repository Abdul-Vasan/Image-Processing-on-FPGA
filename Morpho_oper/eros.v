`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2021 16:53:43
// Design Name: 
// Module Name: conv
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


module eros(
input        i_clk,
input [8:0]  i_pixel_data,
input        i_pixel_data_valid,
output reg   o_convolved_data,
output reg   o_convolved_data_valid
);
    
integer i; 
reg erosData;
reg erosDataValid;
reg convolved_data_valid;

    
always @(posedge i_clk)
begin
    erosData <= |i_pixel_data;
    erosDataValid <= i_pixel_data_valid;
end

    
always @(posedge i_clk)
begin
    o_convolved_data <= erosData;
    o_convolved_data_valid <= erosDataValid;
end
    
endmodule

