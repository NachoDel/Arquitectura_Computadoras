`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15/10/2025 05:57:16 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART Transmitter FSM (8N1) con sobremuestreo 16x
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_tx #(
    parameter DATA_BITS = 8,
    parameter OVERSAMPLING = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire tx_start,                   // Señal para iniciar la transmisión
    input  wire [DATA_BITS-1:0] data_in,    // Datos a transmitir
    input  wire tick,                       // Tick 16x de baud_gen
    output reg tx,                          // Línea serie de salida
    output reg tx_done                      // Señal de finalización de transmisión
);
    localparam [2:0] S_IDLE=0, S_START=1, S_DATA=2, S_STOP=3;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [$clog2(DATA_BITS)-1:0] n_reg, n_next;
    reg [DATA_BITS-1:0] data_reg; // Registro para capturar data_in
    reg tx_next; // Señal para el próximo valor de tx

    always @(posedge clk) begin
        if (rst) begin
            state_reg <= S_IDLE;
            s_reg <= 0;
            n_reg <= 0;
            tx <= 1; // Línea inactiva (alto)
            tx_done <= 1'b0;
            data_reg <= 0;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            tx <= tx_next;
            
            // Capturar datos cuando se inicia transmisión
            if (state_reg == S_IDLE && tx_start)
                data_reg <= data_in;

            // Generar tx_done de forma síncrona (1 ciclo) cuando se completa el STOP
            if (state_reg == S_STOP && tick && (s_reg == (OVERSAMPLING - 1)))
                tx_done <= 1'b1;
            else
                tx_done <= 1'b0;
        end
    end
    
    // Lógica del próximo estado
    always @(*) begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        // tx_done = 1'b0;  // tx_done ahora es síncrono
        tx_next = tx; // Mantener valor actual por defecto
        
        case (state_reg)
            S_IDLE: begin
                tx_next = 1; // Línea en alto
                if (tx_start) begin
                    s_next = 0;
                    n_next = 0;
                    state_next = S_START;
                    tx_next = 0;    // Bit de inicio (bajo)
                end
            end
            
            S_START: begin
                tx_next = 0;    // Mantenemos bit de inicio
                if (tick) begin
                    if (s_reg == (OVERSAMPLING - 1)) begin
                        s_next = 0;
                        state_next = S_DATA;
                        tx_next = data_reg[0];  // Primer bit de datos
                    end else
                        s_next = s_reg + 1;
                end
            end
            
            S_DATA: begin
                tx_next = data_reg[n_reg];  // Mantenemos bit actual
                if (tick) begin
                    if (s_reg == (OVERSAMPLING - 1)) begin
                        s_next = 0;
                        if (n_reg == (DATA_BITS - 1)) begin
                            state_next = S_STOP;
                            tx_next = 1; // Bit de parada
                        end else begin
                            n_next = n_reg + 1;
                            tx_next = data_reg[n_reg + 1];  // Siguiente bit
                        end
                    end else
                        s_next = s_reg + 1;
                end
            end
            
            S_STOP: begin
                tx_next = 1;    // Bit de parada (alto)
                if (tick) begin
                    if (s_reg == (OVERSAMPLING - 1)) begin
                        // tx_done se genera en el flanco de reloj para que la FSM lo detecte
                        state_next = S_IDLE;
                    end else
                        s_next = s_reg + 1;
                end
            end
            
            default: begin
                state_next = S_IDLE;
                tx_next = 1;
            end
        endcase
    end
endmodule
