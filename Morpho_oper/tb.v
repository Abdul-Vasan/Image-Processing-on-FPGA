`timescale 1ns / 1ps
`include "imageBuffer.v"
`include "eros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2021 16:43:43
// Design Name: 
// Module Name: tb
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


`define headerSize 1080
`define imageSize 512*512

module tb(

    );
    
 
 reg clk;
 reg reset;
 reg imgData;
 integer file,file1,i;
 reg imgDataValid;
 integer sentSize;
 integer status;
 wire [8:0] outData;
 wire outDataValid;
 integer receivedData=0;
 wire  outData_i;
 wire outDataValid_i;

 initial
 begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
 end
 
 initial
 begin
    reset = 0;
    sentSize = 0;
    imgDataValid = 0;
    #100;
    reset = 1;
    #100;
    file = $fopen("lena_bin.bmp","rb");
    file1 = $fopen("lena_eros.bmp","wb");
    for(i=0;i<`headerSize;i=i+1)
    begin
        status = $fscanf(file,"%c",imgData);
        $fwrite(file1,"%c",imgData);
    end
    
    @(posedge clk);
    imgDataValid <= 1'b0;
    while(sentSize < `imageSize)
    begin

            @(posedge clk);
            status = $fscanf(file,"%c",imgData);
            imgDataValid <= 1'b1;    

    end

    $fclose(file);
    while(1)
    begin
        @(posedge clk);
        imgData <= 0;
        imgDataValid <= 1'b1;    
    end

 end
 
 always @(posedge clk)
 begin
     if(outDataValid)
     begin
         $fwrite(file1,"%c",outData);
         receivedData = receivedData+1;
     end 
     if(receivedData == `imageSize - 1)// -1 as sim stops at 39999
     begin
        $fclose(file1);
        $stop;
     end
 end
 
 imageBuffer dut(
    .i_clk(clk),
    .i_reset_n(reset),
    .i_pixel_data(imgData),
    .i_pixel_data_valid(imgDataValid),
    .o_data(outData_i),
    .o_data_valid(outDataValid_i)
);

eros eros1(
    .i_clk(clk),
    .i_pixel_data(outData_i),
    .i_pixel_data_valid(outDataValid_i),
    .o_convolved_data(outData),
    .o_convolved_data_valid(outDataValid)
);   

initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0,dut,eros1);
    end
endmodule

