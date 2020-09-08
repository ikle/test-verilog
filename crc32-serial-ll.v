/*
 * CRC32 serial low-level (non-inverted)
 *
 * Copyright (c) 2017-2018 Alexei A. Smekalkine <ikle@ikle.ru>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

module crc32_serial_ll (
	input reset, enable, clk, d,
	output reg [31:0] q
);
	wire c;

	assign c = q[31] ^ d;

	always @(posedge clk)
		if (reset)
			q <= 32'hFFFFFFFF;
		else
		if (enable) begin
			// 7
			q[0]  <= 0     ^ c;
			q[1]  <= q[0]  ^ c;
			q[2]  <= q[1]  ^ c;
			q[3]  <= q[2];
			// b
			q[4]  <= q[3]  ^ c;
			q[5]  <= q[4]  ^ c;
			q[6]  <= q[5];
			q[7]  <= q[6]  ^ c;
			// d
			q[8]  <= q[7]  ^ c;
			q[9]  <= q[8];
			q[10] <= q[9]  ^ c;
			q[11] <= q[10] ^ c;
			// 1
			q[12] <= q[11] ^ c;
			q[13] <= q[12];
			q[14] <= q[13];
			q[15] <= q[14];
			// 1
			q[16] <= q[15] ^ c;
			q[17] <= q[16];
			q[18] <= q[17];
			q[19] <= q[18];
			// c
			q[20] <= q[19];
			q[21] <= q[20];
			q[22] <= q[21] ^ c;
			q[23] <= q[22] ^ c;
			// 4
			q[24] <= q[23];
			q[25] <= q[24];
			q[26] <= q[25] ^ c;
			q[27] <= q[26];
			// 0
			q[28] <= q[27];
			q[29] <= q[28];
			q[30] <= q[29];
			q[31] <= q[30];
		end
endmodule
