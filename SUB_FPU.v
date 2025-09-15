`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2025 08:06:18
// Design Name: 
// Module Name: SUB_FPU
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


`timescale 1ns / 1ps
module SUB_FPU(a, b, s, OVERFLOW, UNDERFLOW);
    parameter NEXP = 8;  // Exponent size
    parameter NSIG = 23; // Significand size
    input [NEXP + NSIG : 0] a, b;
    output [NEXP + NSIG : 0] s;
    output OVERFLOW, UNDERFLOW;

    wire [NEXP + NSIG : 0] neg_b;
    
    // Negate the second operand by flipping the sign bit
    assign neg_b = {~b[NEXP+NSIG], b[NEXP+NSIG-1:0]};
    
    // Instantiate ADD_FPU for subtraction
    ADD_FPU #(.NEXP(NEXP), .NSIG(NSIG)) adder (
        .a(a), 
        .b(neg_b), 
        .s(s), 
        .OVERFLOW(OVERFLOW), 
        .UNDERFLOW(UNDERFLOW)
    );
    
endmodule

