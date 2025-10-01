`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2025 07:41:13 PM
// Design Name: 
// Module Name: test_bench
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

module test_bench;

    parameter N_data = 8;
    parameter N_op   = 6;

    reg clk;
    reg rst;
    reg [N_data-1:0] data;
    reg enable_a, enable_b, enable_op;

    wire [N_data-1:0] result;
    wire zero;
    wire carry;

    // DUT
    top_module #(
        .N_data(N_data),
        .N_op(N_op)
    ) dut (
        .clk(clk),
        .rst(rst),
        .data(data),
        .enable_a(enable_a),
        .enable_b(enable_b),
        .enable_op(enable_op),
        .result(result),
        .zero(zero),
        .carry(carry)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;  // periodo 10 ns -> 100 MHz
    
    // Modelo de referencia
    reg [N_data-1:0] expected;
    reg expected_carry;
    reg expected_zero;
    
    task check_result;
    begin
        expected      = 0;
        expected_carry = 0;
    
        case (Op)
            6'b100000: {expected_carry, expected} = A + B;       // ADD
            6'b100010: {expected_carry, expected} = A - B;       // SUB
            6'b100100: expected = A & B;                         // AND
            6'b100101: expected = A | B;                         // OR
            6'b100110: expected = A ^ B;                         // XOR
            6'b000011: expected = $signed(A) >>> B[$clog2(N_data)-1:0]; // SRA
            6'b000010: expected = A >> B[$clog2(N_data)-1:0];           // SRL
            6'b100111: expected = ~(A | B);                      // NOR
            default:   expected = 0;
        endcase
    
        expected_zero = (expected == 0);
    
        // Verificación
        if (result !== expected || carry !== expected_carry || zero !== expected_zero) begin
            $display("ERROR en i=%0d | Op=%b A=%h B=%h => result=%h(c=%b,z=%b) esperado=%h(c=%b,z=%b)",
                i, Op, A, B, result, carry, zero, expected, expected_carry, expected_zero);
            $fatal; // termina la simulación en el primer error
        end else begin
            $display("OK: Op=%b A=%h B=%h => result=%h (carry=%b zero=%b)",
                Op, A, B, result, carry, zero);
        end
    end
    endtask

    // Variables para el test
    reg [N_data-1:0] A;
    reg [N_data-1:0] B;
    reg [N_op-1:0] Op;

    integer i;
    reg [N_op-1:0] valid_ops [0:N_data];
    
    initial begin
        valid_ops[0] = 6'b100000;  // ADD
        valid_ops[1] = 6'b100010;  // SUB
        valid_ops[2] = 6'b100100;  // AND
        valid_ops[3] = 6'b100101;  // OR
        valid_ops[4] = 6'b100110;  // XOR
        valid_ops[5] = 6'b000011;  // SRA
        valid_ops[6] = 6'b000010;  // SRL
        valid_ops[7] = 6'b100111;  // NOR
        valid_ops[8] = 6'b111111;  // INVALID
        data = 0;
        rst = 1;
        enable_a = 0; enable_b = 0; enable_op = 0;
        #20;
        rst = 0;

        for (i=0; i<100; i=i+1) begin
            // generar aleatorios proceduralmente
            A  = $random;
            B  = $random;
            Op = valid_ops[$urandom_range(0, 8)];

            // Cargar A
            @(posedge clk);
            data = A; enable_a = 1;
            @(posedge clk);
            enable_a = 0;

            // Cargar B
            @(posedge clk);
            data = B; enable_b = 1;
            @(posedge clk);
            enable_b = 0;

            // Cargar Op (se usan los 6 LSB de data en top_module)
            @(posedge clk);
            data = Op; enable_op = 1;
            @(posedge clk);
            enable_op = 0;
            
            // Darle un ciclo para que la ALU procese
            @(posedge clk);
            check_result();
        end
    end

endmodule

