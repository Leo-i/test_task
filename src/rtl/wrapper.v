`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2021 18:21:45
// Design Name: 
// Module Name: wrapper
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


module wrapper(
    input           input_clk,
    input           reset,
    output [31:0]   result_reg, // регистр хранящий значения тестов
                                // 0 - FAIL, 1 - PASS
    input           cmd_to_start_test,                            
    
    // сигналы на Fx3
    output          clk_40_mhz,
    output          rst,// 200 мкс

    output  [22:0]  GPO,
    output          INTR, // на спадающем фронте
    input   [22:0]  GPI,
    input           ACK, // на заднем фронте

    input           GPI_status,
    input           Fx3_ready,
    output          USB_cabel_connection,
    output [4:0]    usb_package_count,
    output [31:0]   received_usb_data

);

reg [3:0] state;
localparam IDLE         = 4'h0;
localparam START_TEST   = 4'h1;
localparam SEND_DATA    = 4'h2;
localparam RECEIVE_DATA = 4'h3;
localparam DELAY        = 4'h4;
localparam RESTART      = 4'h5;
localparam RESET_Fx3    = 4'h6;
localparam VERIFY       = 4'h7;

localparam tests_count  = 31;

assign rst = (state == RESET_Fx3);

assign clk_40_mhz = input_clk; // некий модуль преобразующий входную частоту на частоту в 40 МГц

wire data_from_usb;
wire valid_usb_data;

GPI_Status GPI_Status(
.clk                    (clk_40_mhz         ),
.reset                  (reset              ),
.GPI_status             (GPI_status         ), 
.Fx3_ready              (Fx3_ready          ),                         
.value_from_usb         (data_from_usb      ),
.valid                  (valid_usb_data     ),
.USB_cabel_connection   (USB_cabel_connection)
);


wire [4:0]  current_test;
wire [22:0] data_to_send;

test_patterns test_patterns(
.current_test   (current_test), 
.data           (data_to_send)   
);

wire tx_ready;
reg start_send;

transmitter transmitter(
.clk              (clk_40_mhz                       ),
.reset            (reset | (state == RECEIVE_DATA)  ),
.data_to_send     (data_to_send                     ),
.start_send       (start_send                       ),
.GPO              (GPO                              ),
.INTR             (INTR                             ),
.ready            (tx_ready                         )
);

wire [22:0] received_data;
wire rx_ready;

receiver receiver(
.reset          (reset || (state == RESTART)),
.GPI            (GPI                        ),
.ACK            (ACK                        ),
.received_data  (received_data              ),
.ready          (rx_ready                   )
);

wire data_to_result_reg;
reg [22:0] sended_data;

compare_module compare_module(
.sended_data    (sended_data        ),
.received_data  (received_data      ),
.data           (data_to_result_reg )
);

special_reg special_reg(
.reset              (reset              ),

.valid_data         (state == VERIFY    ),
.data               (data_to_result_reg ),
.result             (result_reg         ),
.current_test       (current_test       ),

.data_from_usb      (data_from_usb      ),
.valid_usb_data     (valid_usb_data     ),
.received_usb_data  (received_usb_data  ),
.usb_package_count  (usb_package_count  )
);


reg [15:0] delay = 0;

always@(posedge clk_40_mhz) begin
  
    if(reset) begin
        state <= 4'h0;
        delay <= 16'h0;
    end else begin
        case (state)
            IDLE        : begin 
                
                if (cmd_to_start_test) begin
                    state <= SEND_DATA;
                end else begin
                  start_send <= 1'b0;
                end

            end
            SEND_DATA   : begin 
                
                if (tx_ready) begin
                    state       <= RECEIVE_DATA;
                    start_send  <= 1'b0;
                end else begin
                    start_send  <= 1'b1;
                    sended_data <= data_to_send;
                end

            end
            RECEIVE_DATA: begin 

                if (rx_ready) begin
                  state <= VERIFY;
                end 

            end
            VERIFY      : begin
              
                if (result_reg[current_test-1] == 0)  // Если тест провалился, поднимаем сигнал сброса
                    state <= RESET_Fx3;
                else
                    state <= RESTART;
            end
            RESET_Fx3   : begin // поднимаем сигнал сброса больше чем на 200 мкс
              
              if (delay > 16'h2000) begin
                delay <= 12'h0;
                state <= RESTART;
              end else
                delay <= delay + 1;

            end
            RESTART     : begin // Проверяем нужны ли еще тесты
                
                if (tests_count > current_test) begin
                    state <= DELAY;
                end else begin
                    state <= IDLE;
                end

            end
            DELAY       : begin // Задержка между тестами

                if (delay > 16'h200) begin
                    delay <= 12'h0;
                    state <= SEND_DATA;
                end else
                    delay <= delay + 1;

            end

            default: state <= IDLE;
        endcase
    end

end

endmodule
