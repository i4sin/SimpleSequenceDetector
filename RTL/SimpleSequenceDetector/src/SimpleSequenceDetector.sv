module SimpleSequenceDetector(
    input clk,
    input resetn,
    input [31:0] A,
    input [31:0] B,
    input [2:0] OP,
    output [31:0] X,
    output Z
);
    logic [31:0] output_d, output_q;

    assign Z = (X == 0);
    assign X = output_q;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            output_q <= 0;
        end else begin
            output_q <= output_d;
        end
    end

    always_comb begin
        output_d = output_q;
        case (OP)
            3'b000 : output_d = A + B;
            3'b001 : output_d = A - B;
            3'b010 : output_d = ~(A | B);
            3'b011 : output_d = A | B;
            3'b100 : output_d = ~(A & B);
            3'b101 : output_d = A & B;
            3'b110 : output_d = A ~^ B;
            default: output_d = 0;
        endcase
    end
endmodule