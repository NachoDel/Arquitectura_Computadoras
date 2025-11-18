`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15/10/2025 05:56:48 PM
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART Receiver FSM (8N1) con sobremuestreo 16x
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter DATA_BITS = 8,
    parameter OVERSAMPLING = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,          // línea serie desde PC
    input  wire tick,        // tick 16x de baud_gen
    output reg rx_done,
    output wire [DATA_BITS-1:0] data_out
);
    localparam [2:0] S_IDLE=0, S_START=1, S_DATA=2, S_STOP=3;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;                    // para llevar la cuenta de los ticks
    reg [$clog2(DATA_BITS)-1:0] n_reg, n_next;  // para llevar la cuenta de los bits recibidos
    reg [DATA_BITS-1:0] b_reg, b_next;          // para guardar los bits recibidos

    always @(posedge clk) begin
        if (rst) begin
            state_reg <= S_IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end else begin
           state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end
    
    // Lógica del próximo estado
    always @(*)
    begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done = 1'b0;
        case (state_reg)
            S_IDLE:
                if (~rx) 
                begin
                    s_next = 0;
                    state_next = S_START;
                end
            S_START:
                if (tick)
                    if (OVERSAMPLING/2 - 1)     // Cuando llega a 7 reseteamos los ticks a 0 para poder leer a la mitad de los bits a los 16 ticks
                    begin
                        s_next = 0;
                        n_next = 0;
                        state_next = S_DATA;
                    end
                    else
                        s_next = s_reg + 1;
            S_DATA:
                if (tick)
                    if (s_reg == (OVERSAMPLING -1))     // Nos encontramos en la mitad del bit
                    begin
                        s_next = 0; // Reinciamos los ticks
                        b_next = {rx, b_reg[DATA_BITS-1:1]};    // Shift a la derecha
                        if (n_reg == (DATA_BITS-1))
                            state_next = S_STOP;    // Si ya leimos el ultimo bit, paramos
                        else
                            n_next = n_reg + 1;     // Continuamos para leer el próximo bit
                    end
                    else
                        s_next = s_reg + 1;
            S_STOP:
                if (tick)
                    if (s_reg == (OVERSAMPLING -1))
                    begin
                        rx_done = 1'b1;
                        state_next = S_IDLE;
                    end
                    else
                        s_next = s_reg + 1;
            default:
                state_next = S_IDLE;
        endcase
    end
    
    // Logica de salida
    assign data_out = b_reg;
endmodule
