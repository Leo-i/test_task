`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2021 19:49:17
// Design Name: 
// Module Name: receiver
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


module receiver(

    input               reset,
    
    input [22:0]        GPI,
    input               ACK,

    output reg [22:0]   received_data,
    output reg          ready
);


always@(negedge ACK or posedge reset) begin
  
    if(reset) begin
        ready   <= 1'b0;
        received_data <= 23'h0;
    end else begin
        received_data <= GPI;
        ready   <= 1'b1;
    end


end



endmodule
