module SimpleSequenceDetector(
    input clk,
    input resetn,

    input seq,
    input valid,
    output detected
);
    typedef enum {
        StIdle,
        St1,
        St10,
        St101,
        St1011,
        St10110
    } stete_e;

    state_e state_d, state_q;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state_q <= StIdle;
        end else begin
            state_q <= state_d;
        end
    end

    always_comb begin
        state_d = state_q;
        detected = 0;
        case (state_q)
            StIdle  : state_d = (seq ? St1    : StIdle );
            St1     : state_d = (seq ? St1    : St10   );
            St10    : state_d = (seq ? St101  : St10   );
            St101   : state_d = (seq ? St1011 : St101  );
            St1011  : state_d = (seq ? St1011 : St10110);
            default : state_d = StIdle;
        endcase
    end
endmodule