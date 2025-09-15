`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2025 00:56:51
// Design Name: 
// Module Name: MUL_FPU
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

module MUL_FPU(a, b, p, OVERFLOW, UNDERFLOW);
    parameter NEXP = 8;
    parameter NSIG = 23;
    input [NEXP+NSIG:0] a, b;
    output [NEXP+NSIG:0] p;
    output OVERFLOW, UNDERFLOW;
//    `include "ieee-754-flags.vh"
parameter NORMAL = 0;
parameter SUBNORMAL = NORMAL + 1;
parameter ZERO = SUBNORMAL + 1;
parameter INFINITY = ZERO + 1;
parameter QNAN = INFINITY + 1;
parameter SNAN = QNAN + 1;
parameter LAST_FLAG = SNAN + 1;

parameter BIAS = ((1 << (NEXP - 1)) - 1); // IEEE 754, section 3.3
parameter EMAX = BIAS; // IEEE 754, section 3.3
parameter EMIN = (1 - EMAX); // IEEE 754,

    reg [LAST_FLAG-1:0] pFlags;

    wire signed [NEXP+1:0] aExp, bExp;
    reg signed [NEXP+1:0] pExp, t1Exp, t2Exp;
    wire [NSIG:0] aSig, bSig;
    reg [NSIG:0] pSig, tSig;

    reg [NEXP+NSIG:0] pTmp;

    wire [2*NSIG+1:0] rawSignificand;

    wire [LAST_FLAG-1:0] aFlags, bFlags;

    reg pSign;

    fp_class #(NEXP,NSIG) aClass(a, aExp, aSig, aFlags);
    fp_class #(NEXP,NSIG) bClass(b, bExp, bSig, bFlags);

    assign rawSignificand = aSig * bSig;

    always @(*)
    begin
        pSign = a[NEXP+NSIG] ^ b[NEXP+NSIG];
        pTmp = {pSign, {NEXP{1'b1}}, 1'b0, {NSIG-1{1'b1}}};
        pFlags = 6'b000000;

        if ((aFlags[SNAN] | bFlags[SNAN]) == 1'b1)
        begin
            pTmp = aFlags[SNAN] == 1'b1 ? a : b;
            pFlags[SNAN] = 1;
        end
        else if ((aFlags[QNAN] | bFlags[QNAN]) == 1'b1)
        begin
            pTmp = aFlags[QNAN] == 1'b1 ? a : b;
            pFlags[QNAN] = 1;
        end
        else if ((aFlags[INFINITY] | bFlags[INFINITY]) == 1'b1)
        begin
            if ((aFlags[ZERO] | bFlags[ZERO]) == 1'b1)
            begin
                pTmp = {pSign, {NEXP{1'b1}}, 1'b1, {NSIG-1{1'b0}}}; // qNaN
                pFlags[QNAN] = 1;
            end
            else
            begin
                pTmp = {pSign, {NEXP{1'b1}}, {NSIG{1'b0}}};
                pFlags[INFINITY] = 1;
            end
        end
        else if ((aFlags[ZERO] | bFlags[ZERO]) == 1'b1 || (aFlags[SUBNORMAL] & bFlags[SUBNORMAL]) == 1'b1)
        begin
            pTmp = {pSign, {NEXP+NSIG{1'b0}}};
            pFlags[ZERO] = 1;
        end
        else
        begin
            t1Exp = aExp + bExp;

            if (rawSignificand[2*NSIG+1] == 1'b1)
            begin
                tSig = rawSignificand[2*NSIG+1:NSIG+1];
                t2Exp = t1Exp + 1;
            end
            else
            begin
                tSig = rawSignificand[2*NSIG:NSIG];
                t2Exp = t1Exp;
            end

            if (t2Exp < (EMIN - NSIG))
            begin
                pTmp = {pSign, {NEXP+NSIG{1'b0}}};
                pFlags[ZERO] = 1;
            end
            else if (t2Exp < EMIN)
            begin
                pSig = tSig >> (EMIN - t2Exp);
                pTmp = {pSign, {NEXP{1'b0}}, pSig[NSIG-1:0]};
                pFlags[SUBNORMAL] = 1;
            end
            else if (t2Exp > EMAX)
            begin
                pTmp = {pSign, {NEXP{1'b1}}, {NSIG{1'b0}}};
                pFlags[INFINITY] = 1;
            end
            else
            begin
                pExp = t2Exp + BIAS;
                pSig = tSig;
                pTmp = {pSign, pExp[NEXP-1:0], pSig[NSIG-1:0]};
                pFlags[NORMAL] = 1;
            end
        end
    end

    assign p = pTmp;
    assign OVERFLOW = pFlags[INFINITY];
    assign UNDERFLOW = pFlags[ZERO] | pFlags[SUBNORMAL];

endmodule

