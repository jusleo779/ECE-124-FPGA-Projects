 module full_adder_1bit(
    input A, B,
    input carry_in,
    output carry_out, sum_out
 );
    wire half_sum_out, half_carry_out;

    assign half_sum_out = A ^ B;
    assign half_carry_out = A & B;
    
    assign carry_out = half_carry_out | (half_sum_out & carry_in);
    assign sum_out = half_sum_out ^ carry_in;
    
 endmodule

 module full_adder_4bit(
    input[3:0] A, 
    input[3:0] B,
    input carry_in,
    output carry_out,
    output [3:0] hex_sum

 );
    wire c1, c2, c3;
    full_adder_1bit FA0 (
        .A(A[0]),
        .B(B[0]),
        .carry_in(carry_in),
        .carry_out(c1),
        .sum_out(hex_sum[0])
    );
    full_adder_1bit FA1 (
        .A(A[1]),
        .B(B[1]),
        .carry_in(c1),
        .carry_out(c2),
        .sum_out(hex_sum[1])
    );
    full_adder_1bit FA2 (
        .A(A[2]),
        .B(B[2]),
        .carry_in(c2),
        .carry_out(c3),
        .sum_out(hex_sum[2])
    );
    full_adder_1bit FA3 (
        .A(A[3]),
        .B(B[3]),
        .carry_in(c3),
        .carry_out(carry_out),
        .sum_out(hex_sum[3])
    );
 endmodule