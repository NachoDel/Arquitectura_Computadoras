`timescale 1ns / 1ps

module tb_uart_tx;

    // Parámetros
    localparam CLK_FREQ = 100_000_000;
    localparam BAUD_RATE = 9600;
    localparam OVERSAMPLING = 16;
    localparam DATA_BITS = 8;

    localparam CLK_PERIOD = 10; // 100 MHz → 10 ns
    localparam real BIT_PERIOD = 1e9 / BAUD_RATE;

    // Señales
    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [DATA_BITS-1:0] data_in = 0;
    wire tick;
    wire tx_done;
    wire tx;

    // Generador de reloj
    always #(CLK_PERIOD/2) clk = ~clk;

    // Instancia de baud_gen
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(OVERSAMPLING)
    ) baud_gen_inst (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    // Instancia de uart_tx
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

    // Estímulo
    initial begin
        $dumpfile("tb_uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        // Reset
        #(20*CLK_PERIOD);
        rst = 0;

        // Enviar un byte de prueba
        data_in = 8'hA5; // 10100101
        tx_start = 1;
        #(CLK_PERIOD);
        tx_start = 0;

        wait (tx_done);
        $display("✅ Transmisión finalizada: TX_DONE=1 (byte 0x%h)", data_in);

        #(10*BIT_PERIOD);
        //$finish;
    end

endmodule
