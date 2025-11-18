`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 06:52:42 PM
// Design Name: 
// Module Name: alu
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


module alu #(
    parameter N_data = 8, 	// ancho de datos
    parameter N_op = 6		// ancho de codigo de operacion
) (   
    input wire [N_data-1:0] A,             // operando A
    input  wire [N_data-1:0] B,             // operando B
    input  wire [N_op-1:0] OpCode,              // código de operación (6 bits)
    output reg [N_data-1:0] S,          // resultado
    output reg carry,          // flag de carry
    output reg zero          // flag de resultado
);

    // códigos de operación según el cuadro
    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;
    localparam AND_ = 6'b100100;
    localparam OR_  = 6'b100101;
    localparam XOR_ = 6'b100110;
    localparam SRA  = 6'b000011;
    localparam SRL  = 6'b000010;
    localparam NOR  = 6'b100111;
    localparam SHIFT_BITS = $clog2(N_data);     // cantidad de bits necesarios para hacer los shifts dependiendo el bus de datos de entrada y no usar fijo 3 bits: B[2:0]
    always @(*) begin        // valores por defecto
        S     = 0;
        carry = 0;
        zero  = 0;

        case (OpCode)
            ADD:  {carry, S} = A + B;             // suma
            SUB:  {carry, S} = A - B;             // resta (no es un carry sino un borrow)
            AND_: S = A & B;                      // and
            OR_:  S = A | B;                      // or
            XOR_: S = A ^ B;                      // xor
            SRA:  S = $signed(A) >>> B[SHIFT_BITS-1:0];      // shift der aritmético
            SRL:  S = A >> B[SHIFT_BITS-1:0];                // shift der logico
            NOR:  S = ~(A | B);                   // nor
            default: S = 8'b00000000;             // por las dudas
        endcase

        // flag de zero
        zero = (S == 0);
    end
endmodule
