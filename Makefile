.RECIPEPREFIX = >
.PHONY: all lean gen sim syn wave clean

all: lean gen sim

lean:
> lake build

gen: lean
> lake exe gen

sim: gen
> iverilog -g2012 -o build/sim tb/fir_tb.v build/fir.v
> vvp build/sim

syn: gen
> yosys -q -l build/syn.log -p "read_verilog build/fir.v; synth -top fir; stat"
> tail -n 30 build/syn.log

wave: sim
> gtkwave build/fir.vcd

clean:
> rm -f build/fir.v build/sim build/fir.vcd build/syn.log build/hola build/fircheck
