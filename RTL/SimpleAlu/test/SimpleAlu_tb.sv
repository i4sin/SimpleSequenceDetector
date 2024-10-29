`timescale 10ns/1ns
`PERIOD 20ns

import vunit_pkg::*;

`include "vunit_defines.svh"

module SimpleAlu_tb();
    localparam TOTAL_WORDS_COUNT = 100000;

    typedef logic [31:0] data_logic_array[$];
    typedef logic [2:0]  op_logic_array  [$];
    typedef logic z_array[$];

    data_logic_array input_a_array;
    data_logic_array input_b_array;
    data_logic_array expected_output_array;

    op_logic_array op_array;

    logic expexted_output_z_array[$];

    bit clk = 0;
    bit resetn = 0;
    initial forever #10 clk = ~clk;
    
    logic [31:0] input_A;
    logic [31:0] input_B;
    logic [2:0]  input_OP;
    logic [31:0] output_X;
    logic        output_Z;

    SimpleAlu uut(
        .clk(clk),
        .resetn(resetn),
        .A(input_A),
        .B(input_B),
        .OP(input_OP),
        .X(output_X),
        .Z(output_Z)
    );

    function data_logic_array generate_random_data();
        logic [31:0] random_data[TOTAL_WORDS_COUNT];
        foreach (random_data[i]) begin
            random_data[i] = $urandom();
        end
        return random_data;
    endfunction

    function op_logic_array generate_random_op();
        logic [2:0] random_op[TOTAL_WORDS_COUNT];
        foreach (random_op[i]) begin
            random_op[i] = $urandom_range(0,6);
        end
        return random_op;
    endfunction

    function data_logic_array calculate_expected_output(logic [31:0] input_a_array[$],
                                                        logic [31:0] input_b_array[$],
                                                        logic [2:0] op_array[$]);
        logic [31:0] expected_outputs[$];
        for (int i = 0; i < TOTAL_WORDS_COUNT; i++) begin
            case (op_array[i])
                3'b000 : expected_outputs.push_back(input_a_array[i] +  input_b_array[i]);
                3'b001 : expected_outputs.push_back(input_a_array[i] -  input_b_array[i]);
                3'b010 : expected_outputs.push_back(~(input_a_array[i] | input_b_array[i]));
                3'b011 : expected_outputs.push_back(input_a_array[i] |  input_b_array[i]);
                3'b100 : expected_outputs.push_back(~(input_a_array[i] & input_b_array[i]));
                3'b101 : expected_outputs.push_back(input_a_array[i] &  input_b_array[i]);
                3'b110 : expected_outputs.push_back(input_a_array[i] ~^ input_b_array[i]);
            endcase
        end
        return expected_outputs;
    endfunction

    function z_array calculate_expected_z(logic [31:0] expected_output_array[$]);
        foreach (expected_output_array[i]) begin
            expexted_output_z_array[i] = (expected_output_array[i] == 0);
        end
        return expexted_output_z_array;
    endfunction

    function void check_output(logic [31:0] current_input_A,
                                logic [31:0] current_input_B,
                                logic [31:0] current_expected_output,
                                logic current_expected_z);
        assert (output_X == current_expected_output)
            else $error("Operation wasn't done appropriately; output = %x, expected: %x", 
                                                                output_X, current_expected_output);
        assert ((output_X == 0 && output_Z) || (output_X != 0 && !output_Z))
            else $error("Z flag isn't assigned correctly! output_z = %b, current_expected_z = %b", output_Z, current_expected_z);
    endfunction

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            input_a_array = generate_random_data();
            input_b_array = generate_random_data();
            op_array = generate_random_op();

            expected_output_array = calculate_expected_output(input_a_array, input_b_array, op_array);

            expexted_output_z_array = calculate_expected_z(expected_output_array);

            for (int i = 0; i < TOTAL_WORDS_COUNT; i++) begin
                input_A = input_a_array.pop_front();
                input_B = input_b_array.pop_front();
                input_OP = op_array.pop_front();

                check_output(input_A, input_B, expected_output_array.pop_front(), expexted_output_z_array.pop_front());
            end
        end
    end
endmodule