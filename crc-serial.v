/*
 * Serial CRC Module
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/*
 * Serial CRC module, CRC-32 by default
 *
 * Polinomial specified in LSB-first order (reversed).
 *
 * CRC-4-ITU	(4,  'hC)
 * CRC-16-CCITT	(16, 'h8408)
 * CRC-32	(32, 'hEDB88320)
 * CRC-32C	(32, 'h82F63B78)
 */
module crc_serial #(
	parameter W = 32, P = 'hEDB88320  // LSB-first CRC-32 code
) (
	input reset, enable, clk, d,
	output reg [W-1:0] q
);
	always @(posedge reset, posedge clk)
		if (reset)
			q <= ~0;
		else if (enable)
			q <= (q >> 1) ^ ((q[0] ^ d) ? P : 0);
endmodule
