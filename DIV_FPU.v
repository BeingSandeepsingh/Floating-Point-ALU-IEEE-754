`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2025 01:05:43
// Design Name: 
// Module Name: DIV_FPU
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

module DIV_FPU(a, b, q, OVERFLOW, UNDERFLOW);
    parameter NEXP = 8;
    parameter NSIG = 23;
    input [NEXP+NSIG:0] a, b;
    output [NEXP+NSIG:0] q;
    output OVERFLOW, UNDERFLOW;
    `include "ieee-754-flags.vh"

    reg [LAST_FLAG-1:0] qFlags;

    wire signed [NEXP+1:0] aExp, bExp;
    reg signed [NEXP+1:0] qExp, tExp;
    wire [NSIG:0] aSig, bSig;
    reg [NSIG:0] qSig;

    reg [NEXP+NSIG:0] qTmp;

    wire [LAST_FLAG-1:0] aFlags, bFlags;

    reg qSign;

    fp_class #(NEXP,NSIG) aClass(a, aExp, aSig, aFlags);
    fp_class #(NEXP,NSIG) bClass(b, bExp, bSig, bFlags);
    
    
    

    always @(*)
    begin
        qSign = a[NEXP+NSIG] ^ b[NEXP+NSIG];
        qTmp = {qSign, {NEXP{1'b1}}, 1'b0, {NSIG-1{1'b1}}};
        qFlags = 6'b000000;

        if ((aFlags[SNAN] | bFlags[SNAN]) == 1'b1)
        begin
            qTmp = aFlags[SNAN] == 1'b1 ? a : b;
            qFlags[SNAN] = 1;
        end
        else if ((aFlags[QNAN] | bFlags[QNAN]) == 1'b1)
        begin
            qTmp = aFlags[QNAN] == 1'b1 ? a : b;
            qFlags[QNAN] = 1;
        end
        else if (bFlags[ZERO] == 1'b1)
        begin
            qTmp = {qSign, {NEXP{1'b1}}, 1'b1, {NSIG-1{1'b0}}}; // qNaN
            qFlags[QNAN] = 1;
        end
        else if (aFlags[ZERO] == 1'b1)
        begin
            qTmp = {qSign, {NEXP+NSIG{1'b0}}};
            qFlags[ZERO] = 1;
        end
        else if (aFlags[INFINITY] == 1'b1 && bFlags[INFINITY] == 1'b1)
        begin
            qTmp = {qSign, {NEXP{1'b1}}, 1'b1, {NSIG-1{1'b0}}}; // qNaN
            qFlags[QNAN] = 1;
        end
        else if (aFlags[INFINITY] == 1'b1)
        begin
            qTmp = {qSign, {NEXP{1'b1}}, {NSIG{1'b0}}};
            qFlags[INFINITY] = 1;
        end
        else if (bFlags[INFINITY] == 1'b1)
        begin
            qTmp = {qSign, {NEXP+NSIG{1'b0}}};
            qFlags[ZERO] = 1;
        end
        else
        begin
            tExp = aExp - bExp;
            qSig = (aSig << NSIG) / bSig;

            if (tExp < (EMIN - NSIG))
            begin
                qTmp = {qSign, {NEXP+NSIG{1'b0}}};
                qFlags[ZERO] = 1;
            end
            else if (tExp < EMIN)
            begin
                qSig = qSig >> (EMIN - tExp);
                qTmp = {qSign, {NEXP{1'b0}}, qSig[NSIG-1:0]};
                qFlags[SUBNORMAL] = 1;
            end
            else if (tExp > EMAX)
            begin
                qTmp = {qSign, {NEXP{1'b1}}, {NSIG{1'b0}}};
                qFlags[INFINITY] = 1;
            end
            else
            begin
                qExp = tExp + BIAS;
                qTmp = {qSign, qExp[NEXP-1:0], qSig[NSIG-1:0]};
                qFlags[NORMAL] = 1;
            end
        end
    end

    assign q = qTmp;
    assign OVERFLOW = qFlags[INFINITY];
    assign UNDERFLOW = qFlags[ZERO] | qFlags[SUBNORMAL];

endmodule
