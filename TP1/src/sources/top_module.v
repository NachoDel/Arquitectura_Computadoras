`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2025 02:30:26 PM
// Design Name: 
// Module Name: top_module
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


module top_module #(
    parameter N_data = 8,
    parameter N_op = 6
)(
    input clk,
    input rst,
    input [N_data-1:0] data,
    input enable_a,
    input enable_b,
    input enable_op,
    output [N_data-1:0] result,
    output zero,
    output carry
);
    // Cables intermedios que vamos a necesitar
    wire [N_data-1:0] a, b;
    wire [N_op-1:0] opcode;

    // Instanciamos los 2 modulos de los operandos
    data_module #(.N(N_data)) data_a (
        .clk(clk),
        .rst(rst),
        .enable(enable_a),
        .in(data),
        .out(a)
    );

    data_module #(.N(N_data)) data_b (
        .clk(clk),
        .rst(rst),
        .enable(enable_b),
        .in(data),
        .out(b)
    );

    // Instanciamos el modulo de operacion
    data_module #(.N(N_op)) data_op (
        .clk(clk),
        .rst(rst),
        .enable(enable_op),
        .in(data[N_op-1:0]),  // sólo 6 bits
        .out(opcode)
    );

    // Instanciamos la ALU
    alu alu (
        .A(a),
        .B(b),
        .OpCode(opcode),
        .S(result),
        .carry(carry),
        .zero(zero)
    );

endmodule

