`timescale 1ns / 1ps

module tb_uart_rx;

    // Parámetros
    localparam CLK_FREQ      = 100_000_000;  // 100 MHz Basys3
    localparam BAUD_RATE     = 9600;
    localparam OVERSAMPLING  = 16;
    localparam DATA_BITS     = 8;

    localparam CLK_PERIOD    = 10;  // 100 MHz → 10 ns por ciclo
    localparam real BIT_PERIOD = 1e9 / BAUD_RATE; // ns por bit (~104166 ns)

    // Señales
    reg clk = 0;
    reg rst = 1;
    reg rx = 1;               // línea UART (idle=1)
    wire tick;
    wire rx_done;
    wire [DATA_BITS-1:0] data_out;

    // ------------------------
    // Instancia del generador de ticks
    // ------------------------
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(OVERSAMPLING)
    ) baud_gen_inst (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    // ------------------------
    // Instancia del receptor UART
    // ------------------------
    uart_rx #(
        .DATA_BITS(DATA_BITS),
        .OVERSAMPLING(OVERSAMPLING)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tick(tick),
        .rx_done(rx_done),
        .data_out(data_out)
    );

    // ------------------------
    // Generador de reloj (100 MHz)
    // ------------------------
    always #(CLK_PERIOD/2) clk = ~clk;

    // ------------------------
    // Tarea: enviar un byte (8N1)
    // ------------------------
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx = 0;
            #(BIT_PERIOD);

            // 8 bits de datos (LSB primero)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit
            rx = 1;
            #(BIT_PERIOD);
        end
    endtask

    // ------------------------
    // Estímulo principal
    // ------------------------
    initial begin
        $display("=== Simulación UART RX + BaudGen ===");
        $dumpfile("tb_uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        // Reset inicial
        #(20*CLK_PERIOD);
        rst = 0;

        // Esperar estabilidad
        #(BIT_PERIOD);

        // Enviar un byte de prueba: 0xA5 = 10100101
        $display("Enviando byte 0xA5...");
        send_byte(8'hA5);

        // Esperar recepción
        wait (rx_done == 1'b1);
        $display("Byte recibido: %h", data_out);

        if (data_out == 8'hA5)
            $display("✅ TEST PASS: Byte recibido correctamente");
        else
            $display("❌ TEST FAIL: Valor recibido = %h", data_out);

        #(5*BIT_PERIOD);
        $finish;
    end

endmodule
