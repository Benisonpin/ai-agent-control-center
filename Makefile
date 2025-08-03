# AI ISP Makefile

.PHONY: all compile sim analyze clean

all: compile sim

compile:
	@echo "Compiling AI ISP..."
	@mkdir -p work
	@iverilog -o work/ai_isp_sim \
		rtl/ai_agent_core.v \
		rtl/ai_auto_white_balance.v \
		rtl/ai_noise_reduction.v \
		rtl/statistics_collector.v \
		rtl/ai_isp_top.v \
		testbench/ai_isp_tb.v

sim: compile
	@echo "Running simulation..."
	@cd work && vvp ai_isp_sim

analyze:
	@echo "Analyzing AI performance..."
	@python3 scripts/analyze_ai_performance.py

view:
	@gtkwave work/ai_isp.vcd &

clean:
	@rm -rf work/
	@rm -f *.png
	@echo "Cleaned!"

help:
	@echo "Available targets:"
	@echo "  make compile  - Compile Verilog files"
	@echo "  make sim      - Run simulation"
	@echo "  make analyze  - Analyze AI performance"
	@echo "  make view     - View waveforms"
	@echo "  make clean    - Clean build files"
