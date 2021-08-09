`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2021 19:23:28
// Design Name: 
// Module Name: special_reg
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


module special_reg(
    input               reset,
    input               valid_data,
    input               data,

    output reg [31:0]   result, 
    output reg [4:0]    current_test,

    input               data_from_usb,
    input               valid_usb_data,

    output reg [31:0]   received_usb_data,
    output reg [4:0]    usb_package_count
);


initial begin
    result              <= 32'h0;
    current_test        <= 5'h0;
    usb_package_count <= 5'h0;
end


always @(posedge valid_data or posedge reset) begin

    if (reset) begin
        result  <= 32'h0;
        current_test <= 5'h0;
    end else begin 
        result[current_test] <= data;
        current_test <= current_test + 1;
    end

end

always @(posedge valid_usb_data or posedge reset) begin

    if (reset) begin
        received_usb_data <= 32'h0;
        usb_package_count <= 5'h0;
    end else begin
        received_usb_data[usb_package_count] <= data_from_usb;
        usb_package_count <= usb_package_count + 1;
    end

end

endmodule
