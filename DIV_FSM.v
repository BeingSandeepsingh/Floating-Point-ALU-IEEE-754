`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2025 12:12:35
// Design Name: 
// Module Name: DIV_FSM
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


module DIV_FSM(a, b, CLK, RST, Z);
 parameter N=3;
 input [N-1:0] a, b;
 input CLK, RST;
 output reg Z;

 `define ini       3'b000
 `define binc      3'b001   
 `define bcond     3'b010   
 `define aincb0    3'b011   
 `define acond     3'b100   
 `define Output    3'b101   

reg [N-1:0] A, B;
reg [2:0] state = `ini, nxt_state;
reg [2:0] count = 3'b000;

always @(posedge CLK or posedge RST)
begin
    if (RST)
    begin
        count <= 3'b000;
        state <= `ini;
        Z <= 0;
        A <= 0;
        B <= 0;
    end
    else
    begin
        count <= count + 1;
        state <= nxt_state;
    end
end

always @(posedge CLK)
begin
    if (count < 6)
    begin
        case (state)
            `ini: begin
                A <= 0;
                B <= 0;
                nxt_state <= `binc;
            end
            `binc: begin
                B <= B + 1;
                nxt_state <= `bcond;
            end 
            `bcond: begin
                if (B < 8)
                    nxt_state <= `binc;
                else
                    nxt_state <= `aincb0;
            end
            `aincb0: begin
                A <= A + 1;
                B <= 0;
                nxt_state <= `acond;
            end                      
            `acond: begin
                if (A < 8)
                    nxt_state <= `binc;
                else 
                    nxt_state <= `Output;     
            end
            `Output: begin
                nxt_state <= `ini;
                Z <= 1;
            end        
        endcase
    end                  
end

endmodule

