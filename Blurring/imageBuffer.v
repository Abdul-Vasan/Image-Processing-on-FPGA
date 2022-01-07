`timescale 1ns / 1ps
`include "lineBuffer.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2021 16:41:17
// Design Name: 
// Module Name: imageBuffer
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


module imageBuffer #(parameter dataWidth=8, 
                     parameter kernelWidth=3, 
                     parameter kernelHeight=3,
                     parameter imageWidth=512)(
    input        i_clk,
    input        i_reset_n,
    input  [dataWidth-1:0] i_pixel_data,
    input        i_pixel_data_valid,
    output [kernelWidth*kernelHeight*dataWidth-1:0] o_data,
    output  reg  o_data_valid
);

integer counter=0;

always @(posedge i_clk)
begin
    if(!i_reset_n)
        counter <= 0;
    else if(i_pixel_data_valid & !o_data_valid)
        counter <= counter+1;
    else if(!i_pixel_data_valid & o_data_valid)
        counter <= counter-1;
        
    if(counter == (((kernelHeight-1)/2)*imageWidth+((kernelWidth-1)/2)) & i_pixel_data_valid)
        o_data_valid <= 1'b1;
    else if(counter > (((kernelHeight-1)/2)*imageWidth+(kernelWidth-1)/2))
        o_data_valid <= 1'b1;
    else
        o_data_valid <= 1'b0;
end


//assign o_data_valid = counter >= (((kernelHeight-1)/2)*imageWidth+(kernelWidth)/2);
//assign o_data_valid = counter >= ((kernelHeight-1)/2)*imageWidth;


wire [dataWidth-1:0] w_data_reg_out [kernelWidth*kernelHeight-1:0];
wire [kernelWidth*kernelHeight-1:0] w_data_reg_out_valid;
wire [dataWidth-1:0] line_buff_out [kernelHeight-2:0];
wire [kernelHeight-2:0] line_buff_out_valid;

//assign o_data_valid = i_pixel_data_valid;//w_data_reg_out_valid[`kernelWidth*`kernelHeight-1];

generate
genvar i,j,k;
    for(i=kernelHeight-1;i>=0;i=i-1)
    begin:l1
        for(j=kernelWidth-1;j>=0;j=j-1)
        begin:l2
            for(k=0;k<dataWidth;k=k+1)
            begin:l3
                assign o_data[(kernelHeight-1-i)*kernelWidth*dataWidth+(kernelWidth-1-j)*dataWidth+k] = w_data_reg_out[i*kernelWidth+j][k];
            end
        end
    end
endgenerate



generate
    //genvar i,j;
    for(i=0;i<kernelHeight;i=i+1)
    begin:oloop
        for(j=0;j<kernelWidth;j=j+1)
        begin:iloop
            if(i==0&j==0) //first data register
            begin
                dataReg #(.dataWidth(dataWidth))dR0(
                    .i_clk(i_clk),
                    .i_data(i_pixel_data), //external data
                    .i_data_valid(i_pixel_data_valid),
                    .o_data(w_data_reg_out[i*kernelWidth+j]),
                    .o_data_valid(w_data_reg_out_valid[i*kernelWidth+j])
                );
            end
            else if(j==0) //first data register in each row
            begin
                dataReg #(.dataWidth(dataWidth))dR1(
                    .i_clk(i_clk),
                    .i_data(line_buff_out[i-1]), //data out from each line
                    .i_data_valid(i_pixel_data_valid),
                    .o_data(w_data_reg_out[i*kernelWidth+j]),
                    .o_data_valid(w_data_reg_out_valid[i*kernelWidth+j])
                );
            end
            else//all other cases
            begin
                dataReg #(.dataWidth(dataWidth))dR2(
                    .i_clk(i_clk),
                    .i_data(w_data_reg_out[i*kernelWidth+j-1]), //data out previous data reg
                    .i_data_valid(i_pixel_data_valid),
                    .o_data(w_data_reg_out[i*kernelWidth+j]),
                    .o_data_valid(w_data_reg_out_valid[i*kernelWidth+j])
                );
            end
        end
    end
endgenerate


generate
//genvar i,j;
    for(i=0;i<kernelHeight-1;i=i+1)
    begin:loop
        if(i==0)
        begin
            lineBuffer #(.dataWidth(dataWidth),.imageWidth(imageWidth))lB0(
                .i_clk(i_clk),
                .i_data(i_pixel_data),
                .i_data_valid(i_pixel_data_valid),
                .o_data(line_buff_out[i]),
                .o_data_valid(line_buff_out_valid[i])
            );
        end
        else
        begin
            lineBuffer #(.dataWidth(dataWidth),.imageWidth(imageWidth))lB(
                .i_clk(i_clk),
                .i_data(line_buff_out[i-1]),
                .i_data_valid(i_pixel_data_valid),
                .o_data(line_buff_out[i]),
                .o_data_valid(line_buff_out_valid[i])
            );        
        end
    end
endgenerate


endmodule
