/*
 * Serial CRC Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

module crc_serial #(
	parameter W = 32, P = 'hEDB88320  // LSB-first CRC32 code
) (
	input reset, enable, clk, d,
	output reg [W-1:0] q
);
//	parameter W = 4;
//	parameter P = 'hC;		// LSB CRC-4-ITU

	always @(posedge reset, posedge clk)
		if (reset)
			q <= ~0;
		else if (enable)
			q <= (q >> 1) ^ ((q[0] ^ d) ? P : 0);
endmodule
