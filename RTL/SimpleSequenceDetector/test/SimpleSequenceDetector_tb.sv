`timescale 1ns/1ps
// `PERIOD 20ns/1ps

import vunit_pkg::*;
`include "vunit_defines.svh"

module SimpleSequenceDetector_tb();
    localparam TOTAL_WORDS_COUNT = 100000;

    typedef logic logic_array[$];
    typedef enum {
        StIdle,
        St1,
        St10,
        St101,
        St1011,
        St10110
    } state;

    logic_array seq_array;
    logic_array expected_detected_array;

    bit clk = 0;
    bit resetn = 0;
    initial forever #20 clk = ~clk;
    
    logic input_seq;
    logic input_valid;
    logic output_detected;

    SimpleSequenceDetector sequenceDetector(
        .clk(clk),
        .resetn(resetn),
        .seq(input_seq),
        .valid(input_valid),
        .detected(output_detected)
    );

    function logic_array generate_random_seq();
        logic random_seed;
        logic_array random_seq;
        while (random_seq.size() < TOTAL_WORDS_COUNT) begin
            random_seed = $urandom_range(0, 2);
            case (random_seed)
                0: append_random_pattern(random_seq);
                1: append_base_pattern(random_seq);
                2: append_overlapping_pattern(random_seq);
            endcase
        end
        return random_seq;
    endfunction

    function logic_array append_random_pattern(logic_array seq_array);
        for (int i = 0; i < 5; i++) begin
            seq_array.push_back($urandom_range(0, 1));
        end
        return seq_array;
    endfunction

    function logic_array append_base_pattern(logic_array seq_array);
        seq_array.push_back(1);
        seq_array.push_back(0);
        seq_array.push_back(1);
        seq_array.push_back(1);
        seq_array.push_back(0);
        return seq_array;
    endfunction

    function logic_array append_overlapping_pattern(logic_array seq_array);
        seq_array.push_back(1);
        seq_array.push_back(1);
        seq_array.push_back(0);
        return seq_array;
    endfunction

    function automatic logic_array expect_detected_output(logic_array seq_array);
        logic current_seq_item;
        logic current_detected;

        state current_state = StIdle;
        state next_state = StIdle;
        
        logic_array expected_detected_array;
        
        while (seq_array.size()) begin
            current_seq_item = seq_array.pop_front();
            case (current_state)
                StIdle : begin
                    current_detected = 0;
                    next_state = (current_seq_item ? St1 : StIdle);
                end
                St1 : begin
                    current_detected = 0;
                    next_state = (current_seq_item ? St1 : St10);
                end
                St10 : begin
                    current_detected = 0;
                    next_state = (current_seq_item ? St101 : StIdle);
                end
                St101 : begin
                    current_detected = 0;
                    next_state = (current_seq_item ? St1011 : St10);
                end
                St1011 : begin
                    current_detected = !current_seq_item;
                    next_state = (current_seq_item ? St1 : St10110);
                end
                St10110 : begin
                    current_detected = 0;
                    next_state = (current_seq_item ? St101 : StIdle);
                end
                default : begin
                    current_detected = 0;
                    next_state = StIdle;
                end
            endcase
            expect_detected_output.push_back(current_detected);
        end

        return expected_detected_array;
    endfunction

    task drive_input(logic seq);
        input_seq <= seq;
        input_valid <= 1;
        @(posedge clk);
    endtask

    task check_output(logic current_expected_output);        
        @(posedge clk);
        assert (output_detected == current_expected_output) begin
            $display("seq: %h, detected: %h, expected_output: %h",
                        input_seq, output_detected, current_expected_output);
        end else $error("Operation wasn't done appropriately; output = %x, expected: %x", 
                                                                output_detected, current_expected_output);
    endtask

    `TEST_SUITE begin
        `TEST_CASE_SETUP begin
            resetn <= 0;
            repeat(6) @(posedge clk);
            resetn <= 1;
            repeat(6) @(posedge clk);
        end
        
        `TEST_CASE("random_test_with_back_pressure") begin
            seq_array = generate_random_seq();
            expected_detected_array = expect_detected_output(seq_array);

            for (int i = 0; i < TOTAL_WORDS_COUNT; i++) begin
                drive_input(seq_array.pop_front());
                check_output(expected_detected_array.pop_front());
            end
        end

        `TEST_CASE_CLEANUP begin
            $display("Making Cleanup....");
        end

        // `WATCHDOG(10000ns)
    end
endmodule
