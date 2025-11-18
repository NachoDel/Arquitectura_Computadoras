`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15/10/2025 05:59:51 PM
// Design Name: 
// Module Name: uart_alu_top
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

module uart_alu_top (
    input wire clk,      // FPGA clock
    input wire rst,      // Reset
    input wire rx,       // linea UART RX
    output wire tx       // linea UART TX
);

    // Parametros
    parameter CLK_FREQ = 100_000_000;  // 100MHz
    parameter BAUD_RATE = 9600;        // 9600 baud
    parameter DATA_WIDTH = 8;          // 8 bits de datos
    parameter OP_WIDTH = 6;            // 6 bits para el opcode de la ALU

    // Internal signals
    wire tick;                // tick del baud
    wire rx_done;             // señal completa RX
    wire [DATA_WIDTH-1:0] rx_data;  // datos recibidos
    wire tx_start;            // señal de start de TX
    wire [DATA_WIDTH-1:0] tx_data;  // Datos a transmitir
    wire tx_done;             // señal completa TX
    
    wire [DATA_WIDTH-1:0] alu_a;    // operando A de la ALU
    wire [DATA_WIDTH-1:0] alu_b;    // operando B de la ALU
    wire [OP_WIDTH-1:0] alu_opcode; // opcode de la ALU
    wire [DATA_WIDTH-1:0] alu_result; // resulado de la operacion
    wire alu_carry, alu_zero;  // flags de la operacion
    
    // Instanciamos el baud rate generator
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(16)
    ) baud_gen_inst (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );
    
    // Instanciamos el receptor UART
    uart_rx #(
        .DATA_BITS(DATA_WIDTH),
        .OVERSAMPLING(16)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tick(tick),
        .rx_done(rx_done),
        .data_out(rx_data)
    );
    
    // Instanciamos el transmisor UART
    uart_tx #(
        .DATA_BITS(DATA_WIDTH),
        .OVERSAMPLING(16)
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tick(tick),
        .tx(tx),
        .tx_done(tx_done)
    );
    
    // Instanciamos la ALU
    alu #(
        .N_data(DATA_WIDTH),
        .N_op(OP_WIDTH)
    ) alu_inst (
        .A(alu_a),
        .B(alu_b),
        .OpCode(alu_opcode),
        .S(alu_result),
        .carry(alu_carry),
        .zero(alu_zero)
    );
    
    // Instanciamos la interfaz
    interface #(
        .N_DATA(DATA_WIDTH),
        .N_OP(OP_WIDTH)
    ) interface_inst (
        .clk(clk),
        .rst(rst),
        // UART RX interface
        .rx_done(rx_done),
        .rx_data(rx_data),
        // UART TX interface
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done(tx_done),
        // ALU interface
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_opcode(alu_opcode),
        .alu_result(alu_result),
        .alu_carry(alu_carry),
        .alu_zero(alu_zero)
    );

endmodule
