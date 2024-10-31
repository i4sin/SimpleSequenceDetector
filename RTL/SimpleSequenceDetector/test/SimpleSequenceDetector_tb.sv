`timescale 1ns/1ps
// `PERIOD 20ns/1ps

import vunit_pkg::*;
`include "vunit_defines.svh"

module SimpleSequenceDetector_tb();
    localparam TOTAL_WORDS_COUNT = 100000;

    typedef logic logic_array[$];

    logic_array seq_array;
    logic_array expexted_detected_array;

    bit clk = 0;
    bit resetn = 0;
    initial forever #(10 / 2) clk = ~clk;
    
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

    task drive_input();
        //
        @(posedge clk);
    endtask

    task check_output();        
        @(posedge clk);
        // assert (output_X == current_expected_output) begin
        //     $display("A: %h, B: %h, OP: %b, X: %h, expected_X: %h, Z: %b, expected_Z: %b",
        //                 input_A, input_B, input_OP, output_X, current_expected_output, output_Z, current_expected_z);
        // end else $error("Operation wasn't done appropriately; output = %x, expected: %x", 
        //                                                         output_X, current_expected_output);
    endtask

    `TEST_SUITE begin
        `TEST_CASE_SETUP begin
            resetn <= 0;
            repeat(6) @(posedge clk);
            resetn <= 1;
            repeat(6) @(posedge clk);
        end
        
        `TEST_CASE("random_test_without_pressure") begin
            seq_array = generate_random_seq();
            expexted_detected_array = calculate_expected_output();

            for (int i = 0; i < TOTAL_WORDS_COUNT; i++) begin
                drive_input();
                check_output();
            end
        end

        `TEST_CASE_CLEANUP begin
            $display("Making Cleanup....");
        end
    end
endmodule
