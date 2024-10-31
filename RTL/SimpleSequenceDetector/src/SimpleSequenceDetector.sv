module SimpleSequenceDetector(
    input clk,
    input resetn,

    input seq,
    input valid,
    output reg detected
);
    typedef enum {
        StIdle,
        St1,
        St10,
        St101,
        St1011,
        St10110
    } state;

    state state_d, state_q;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state_q <= StIdle;
        end else begin
            state_q <= state_d;
        end
    end

    always_comb begin
        state_d = state_q;
        if (valid) begin
            case (state_q)
                StIdle : begin
                    detected = 0;
                    state_d = (seq ? St1 : StIdle );
                end
                St1 : begin
                    detected = 0;
                    state_d = (seq ? St1 : St10   );
                end
                St10 : begin
                    detected = 0;
                    state_d = (seq ? St101 : StIdle );
                end
                St101 : begin
                    detected = 0;
                    state_d = (seq ? St1011 : St10   );
                end
                St1011 : begin
                    detected = !seq;
                    state_d = (seq ? St1 : St10110);
                end
                St10110 : begin
                    detected = 0;
                    state_d = (seq ? St101 : StIdle );
                end
                default : begin
                    detected = 0;
                    state_d = StIdle;
                end
            endcase
        end else detected = 0;
    end
endmodule
