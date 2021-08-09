`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2021 19:38:17
// Design Name: 
// Module Name: compare_module
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


module compare_module(

    input [22:0]    sended_data,
    input [22:0]    received_data,

    output          data
    );

assign data = (sended_data == received_data);

endmodule
