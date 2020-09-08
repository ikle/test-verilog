/*
 * FIFO Testbench Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

`timescale 1ns / 100ps

`include "fifo.v"

module fifo_tb;
	reg reset, clk1 = 0, clk2 = 0;
	integer i = 0, j = 0;
	reg [7:0] in, data [0:17];

	initial $readmemh ("fifo-tb.dat", data);

	initial begin
		# 0.5	reset <= 1; //in <= data[0]; i <= i + 1;
		# 1.8	reset <= 0;
		# 220	$finish;
	end

	always
		# 2.5	clk1 <= !clk1;

	always
		# 3.9	clk2 <= !clk2;

	wire [7:0] out;
	wire full, empty;
	reg put = 0, get = 0;

	always @(posedge clk1)
		if (!full && $time > 5 && i < 18) begin
			put <= 1;
			i <= i + 1;
		end

	always @(negedge clk1) begin
		put <= 0;

		if (i < 18)
			in <= data[i];
	end

	always @(posedge clk2)
		if (!empty && $time > 70 && j < 18)
			get <= 1;

	always @(negedge clk2)
		if (get && j < 18) begin
			get <= 0;
			j <= j + 1;

			if (data[j] != out)
				$display ("%d: %h ≠ %h", j, data[j], out);
		end

	fifo #(8, 3) q (reset, in, put, full, out, get, empty);

	initial begin
//		$monitor ("%t: %h, %h | %h %h %h",
//			  $time, q.w, q.r,
//			  q.state.gs, q.state.gr, q.state.up);
		$dumpfile ("fifo-tb.vcd");
		$dumpvars (1, fifo_tb);
	end
endmodule
