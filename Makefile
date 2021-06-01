# FPGA variables
PROJECT = fpga/memLCDdriver
SOURCES = src/memLCDdriver.v src/memlcd_fsm.v src/clockdiv.v src/spi_s.v src/sfifo.v src/fifomem.v
ICEBREAKER_DEVICE = up5k
ICEBREAKER_PIN_DEF = fpga/icebreaker.pcf
ICEBREAKER_PACKAGE = sg48
SEED = 1

# COCOTB variables
export COCOTB_REDUCED_LOG_FMT=1

all: test_memLCDdriver test_sfifo test_spi_s test_memlcd_fsm

# if you run rules with NOASSERT=1 it will set PYTHONOPTIMIZE, which turns off assertions in the tests
test_memLCDdriver:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s memLCDdriver -s dump -g2012 src/memLCDdriver.v test/dump_memLCDdriver.v src/ src/memlcd_fsm.v src/clockdiv.v src/spi_s.v src/sfifo.v src/fifomem.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_memLCDdriver vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

test_sfifo:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s sfifo -s dump -g2012 src/sfifo.v test/dump_sfifo.v src/ src/fifomem.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_sfifo vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

test_spi_s:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s spi_s -s dump -g2012 src/spi_s.v test/dump_spi_s.v src/
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_spi_s vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

test_memlcd_fsm:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s memlcd_fsm -s dump -g2012 src/memlcd_fsm.v test/dump_memlcd_fsm.v src/ src/clockdiv.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_memlcd_fsm vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

show_%: %.vcd %.gtkw
	gtkwave $^

# FPGA recipes

show_synth_%: src/%.v
	yosys -p "read_verilog $<; proc; opt; show -colors 2 -width -signed"

%.json: $(SOURCES)
	yosys -l fpga/yosys.log -p 'synth_ice40 -top memLCDdriver -json $(PROJECT).json' $(SOURCES)

%.asc: %.json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 -l fpga/nextpnr.log --seed $(SEED) --freq 20 --package $(ICEBREAKER_PACKAGE) --$(ICEBREAKER_DEVICE) --asc $@ --pcf $(ICEBREAKER_PIN_DEF) --json $<

%.bin: %.asc
	icepack $< $@

prog: $(PROJECT).bin
	iceprog $<

# general recipes

lint:
	verible-verilog-lint src/*v --rules_config verible.rules

clean:
	rm -rf *vcd sim_build fpga/*log fpga/*bin test/__pycache__ results.xml

.PHONY: clean
