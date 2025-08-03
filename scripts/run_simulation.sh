#!/bin/bash
echo "Running AI ISP Simulation..."
echo "==========================="

# Create work directory
mkdir -p work

# Compile Verilog files
echo "Compiling Verilog files..."
iverilog -o work/ai_isp_sim \
    rtl/ai_agent_core.v \
    rtl/ai_auto_white_balance.v \
    rtl/ai_noise_reduction.v \
    rtl/statistics_collector.v \
    rtl/ai_isp_top.v \
    testbench/ai_isp_tb.v

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Run simulation
    echo "Running simulation..."
    cd work
    vvp ai_isp_sim
    
    # Check if VCD file was generated
    if [ -f ai_isp.vcd ]; then
        echo -e "\nSimulation complete! VCD file generated."
        echo "You can view waveforms with: gtkwave work/ai_isp.vcd"
    fi
else
    echo "Compilation failed!"
fi
