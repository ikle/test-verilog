#
# Verilog Samples
#
# Copyright (c) 2016-2018 Alexei A. Smekalkine <ikle@ikle.ru>
#
# SPDX-License-Identifier: BSD-2-Clause
#

TARGETS  = counter-tb.vcd

VC ?= iverilog

%.vvp: %.v
	$(VC) $(VFLAGS) -o $@ $<

%.vcd: %.vvp
	vvp $^

all: $(TARGETS)

clean:
	rm -f *.vvp $(TARGETS)

counter-tb.vcd: counter-tb.v counter.v
