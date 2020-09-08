/*
 * HDLC Testbench Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

`timescale 1ns / 100ps

`include "hdlc.v"

module hdlc_tb;
	reg clk = 0, in;
	integer i = 0;
	reg data[0:63];

	initial $readmemb ("hdlc-tb.dat", data);

	always
		# 2.5 clk = !clk;

	always @(posedge clk)
		if (i == 63)
			$finish;
		else
			i <= i + 1;

	always @(negedge clk)
		in <= data[i];

	wire [7:0] q;
	wire flush, mark, error;

	hdlc_parser parser (clk, in, q, flush, mark, error);

	always @(posedge mark)
		$display ("%t: mark", $time);

	always @(posedge flush)
		$display ("%t: %h", $time, q);

	initial begin
//		$monitor ("%t: %h, %h", $time, clk, in);
		$dumpfile ("hdlc-tb.vcd");
		$dumpvars (1, hdlc_tb);
	end
endmodule
