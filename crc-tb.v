/*
 * CRC Testbench Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

`timescale 1ns / 100ps

`include "crc-serial.v"
`include "crc32-serial-ll.v"
`include "crc-parallel.v"

module reflect #(
	parameter W = 32
) (
	input  wire [W-1:0] d,
	output wire [W-1:0] q
);
	genvar i;

	for (i = 0; i < W; i = i + 1) begin : reflect
		assign q[i] = d[W-1 - i];
	end
endmodule

module crc_tb;
	reg reset = 0, enable = 0, clk = 0, d;
	reg [7:0] D;

	initial begin
		# 3	reset = 1;
		# 5	reset = 0;
		# 52	$finish;
	end

	always
		# 2.5	clk = !clk;

	initial begin
		# 12	d = 0; D = 'hAA; enable = 1;
		# 5	d = 1;
		# 5	d = 0;
		# 5	d = 1;
		# 5	d = 0;
		# 5	d = 1;
		# 5	d = 0;
		# 5	d = 1;
		# 5	d = 0; enable = 0;
	end

	wire [31:0] a, na, b, rb;

	crc_serial #(32, 'hEDB88320) A (reset, enable, clk, d, a);
	assign na = ~a;

	crc32_serial_ll B (reset, enable, clk, d, b);
	reflect #(32) RB (b, rb);

	wire [31:0] p;

	crc_parallell #(8, 32, 'hEDB88320) P (reset, enable, clk, D, p);

	initial begin
		$monitor ("%t: %h, %h, %h, %h", $time, a, na, rb, p);
		$dumpfile ("crc-tb.vcd");
		$dumpvars (1, crc_tb);
	end
endmodule
