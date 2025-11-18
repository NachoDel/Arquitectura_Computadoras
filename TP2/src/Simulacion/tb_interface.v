`timescale 1ns / 1ps

module tb_interface;

    // Señales
    reg clk, rst;
    reg rx_done;
    reg [7:0] rx_data;
    wire tx_start;
    wire [7:0] tx_data;
    reg tx_done;
    wire [7:0] alu_a, alu_b;
    wire [5:0] alu_opcode;
    wire [7:0] alu_result;
    wire alu_carry, alu_zero;

    // Instancia de la interfaz
    interface uut (
        .clk(clk),
        .rst(rst),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done(tx_done),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_opcode(alu_opcode),
        .alu_result(alu_result),
        .alu_carry(alu_carry),
        .alu_zero(alu_zero)
    );

    // Instancia de la ALU
    alu alu_inst (
        .A(alu_a),
        .B(alu_b),
        .OpCode(alu_opcode),
        .S(alu_result),
        .carry(alu_carry),
        .zero(alu_zero)
    );

    // Reloj
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz → periodo 10 ns

    // Secuencia de prueba
    initial begin
        $display("Inicio de simulación del módulo interface + ALU");
        rst = 1;
        rx_done = 0;
        rx_data = 0;
        tx_done = 0;
        #20;
        rst = 0;

        // Simulamos envío de operandos y operación
        // A = 8'h0A, B = 8'h03, OpCode = ADD (6'b100000)
        @(posedge clk);
        rx_data = 8'h0A;   // A = 10
        rx_done = 1; #10; rx_done = 0;
        repeat(10) @(posedge clk);

        rx_data = 8'h03;   // B = 3
        rx_done = 1; #10; rx_done = 0;
        repeat(10) @(posedge clk);

        rx_data = 8'b00100000; // OpCode ADD
        rx_done = 1; #10; rx_done = 0;
        repeat(10) @(posedge clk);

        // Esperamos a que la interfaz inicie TX del resultado
        wait(tx_start);
        $display("TX resultado: %d (esperado 13)", tx_data);
        tx_done = 1; #10; tx_done = 0;
        repeat(10) @(posedge clk);

        // Esperamos envío de flags
        wait(tx_start);
        $display("TX flags: carry=%b zero=%b (byte: %b)", tx_data[1], tx_data[0], tx_data);
        tx_done = 1; #10; tx_done = 0;

        repeat(20) @(posedge clk);
        $display("Fin de la simulación");
        $stop;
    end

endmodule
