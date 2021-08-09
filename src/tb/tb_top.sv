`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2021 10:26:22
// Design Name: 
// Module Name: tb_top
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

`define CLK_PERIOD  25.0ns


// В этом модуле соединяется написанный дизайн для ПЛИС с модулем имитирующим Fx3
// И выводятся полученные данные
module tb_top();


// задаем тактовый сигнал
logic clk_100_mhz = 1;
always #(`CLK_PERIOD/2)clk_100_mhz = ~clk_100_mhz;
logic reset = 0;

// механизм для возврата некоректных посылок
logic [22:0]    filter     = 23'h7FFFFF;

logic cmd_to_start = 0;


// соединение между модулями
wire           clk       ;
wire           rst       ;
wire [22:0]    GPO       ;
wire           INTR      ;
wire [22:0]    GPI       ;
wire           ACK       ;
wire           GPI_status;
wire           Fx3_ready ;

wire [31:0]    result_reg;


Fx3 Fx3(
.clk           (clk         ),   
.rst           (rst         ),   
.GPO           (GPO & filter),   
.INTR          (INTR        ),   
.GPI           (GPI         ),   
.ACK           (ACK         ),   
.GPI_status    (GPI_status  ), 
.Fx3_ready     (Fx3_ready   )
);

logic [4:0]  usb_package_count;
logic [31:0] received_usb_data;


wrapper wrapper(
.input_clk              (clk_100_mhz            ),
.reset                  (reset                  ),
.result_reg             (result_reg             ),
.cmd_to_start_test      (cmd_to_start           ),

.clk_40_mhz             (clk                    ),
.rst                    (rst                    ),
.GPO                    (GPO                    ),
.INTR                   (INTR                   ), 
.GPI                    (GPI                    ),
.ACK                    (ACK                    ),
.GPI_status             (GPI_status             ),
.Fx3_ready              (Fx3_ready              ),

.USB_cabel_connection   (USB_cabel_connection   ),
.usb_package_count      (usb_package_count      ),
.received_usb_data      (received_usb_data      ) 
);

always begin

    wait(USB_cabel_connection == 1)
    $display("\nUSB cabel connected");
    wait(USB_cabel_connection == 0)
    $display("\nUSB cabel disconnected\n");

end

initial begin
    #200us
    filter <= 23'h7F00FF;
    #30us
    filter <= 23'h7FFFFF;
end


initial begin
    $timeformat(-6,2,"us");
    $display("\n\n###############################  Start simulation ###################################\n\n");
    #10us
    reset <= 1'b1;
    #1us
    reset <= 1'b0;
    #1us

    cmd_to_start <= 1'b1;
    #(`CLK_PERIOD)
    cmd_to_start <= 1'b0;

    monitor_transactions();

    $display("\n\nUSB was connected %d times",usb_package_count);

    for (int i = 1; i<usb_package_count+1 ;i++ ) begin
        $write("%d time, With data \"%b\"",i,received_usb_data[i]);
    end

    $display("\n\n###############################  End simulation ###################################\n\n");
    $finish();



end


// Функция отслеживает данные идущие к модулю Fx3 и исходящие от него
// Затем проверяет правильно ли модуль распознал их
// И выводит данные о тесте
task monitor_transactions();
    begin
        
        logic [22:0] data_to_Fx3    = 0;
        logic [22:0] data_from_Fx3  = 0;
        logic        correct_answer = 0;
        logic [5:0]  current_test   = 0;

        $display("Launch test \n");
        
        
        while (current_test <= 30) begin
            
            #1
            if (INTR == 0) begin

                data_to_Fx3 = GPO;
                $write("Sended data: %h, ",data_to_Fx3);

                @(negedge ACK)
                data_from_Fx3 = GPI;
                $write("Received data: %h, ",data_from_Fx3);

                if (data_to_Fx3 == data_from_Fx3) correct_answer = 1'b1; else correct_answer = 1'b0;

                #(`CLK_PERIOD*2)
                
                if (result_reg[current_test] == 1)
                    $write("Special reg value: PASS, ");
                else
                    $write("Special reg value: FAIL, ");

                current_test = current_test + 1;

                if (correct_answer == result_reg[current_test-1])
                    $write("Test %d complete. \n", current_test);
                else
                    $write("Test %d fail. \n",current_test);

                data_to_Fx3 = 0;
                correct_answer = 0;
                

            end

        end

        $display("\nfinish test");

    end

endtask


endmodule




module Fx3(
    input  wire         clk,
    input  wire         rst,// 200 мкс
    
    input  wire [22:0]  GPO,
    input  wire         INTR, // на спадающем фронте
    output logic [22:0] GPI,
    output logic        ACK, // на заднем фронте

    output logic        GPI_status,
    output logic        Fx3_ready
);

logic [22:0] buff;

initial begin

buff        <= 0;
ACK         <= 1;
GPI         <= 0;
GPI_status  <= 0;
Fx3_ready   <= 0;

end


initial begin
    
    // три раза имитируем подключение USB кабеля
    // с посылками  1, 0, 1 
    
    #150us
    Fx3_ready   <= 1'b1;
    GPI_status  <= 1'b1;
    #110us
    Fx3_ready   <= 1'b0;

    #190us
    Fx3_ready   <= 1'b1;
    GPI_status  <= 1'b0;
    #110us
    Fx3_ready   <= 1'b0;

    #190us
    Fx3_ready   <= 1'b1;
    GPI_status  <= 1'b1;
    #110us
    Fx3_ready   <= 1'b0;

end


always @(negedge clk)  begin

    if(rst) begin
        #200us
        if (rst) begin 
            buff        <= 0;
            ACK         <= 1;
            GPI         <= 0;
            GPI_status  <= 0;
            Fx3_ready   <= 0;
        end// Если сигнал сброса болше 200 мкс то сбрасываем полученные данные
        wait(!rst);
    end else begin
        /*
            Принимаем данные по сигналу INTR 
            Выжидаем 300 мкс
            Возвращаем полученные даннные и поднимаем сигнал о их валидности
        */

        if (INTR == 0) begin
            buff <= GPO;
            #10us
            @(negedge clk)
            GPI <= buff;
            ACK <= 1'b0;
            @(negedge clk)
            ACK <= 1'b1;
            GPI <= 0;
        end 
    end

end


endmodule

