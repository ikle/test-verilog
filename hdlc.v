/*
 * HDLC Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

`include "fifo.v"

module hdlc_parser (
	input clk, in,
	output reg [7:0] q,
	output flush, mark, error
);
	reg [7:0] raw;
	wire shift, reset;
	wire [3:0] cnt;

	always @(posedge clk)
		raw <= {in, raw[7:1]};

	always @(posedge shift)
		q[7:0] <= {raw[7], q[7:1]};

	assign shift = ~clk & (raw[7:2] != 6'b011111);

	assign mark  = raw == 8'b01111110;
	assign error = raw[7:1] == 7'b1111111;

	counter_ff #(4) c (reset, 4'b0, ~shift, cnt);

	assign flush = cnt == 8;
	assign reset = mark | error | (flush & ~clk);
endmodule

module hdlc_rx #(
	parameter BUF_ORDER = 11, COUNT_ORDER = 4
)(
	input reset, clk, in,
	output [7:0] out, input get, output empty, input start
);
	wire [7:0] data;
	wire flush, mark, error, full;
	reg enable, avail;

	hdlc_parser parser (clk, in, data, flush, mark, error);

	always @(posedge reset or posedge mark)
		if (reset)
			enable <= 0;
		else
			enable <= 1;

	always @(posedge flush or negedge mark)
		if (flush)
			avail <= 1;
		else
			avail <= 0;

	pfifo #(8, BUF_ORDER, COUNT_ORDER) pipe (
		reset,
		data, enable & flush, full, avail & mark, full | error,
		out, get, empty, start
	);
endmodule
