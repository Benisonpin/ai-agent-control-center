# Makefile for AI + HDR + ISP Integration

# Tool settings
VERILOG_COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

# Source files
VERILOG_SOURCES = $(wildcard *.v)
TOP_MODULE = ai_hdr_isp_integrated_top
TB_MODULE = tb_wrapper

# Targets
.PHONY: all compile sim wave clean

all: compile

compile:
	@echo "Compiling Verilog files..."
	$(VERILOG_COMPILER) -o $(TOP_MODULE).vvp -s $(TB_MODULE) $(VERILOG_SOURCES)

sim: compile
	@echo "Running simulation..."
	$(SIMULATOR) $(TOP_MODULE).vvp

wave: sim
	@echo "Opening waveform viewer..."
	$(VIEWER) simulation.vcd &

clean:
	@echo "Cleaning up..."
	rm -f *.vvp *.vcd

check:
	@echo "Checking files..."
	@ls -la *.v | wc -l
	@echo "Total Verilog files found"
