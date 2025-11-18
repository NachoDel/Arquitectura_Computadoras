`timescale 1ns / 1ps

module tb_uart_loopback;

    // Parámetros
    localparam CLK_FREQ = 100_000_000;
    localparam BAUD_RATE = 9600;
    localparam OVERSAMPLING = 16;
    localparam DATA_BITS = 8;

    localparam CLK_PERIOD = 10; // 100 MHz

    // Señales
    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [DATA_BITS-1:0] data_in = 0;
    wire tick;
    wire tx_done;
    wire rx_done;
    wire tx;  // Línea compartida
    wire [DATA_BITS-1:0] data_out;

    // Generador de reloj
    always #(CLK_PERIOD/2) clk = ~clk;

    // Instancia del baud_gen
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(OVERSAMPLING)
    ) baud_gen_inst (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    // Transmisor
    uart_tx #(
        .DATA_BITS(DATA_BITS),
        .OVERSAMPLING(OVERSAMPLING)
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(data_in),
        .tick(tick),
        .tx(tx),
        .tx_done(tx_done)
    );

    // Receptor
    uart_rx #(
        .DATA_BITS(DATA_BITS),
        .OVERSAMPLING(OVERSAMPLING)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx),   // ← conexión directa TX → RX
        .tick(tick),
        .rx_done(rx_done),
        .data_out(data_out)
    );

    // Estímulo
    initial begin
        $dumpfile("tb_uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);
        $display("=== UART LOOPBACK TEST ===");

        // Reset
        #(20*CLK_PERIOD);
        rst = 0;

        // Enviar un byte
        data_in = 8'hA5;
        tx_start = 1;
        #(CLK_PERIOD);
        tx_start = 0;

        // Esperar recepción
        wait (rx_done);
        $display("TX→RX Loopback: recibido = %h", data_out);

        if (data_out == data_in)
            $display("✅ LOOPBACK PASS: Byte recibido correctamente");
        else
            $display("❌ LOOPBACK FAIL: Esperado %h, recibido %h", data_in, data_out);

        #(10000);
        $finish;
    end

endmodule
