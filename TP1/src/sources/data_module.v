`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2025 02:31:29 PM
// Design Name: 
// Module Name: data_module
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


module data_module #(
    parameter N = 8
) (
    input clk,
    input rst,
    input enable,
    input [N-1:0] in,
    output reg [N-1:0] out
);

    always @(posedge clk) begin
        if (rst)
            out <= {N{1'b0}};
        else if (enable)
            out <= in;
    end
endmodule

