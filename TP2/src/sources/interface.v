`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15/10/2025 05:58:27 PM
// Design Name: 
// Module Name: interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: FSM responsable de cargar los operandos en la ALU recibidos mediante uart_rx
// Luego devuelve el resultado y los flags de la operacion mediante uart_tx
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module interface #(
    parameter N_DATA = 8,       // ancho de datos
    parameter N_OP = 6          // ancho de código de operación
)(
    input wire clk,
    input wire rst,
    // interfaz UART RX
    input wire rx_done,
    input wire [N_DATA-1:0] rx_data,
    // interfaz UART TX
    output reg tx_start,
    output reg [N_DATA-1:0] tx_data,
    input wire tx_done,
    // interfaz ALU
    output reg [N_DATA-1:0] alu_a,
    output reg [N_DATA-1:0] alu_b,
    output reg [N_OP-1:0] alu_opcode,
    input wire [N_DATA-1:0] alu_result,
    input wire alu_carry,
    input wire alu_zero
);

    // Estados de la FSM
    localparam [2:0] 
        S_GET_A = 0,
        S_GET_B = 1,
        S_GET_OP = 2,
        S_SEND_RESULT = 3,
        S_WAIT_RESULT = 4,
        S_SEND_FLAGS = 5,
        S_WAIT_FLAGS = 6;
    
    reg [2:0] state;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= S_GET_A;
            tx_start <= 1'b0;
            tx_data <= {N_DATA{1'b0}};
            alu_a <= {N_DATA{1'b0}};
            alu_b <= {N_DATA{1'b0}};
            alu_opcode <= {N_OP{1'b0}};
        end else begin
            // tx_start se va a activar solo durante un ciclo
            tx_start <= 1'b0;
            
            case (state)
                S_GET_A: begin
                    if (rx_done) begin
                        alu_a <= rx_data;
                        state <= S_GET_B;
                    end
                end
                
                S_GET_B: begin
                    if (rx_done) begin
                        alu_b <= rx_data;
                        state <= S_GET_OP;
                    end
                end
                
                S_GET_OP: begin
                    if (rx_done) begin
                        alu_opcode <= rx_data[N_OP-1:0];
                        // Como la ALU es combinacional, pasamos directamente al estado para mandar el resultado
                        state <= S_SEND_RESULT;
                    end
                end
                
                S_SEND_RESULT: begin
                    tx_data <= alu_result;
                    tx_start <= 1'b1;
                    state <= S_WAIT_RESULT;
                end
                
                S_WAIT_RESULT: begin
                    if (tx_done) begin
                        state <= S_SEND_FLAGS;
                    end
                end
                
                S_SEND_FLAGS: begin
                    tx_data <= {{(N_DATA-2){1'b0}}, alu_carry, alu_zero};
                    tx_start <= 1'b1;
                    state <= S_WAIT_FLAGS;
                end
                
                S_WAIT_FLAGS: begin
                    if (tx_done) begin
                        state <= S_GET_A;
                    end
                end
                
                default:
                    state <= S_GET_A;
            endcase
        end
    end

endmodule
