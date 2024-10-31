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

    task drive_base_pattern();
        drive_input(1);
        drive_input(0);
        drive_overlapping_pattern();
    endtask

    task drive_overlapping_pattern();
        drive_input(1);
        drive_input(1);
        drive_input(0);
    endtask

    function logic_array generate_random_seq();
        logic random_seed;
        logic_array random_seq;
        while (random_seq.size() < TOTAL_WORDS_COUNT) begin
            random_seed = $urandom_range(0, 2);
            case (random_seed)
                0: random_seq = append_random_pattern(random_seq);
                1: random_seq = append_base_pattern(random_seq);
                2: random_seq = append_overlapping_pattern(random_seq);
            endcase
        end
        $display("random_seq:\n %p", random_seq);
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
        state current_state = StIdle;
        state next_state = StIdle;

        logic current_detected;

        logic_array expected_detected_array;
        
        foreach (seq_array[i]) begin
            case (current_state)
                StIdle : begin
                    current_detected = 0;
                    next_state = (seq_array[i] ? St1 : StIdle);
                end
                St1 : begin
                    current_detected = 0;
                    next_state = (seq_array[i] ? St1 : St10);
                end
                St10 : begin
                    current_detected = 0;
                    next_state = (seq_array[i] ? St101 : StIdle);
                end
                St101 : begin
                    current_detected = 0;
                    next_state = (seq_array[i] ? St1011 : St10);
                end
                St1011 : begin
                    current_detected = !seq_array[i];
                    next_state = (seq_array[i] ? St1 : St10110);
                end
                St10110 : begin
                    current_detected = 0;
                    next_state = (seq_array[i] ? St101 : StIdle);
                end
                default : begin
                    current_detected = 0;
                    next_state = StIdle;
                end
            endcase
            current_state = next_state;
            expected_detected_array.push_back(current_detected);
        end
        $display("expected_detected_array:\n %p", expected_detected_array);
        return expected_detected_array;
    endfunction

    task drive_input(logic seq);
        input_seq <= seq;
        input_valid <= 1;
        @(posedge clk);
    endtask

    task check_output(logic current_expected_output);        
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
        
        `TEST_CASE("direct_base_test") begin
            drive_base_pattern();
            check_output(1);
        end

        `TEST_CASE("direct_overlapping_test") begin
            automatic int overlapping_tests_count = $urandom_range(1, 10);
            drive_base_pattern();
            check_output(1);
            for (int i = 0; i < overlapping_tests_count; i++) begin
                drive_overlapping_pattern();
                check_output(1);
            end
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
