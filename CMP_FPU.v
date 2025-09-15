`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2025 08:23:00
// Design Name: 
// Module Name: CMP_FPU
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
module CMP_FPU(a, b, p);
    parameter NEXP = 8;  
    parameter NSIG = 23; 
    input [NEXP + NSIG : 0] a, b;
    output reg [NEXP + NSIG : 0] p;

    reg [NEXP + NSIG : 0] diff_exp, diff_mant; 

    always @(*) begin
        // Step 1: Compare sign bits
        if (a[NEXP+NSIG] != b[NEXP+NSIG]) begin  
            p = (a[NEXP+NSIG]) ? b : a; 
        end 
        else begin
           
            diff_exp = {1'b0, a[NEXP+NSIG-1:NSIG]} - {1'b0, b[NEXP+NSIG-1:NSIG]};
            
            if (diff_exp[NEXP]) begin  
                p = b;
            end 
            else if (diff_exp == 0) begin  
                diff_mant = {1'b0, a[NSIG-1:0]} - {1'b0, b[NSIG-1:0]};

                if (diff_mant[NSIG]) begin  // MSB of mantissa difference is 1, meaning a < b
                    p = b;
                end 
                else begin
                    p = a;  // Otherwise, a is greater or equal
                end
            end 
            else begin
                p = a; // If exponent of `a` is greater, then `a` is larger
            end
        end
    end
endmodule


