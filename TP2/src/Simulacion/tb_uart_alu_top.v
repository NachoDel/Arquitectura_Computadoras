`timescale 1ns / 1ps

module tb_uart_alu_top;

    // Señales del testbench
    reg clk, rst;
    reg rx;
    wire tx;

    // Instancia del módulo top
    uart_alu_top dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx)
    );

    // Generador de reloj 100 MHz
    initial clk = 0;
    always #5 clk = ~clk; // Periodo = 10 ns

    // ----------------------------------------------------------
    // Parámetros UART
    localparam BAUD_RATE = 9600;
    localparam CLK_FREQ  = 100_000_000;
    localparam integer OVERSAMPLING = 16;
    localparam integer TICKS_PER_BIT = CLK_FREQ / (BAUD_RATE * OVERSAMPLING);
    localparam integer BIT_PERIOD = TICKS_PER_BIT * 16 * 10; // aprox. tiempo total por bit (ajustado para sim rápida)
    // ----------------------------------------------------------

    // Tarea para enviar un byte por UART simulando la PC
    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            // Bit de start (0)
            rx <= 0;
            #(BIT_PERIOD);

            // 8 bits de datos (LSB primero)
            for (i = 0; i < 8; i = i + 1) begin
                rx <= data[i];
                #(BIT_PERIOD);
            end

            // Bit de stop (1)
            rx <= 1;
            #(BIT_PERIOD);
        end
    endtask

    // ----------------------------------------------------------
    // Secuencia de prueba
    // ----------------------------------------------------------
    initial begin
        $display("Inicio de simulación UART-ALU-TOP");
        rx = 1;  // línea UART inactiva
        rst = 1;
        #1000;
        rst = 0;
        
        $monitor("t=%0t | A=%h B=%h OP=%h RESULT=%h C=%b Z=%b TX=%b RX=%b",
         $time,
         dut.interface_inst.alu_a,
         dut.interface_inst.alu_b,
         dut.interface_inst.alu_opcode,
         dut.alu_inst.S,
         dut.alu_inst.carry,
         dut.alu_inst.zero,
         tx, rx);

        // Enviar operandos y opcode como lo haría la PC:
        // A = 10 (0x0A)
        // B = 3  (0x03)
        // OpCode = ADD (6'b100000 = 0x20)
        uart_send_byte(8'hFF);  // A
        uart_send_byte(8'h02);  // B
        uart_send_byte(8'h20);  // SUB;

        // Esperar un tiempo largo para recibir respuesta
        #2000000;

        $display("Fin de la simulación");
        $stop;
    end

endmodule
