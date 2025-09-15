`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2025 10:41:26
// Design Name: 
// Module Name: DIV_SEQ_FPU
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


module DIV_SEQ_FPU(a, b,d,O,V);

parameter NEXP = 8;
parameter NSIG = 23;


input [NSIG + NEXP:0] a, b;

output  [NSIG + NEXP:0] d;
output  O,V;


wire  [NSIG + NEXP:0] result;

// Intermediate signals
    wire [31:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7;
    wire [31:0] x0, x1, x2, x3;
    wire [7:0]  Exponent; 
    wire [31:0] reciprocal;
    wire OM1, OM2, OM3, OM4, OM5, OM6, OM7;
    wire VM1, VM2, VM3, VM4, VM5, VM6, VM7;
    wire OA1, OA2, OA3, OA4;
    wire VA1, VA2, VA3, VA4; 

/*----Initial value----*/
MUL_FPU M1(.a({{1'b0,8'd126,b[22:0]}}),.b(32'h3ff0f0f1),.p(temp1),.OVERFLOW(OM1),.UNDERFLOW(VM1)); //verified

ADD_FPU A1(.a(32'h4034b4b5),.b({1'b1,temp1[30:0]}),.s(x0),.OVERFLOW(OA1),.UNDERFLOW(VA1));

/*----First Iteration----*/
MUL_FPU M2(.a({{1'b0,8'd126,b[22:0]}}),.b(x0),.p(temp2),.OVERFLOW(OM2),.UNDERFLOW(VM2));
ADD_FPU A2(.a(32'h40000000),.b({!temp2[31],temp2[30:0]}),.s(temp3),.OVERFLOW(OA2),.UNDERFLOW(VA2));
MUL_FPU M3(.a(x0),.b(temp3),.p(x1),.OVERFLOW(OM3),.UNDERFLOW(VM3));

/*----Second Iteration----*/
MUL_FPU M4(.a({1'b0,8'd126,b[22:0]}),.b(x1),.p(temp4),.OVERFLOW(OM4),.UNDERFLOW(VM4));
ADD_FPU A3(.a(32'h40000000),.b({!temp4[31],temp4[30:0]}),.s(temp5),.OVERFLOW(OA3),.UNDERFLOW(VA3));
MUL_FPU M5(.a(x1),.b(temp5),.p(x2),.OVERFLOW(OM5),.UNDERFLOW(VM5));

/*----Third Iteration----*/
MUL_FPU M6(.a({1'b0,8'd126,b[22:0]}),.b(x2),.p(temp6),.OVERFLOW(OM6),.UNDERFLOW(VM6));
ADD_FPU A4(.a(32'h40000000),.b({!temp6[31],temp6[30:0]}),.s(temp7),.OVERFLOW(OA4),.UNDERFLOW(VA4));
MUL_FPU M7(.a(x2),.b(temp7),.p(x3),.OVERFLOW(OM7),.UNDERFLOW(VM7));

/*----Reciprocal : 1/B----*/
assign Exponent = x3[30:23]+8'd126-b[30:23];
assign reciprocal = {b[31],Exponent,x3[22:0]};

/*----Multiplication A*1/B----*/
MUL_FPU M8(.a(a),.b(reciprocal),.p(result),.OVERFLOW(O),.UNDERFLOW(V));

assign d=result;
endmodule

