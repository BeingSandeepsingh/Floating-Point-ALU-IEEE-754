`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.02.2025 19:39:31
// Design Name: 
// Module Name: ALU_FPU
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

module ALU_FPU (a,b,opcode,p,OVERFLOW, UNDERFLOW);
    parameter NEXP = 8; 
    parameter NSIG = 23;
    input [NEXP + NSIG : 0] a, b;  // Floating point inputs (IEEE-754 format)
    input [2:0] opcode;           // Operation selector
    output reg [NEXP + NSIG : 0] p; // Output result
    output reg OVERFLOW, UNDERFLOW; // Overflow and Underflow flags

    
    wire [NEXP + NSIG : 0] add_out, sub_out, mul_out, div_out, cmp_out;
    wire ov_add, uf_add, ov_sub, uf_sub, ov_mul, uf_mul, ov_div, uf_div;
    
    // Instantiate individual floating point units
    ADD_FPU add_inst (.a(a), .b(b), .s(add_out), .OVERFLOW(ov_add), .UNDERFLOW(uf_add));
    SUB_FPU sub_inst (.a(a), .b(b), .s(sub_out), .OVERFLOW(ov_sub), .UNDERFLOW(uf_sub));
    MUL_FPU mul_inst (.a(a), .b(b), .p(mul_out), .OVERFLOW(ov_mul), .UNDERFLOW(uf_mul));
    DIV_SEQ_FPU div_inst (.a(a), .b(b), .d(div_out), .O(ov_div), .V(uf_div));
    CMP_FPU cmp_inst (.a(a), .b(b), .p(cmp_out));

    always @(*) begin
        OVERFLOW = 0;
        UNDERFLOW = 0;
        
        case (opcode)
            3'b000: begin  // Addition
                p = add_out;
                OVERFLOW = ov_add;
                UNDERFLOW = uf_add;
            end
            3'b001: begin  // Subtraction
                p = sub_out;
                OVERFLOW = ov_sub;
                UNDERFLOW = uf_sub;
            end
            3'b010: begin  // Multiplication
                p = mul_out;
                OVERFLOW = ov_mul;
                UNDERFLOW = uf_mul;
            end
            3'b011: begin  // Division
                p = div_out;
                OVERFLOW = ov_div;
                UNDERFLOW = uf_div;
            end
            3'b100: begin  // Comparator
                p = cmp_out;  // No overflow/underflow for comparison
            end
            default: begin  // Invalid opcode
                p = 0;
            end
        endcase
    end

endmodule
