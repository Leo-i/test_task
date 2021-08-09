`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2021 19:10:02
// Design Name: 
// Module Name: GPI_Status
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


module GPI_Status(
    input       clk,
    input       reset,

    input       GPI_status, // это значение идет в специальный регистр
    input       Fx3_ready,   // сигнал оповещения о подключении USB. Должен 
                            // держатся в "1" 100 мкс
    output      value_from_usb,
    output reg  valid,
    output      USB_cabel_connection // информирует о подключении USB кабеля
                                    // 1 - подключен, 0 - отключен
);

assign value_from_usb = GPI_status;
assign USB_cabel_connection = (state == WAIT_DISCONNECT);

reg [1:0] state;

localparam IDLE             = 2'h0;
localparam KEEP_1           = 2'h1;
localparam WRITE_TO_REG     = 2'h2;
localparam WAIT_DISCONNECT  = 2'h3;

//100мкс / 25нс = 4000 = 0xFA0
reg [11:0] delay; 

always@(negedge clk) begin

    if (reset) begin
        state <= IDLE;      
    end else begin

        case(state)

            IDLE: begin
                
                if(Fx3_ready) begin
                    state <= KEEP_1;
                end else begin
                  valid <= 0;
                  delay <= 0;
                end

            end
            KEEP_1: begin  

                if (Fx3_ready)
                    if (delay > 12'hFA0) begin
                        delay <= 12'h0;
                        state <= WRITE_TO_REG;
                    end else
                        delay <= delay + 1;
                else
                    state <= IDLE;
            
            end
            WRITE_TO_REG: begin

                valid <= 1'b1;
                state <= WAIT_DISCONNECT;
            
            end
            WAIT_DISCONNECT: begin

                valid <= 1'b0;
                if (!Fx3_ready)
                    state <= IDLE;
              
            end

        endcase

    end
  
end
endmodule
