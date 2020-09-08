#
# Verilog Samples
#
# Copyright (c) 2016-2018 Alexei A. Smekalkine <ikle@ikle.ru>
#
# SPDX-License-Identifier: BSD-2-Clause
#

TARGETS  = counter-tb.vcd crc-tb.vcd fifo-tb.vcd hdlc-tb.vcd

VC ?= iverilog

%.vvp: %.v
	$(VC) $(VFLAGS) -o $@ $<

%.vcd: %.vvp
	vvp $^

all: $(TARGETS)

clean:
	rm -f *.vvp $(TARGETS)

counter-tb.vcd: counter-tb.v counter.v
crc-tb.vcd: crc-tb.v crc-serial.v crc32-serial-ll.v crc-parallel.v
fifo-tb.vcd: fifo-tb.v fifo.v counter.v fifo-tb.dat
hdlc-tb.vcd: hdlc-tb.v hdlc.v fifo.v counter.v hdlc-tb.dat
