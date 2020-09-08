/*
 * FIFO Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

`include "counter.v"

module fifo_state #(
	parameter W = 8		// must be ≥ 2
)(
	input reset,
	input [W - 1:0] w, r,	// gray coded write and read pointers
	output empty, full
);
	wire x, y, gs, gr;
	reg up;

//	// revert Gray Code and return two most significant bits
//	function [1:0] dgt (input [W - 1:0] x);
//		dgt = (x >> (W-2)) ^ (x >> (W-1));
//	endfunction
//
//	assign gs = $signed (dgt(w) - dgt(r)) == 2'b11;  	// -1
//	assign gr = $signed (dgt(w) - dgt(r)) == 1 || reset;	// ← works

	assign x = w[W-2] ^ r[W-1];
	assign y = w[W-1] ^ r[W-2];

	assign gs = ~x & y;
	assign gr = x & ~y || reset;

	always @(posedge gr or posedge gs)
		if (gr)
			up <= 0;
		else
			up <= 1;

	assign empty = ~up & (w == r);
	assign full  =  up & (w == r);
endmodule

module fifo #(
	parameter W = 8, ORDER = 4
)(
	input reset,
	input [W - 1:0] in, input put, output full,
	output reg [W - 1:0] out, input get, output empty
);
	reg [W - 1:0] ram [2**ORDER - 1:0];
	wire [ORDER - 1:0] w, r;

	gray_counter #(ORDER) cw (reset, {ORDER{1'b0}}, ~put, w);
	gray_counter #(ORDER) cr (reset, {ORDER{1'b0}}, ~get, r);

	fifo_state #(ORDER) state (reset, w, r, empty, full);

	always @(posedge put)
		ram[w] <= in;

	always @(posedge get)
		out <= ram[r];
endmodule

module pfifo #(
	parameter W = 8, ORDER = 4, COUNT_ORDER = 2
)(
	input reset,
	input [W - 1:0] in, input put, output full,  input commit, drop,
	output reg [W - 1:0] out, input get, output empty,  input start
);
	reg [W - 1:0] ram [2**ORDER - 1:0];
	wire [ORDER - 1:0] w, r, tail;  // read packet tail
	reg [ORDER - 1:0] head;  // write packet head
	wire tails_full, bufs_full, tails_empty, bufs_empty;

	fifo #(ORDER, COUNT_ORDER) tails (reset, w, commit, tails_full,
					  tail, start, tails_empty);

	always @(posedge reset or posedge commit)
		if (reset)
			head <= 0;
		else
			head <= w;

	gray_counter #(ORDER) cw (reset | drop, head, ~put, w);
	gray_counter #(ORDER) cr (reset, {ORDER{1'b0}}, ~get, r);

	fifo_state #(ORDER) state (reset, w, r, bufs_empty, bufs_full);

	assign full  = tails_full | bufs_full;
	assign empty = (tails_empty | bufs_empty) && (r != tail);

	always @(posedge put)
		ram[w] <= in;

	always @(posedge get)
		out <= ram[r];
endmodule
