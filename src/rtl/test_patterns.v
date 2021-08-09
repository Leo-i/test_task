`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2021 20:16:56
// Design Name: 
// Module Name: test_patterns
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


module test_patterns(
    input  [4:0] current_test,
    output [22:0] data
);

assign data = (current_test[1:0] == 2'b00) ? 23'h7ABCDE :
              (current_test[1:0] == 2'b01) ? 23'h712345 :
              (current_test[1:0] == 2'b10) ? 23'h767890 : 23'h7BBCCD ;


// always@(*)begin
  
//     case (current_test[1:0])
//         2'b00: data <= 23'h7ABCDE;
//         2'b01: data <= 23'h712345;
//         2'b10: data <= 23'h767890;
//         2'b11: data <= 23'h589646;
//     endcase


// end

endmodule
