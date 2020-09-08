/*
 * Counter Samples Testbench
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

`timescale 1ns / 100ps

`include "counter.v"

module counter_tb;
	reg reset = 0, clk = 0;

	/* make a reset that pulses twice */
	initial begin
		# 17 reset = 1;
		# 11 reset = 0;
		# 29 reset = 1;
		# 11 reset = 0;
		# 170 $finish;
	end

	always
		#5 clk = !clk;

	wire [7:0] value;
	counter_alu #(8) c1 (reset, 8'b0, clk, value);

	wire [9:0] value_2;
	counter_alu #(10) c2 (reset, 10'b0, clk, value_2);

	wire [3:0] value_ff;
	counter_ff #(4) c_ff (reset, 4'b0, clk, value_ff);

	wire [3:0] gray_value;
	gray_counter #(4) gc (reset, 4'b0, ~clk, gray_value);

	initial begin
		$monitor ("%t: %h, %h, %h, %b", $time,
			  value, value_2, value_ff, gray_value);

		$dumpfile ("counter-tb.vcd");
		$dumpvars (1, counter_tb);
	end
endmodule
