`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2021 19:59:47
// Design Name: 
// Module Name: transmitter
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


module transmitter(

    input               clk,
    input               reset,

    input [22:0]        data_to_send,
    input               start_send,

    output [22:0]       GPO,
    output reg          INTR,
    output reg          ready
);

initial begin
    INTR  <= 1'b1;
    ready <= 1'b0;
end


assign GPO = data_to_send;

always@(posedge clk) begin
  
    if (reset) begin
      INTR  <= 1'b1;
      ready <= 1'b0;
    end else begin
      
      if (ready) begin
          INTR <= 1'b1;
      end else begin

        if (start_send) begin
         INTR <= 1'b0;
         ready <= 1'b1;
        end

      end

    end

end
endmodule
