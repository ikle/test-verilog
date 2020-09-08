/*
 * Parallel CRC Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

module crc_parallell #(
	parameter H = 8, W = 32, P = 'hEDB88320  // LSB CRC-32 by default

) (
	input reset, enable, clk,
	input [H-1:0] d,
	output reg [W-1:0] q
);
	// to eat one bit
	function [W-1:0] step (input [W-1:0] acc, d);
		step = (acc >> 1) ^ ((acc[0] ^ d) ? P : 0);
	endfunction

	// eat all bits
	genvar i;
	wire [W-1:0] acc [0:H];

	assign acc[0] = q;

	for (i = 1; i <= H; i = i + 1)
		assign acc[i] = step (acc[i-1], d[i-1]);

	// latch result
	always @(posedge reset, posedge clk)
		if (reset)
			q <= ~0;
		else if (enable)
			q <= acc[H];
endmodule
