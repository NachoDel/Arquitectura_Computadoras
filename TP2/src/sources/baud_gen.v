`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15/10/2025 05:52:42 PM
// Design Name: 
// Module Name: baud_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Generador de ticks de Baud Rate
// Genera ticks para sincronizar UART RX y TX
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module baud_gen #(
    parameter CLK_FREQ = 100_000_000,   // Frecuencia del reloj de la FPGA
    parameter BAUD_RATE = 9600,         // Velocidad de transmisión que queremos usar en uart
    parameter OVERSAMPLING = 16         // OVERSAMPLE típico de 16, daría 651 ciclos de reloj
)(
    input  wire clk, // reloj de la FPGA
    input  wire rst, // reset síncrono
    output reg tick // salida: un pulso de un ciclo cada vez que se cumple el divisor
);

    localparam integer COUNT_MAX = CLK_FREQ / (BAUD_RATE * OVERSAMPLING); //define cada cuántos ciclos de reloj se genera un tick, 16 pq uart trabaja con 16 ticks por cada bit

    // integer counter;  // contador interno
    reg [$clog2(COUNT_MAX)-1:0] counter = 0; // Con ancho específico para hardware sintetizable

    //Se ejecuta en cada flanco positivo del reloj (clk)
    always @(posedge clk) begin
        if (rst) begin
            // Si se resetea, el contador y tick se reinician
            counter <= 0;
            tick <= 0;
        end else begin
            // Cuando el contador llega al máximo, se reinicia y emite un tick
            if (counter == COUNT_MAX - 1) begin
                counter <= 0;
                tick <= 1;
            end else begin
                // Mientras tanto, sigue contando
                counter <= counter + 1;
                tick <= 0; // tick apagado (solo se enciende un ciclo)
            end
        end
    end
endmodule
