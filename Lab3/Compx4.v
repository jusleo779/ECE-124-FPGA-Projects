module compx4(
    input [3:0] hex_A, hex_B,
    output agtb, 
    output altb,
    output aeqb
);
    wire [3:0] AGTB; 
    wire [3:0] ALTB;
    wire [3:0] AEQB;

    compx1 u1(
        .A(hex_A[0]),
        .B(hex_B[0]),
        .AgtB(AGTB[0]),
        .AltB(ALTB[0]),
        .AeqB(AEQB[0])

    );
    compx1 u2(
        .A(hex_A[1]),
        .B(hex_B[1]),
        .AgtB(AGTB[1]),
        .AltB(ALTB[1]),
        .AeqB(AEQB[1])
    );
    compx1 u3(
        .A(hex_A[2]),
        .B(hex_B[2]),
        .AgtB(AGTB[2]),
        .AltB(ALTB[2]),
        .AeqB(AEQB[2])
    );
    compx1 u4(
        .A(hex_A[3]),
        .B(hex_B[3]),
        .AgtB(AGTB[3]),
        .AltB(ALTB[3]),
        .AeqB(AEQB[3])
    );

    assign agtb = AGTB[3] | (AEQB[3] & AGTB[2]) | (AEQB[3] & AEQB[2] & AGTB[1]) | (AEQB[3] & AEQB[2] & AEQB[1] & AGTB[0]);
    assign altb = ALTB[3] | (AEQB[3] & ALTB[2]) | (AEQB[3] & AEQB[2] & ALTB[1]) | (AEQB[3] & AEQB[2] & AEQB[1] & ALTB[0]);
    assign aeqb = (AEQB[3] & AEQB[2] & AEQB[1] & AEQB[0]);

endmodule
