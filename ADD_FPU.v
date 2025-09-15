`timescale 1ns / 1ps
module ADD_FPU(a, b, sum, OVERFLOW, UNDERFLOW);
    parameter NEXP = 8;  // Exponent size
    parameter NSIG = 23; // Significand size
    input [NEXP + NSIG : 0] a, b;
    output reg [NEXP + NSIG : 0] sum;
    output reg OVERFLOW, UNDERFLOW;

    reg [NEXP + NSIG : 0] s;
    reg signed [NEXP:0] exp;
    reg [NSIG:0] mantisa_a, mantisa_b;
    reg [NSIG+1:0] mantisa_out;
    reg [NSIG-1:0] mantisa_last;
    reg [4:0] shift_count;
     
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
     
        wire [LAST_FLAG-1:0] aFlags, bFlags;
    
    wire signed [NEXP+1:0] aExp, bExp;
    reg signed [NEXP+1:0] pExp, t1Exp, t2Exp;
    wire [NSIG:0] aSig, bSig;
    reg [NSIG:0] pSig, tSig;
     
     
    reg [NEXP+NSIG:0] pTmp;
    
    reg [LAST_FLAG-1:0] pFlags;

    reg pSign; 
     
    fp_class #(NEXP,NSIG) aClass(a, aExp, aSig, aFlags);
    fp_class #(NEXP,NSIG) bClass(b, bExp, bSig, bFlags);  
    integer i;

    
    
    
    always @ (*) begin
    if ((aFlags[SNAN] | bFlags[SNAN]) == 1'b1) begin
        pTmp = aFlags[SNAN] == 1'b1 ? a : b;
        pFlags[SNAN] = 1;
    end
    else if ((aFlags[QNAN] | bFlags[QNAN]) == 1'b1) begin
        pTmp = aFlags[QNAN] == 1'b1 ? a : b;
        pFlags[QNAN] = 1;
    end
    else if ((aFlags[INFINITY] | bFlags[INFINITY]) == 1'b1) begin
        pTmp = {pSign, {NEXP{1'b1}}, {NSIG{1'b0}}};
        pFlags[INFINITY] = 1;
    end
    else if ((aFlags[ZERO] | bFlags[ZERO]) == 1'b1 || (aFlags[SUBNORMAL] & bFlags[SUBNORMAL]) == 1'b1) begin
        pTmp = {pSign, {NEXP+NSIG{1'b0}}};
        pFlags[ZERO] = 1;
    end

    if (a[NEXP+NSIG-1:0] >= b[NEXP+NSIG-1:0]) begin
        mantisa_b = {1'b1, b[NSIG-1:0]} >> (a[NEXP+NSIG-1:NSIG] - b[NEXP+NSIG-1:NSIG]);
        mantisa_a = {1'b1, a[NSIG-1:0]};
        exp = a[NEXP+NSIG-1:NSIG];
        pSign = a[NEXP+NSIG];  // Assign sign of larger operand
    end else begin
        mantisa_a = {1'b1, a[NSIG-1:0]} >> (b[NEXP+NSIG-1:NSIG] - a[NEXP+NSIG-1:NSIG]);
        mantisa_b = {1'b1, b[NSIG-1:0]};
        exp = b[NEXP+NSIG-1:NSIG];
        pSign = b[NEXP+NSIG];  // Assign sign of larger operand
    end

    if (a[NEXP+NSIG] ^ b[NEXP+NSIG]) begin
        if (mantisa_a >= mantisa_b) begin
            mantisa_out = mantisa_a - mantisa_b;
            s[NEXP+NSIG] = pSign;  // Keep the sign of the larger operand
        end else begin
            mantisa_out = mantisa_b - mantisa_a;
            s[NEXP+NSIG] = pSign;  // Flip sign if b is larger
        end
    end else begin
        mantisa_out = mantisa_a + mantisa_b;
        s[NEXP+NSIG] = pSign;  // Assign sign based on larger absolute value
    end

    if (mantisa_out[NSIG+1] == 1) begin
        mantisa_last = mantisa_out[NSIG:1];
        exp = exp + 1;
    end else if (mantisa_out[NSIG] == 1) begin
        mantisa_last = mantisa_out[NSIG-1:0];
    end else begin
        shift_count = 0;
        while (mantisa_out[NSIG-shift_count] == 0 && shift_count < NSIG) begin
            shift_count = shift_count + 1;
        end
        mantisa_last = mantisa_out;
        
        for (i = 0; i < shift_count; i = i + 1) begin
            mantisa_last = mantisa_last << 1;
        end
        exp = exp - shift_count;
    end

    if (exp > ((1 << NEXP) - 2)) begin
        OVERFLOW = 1;
        UNDERFLOW = 0;
        s = { {NEXP{1'b1}}, mantisa_last };
    end else if (exp <= 0) begin
        OVERFLOW = 0;
        UNDERFLOW = 1;
        s = { {NEXP{1'b0}}, mantisa_last };
    end else begin
        OVERFLOW = 0;
        UNDERFLOW = 0;
        s = {exp[NEXP-1:0], mantisa_last};
    end
   if (pSign==1) begin 
       s[NEXP+NSIG]=1;
       sum=s;
       end
   else   begin    
       sum=s;
      end 
         
   
end
endmodule
