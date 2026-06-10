module compx1 (
    input A, B,
    output AgtB,
    output AltB,
    output AeqB
);

    assign AeqB = ~(A ^ B);     // A = B
    assign AgtB = A & ~B;       // A > B
    assign AltB = ~A & B;       // A < B
	 
endmodule
