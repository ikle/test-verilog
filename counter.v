/*
 * Counter Samples
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

module counter_alu #(
	parameter W = 4
)(
	input load, input [W-1:0] in,
	input clk, output reg [W-1:0] q
);
	always @(posedge load or posedge clk)
		if (load)
			q <= in;
		else
			q <= q + 1;
endmodule

module counter_ff #(
	parameter W = 4
)(
	input load, input [W-1:0] in,
	input clk, output reg [W-1:0] q
);
	genvar i;

	always @(posedge load or posedge clk)
		if (load)
			q[0] <= in[0];
		else
			q[0] <= ~q[0];

	for (i = 1; i < W; i = i + 1)
		always @(posedge load or negedge q[i - 1])
			if (load)
				q[i] <= in[i];
			else
				q[i] <= ~q[i];
endmodule

/*
 * gray code inverse function
 */
module de_gray #(
	parameter W = 4
)(
	input [W-1:0] in,
	output [W-1:0] q
);
	genvar i;

	assign q[W-1] = in[W-1];

	for (i = W-2; i >= 0; i = i - 1)
		assign q[i] = q[i+1] ^ in[i];
endmodule

module gray_counter #(
	parameter W = 4
)(
	input load, input [W-1:0] in,
	input clk, output reg [W-1:0] q
);
	wire [W-1:0] value, next;

	de_gray #(W) dg (q, value);
	assign next = value + 1;

	always @(posedge load or posedge clk)
		if (load)
			q <= in;
		else
			q <= next ^ (next >> 1);
endmodule
