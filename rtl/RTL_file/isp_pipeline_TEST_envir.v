// ISP Pipeline Test Environment
// Comprehensive UVM testbench for ISP verification

`include "uvm_macros.svh"
import uvm_pkg::*;

// ISP Configuration Object
class isp_config extends uvm_object;
    `uvm_object_utils(isp_config)
    
    // Image parameters
    int image_width = 1920;
    int image_height = 1080;
    int pixel_width = 12;
    
    // Timing parameters
    int h_blank = 280;
    int v_blank = 45;
    int pixel_clock_period = 6734; // ps (148.5MHz for 1080p60)
    
    // Test parameters
    bit enable_blc = 1;
    bit enable_lsc = 1;
    bit enable_dpc = 1;
    bit enable_bnr = 1;
    bit enable_awb = 1;
    bit enable_ccm = 1;
    bit enable_gamma = 1;
    bit enable_tnr = 1;
    bit enable_ee = 1;
    
    // Bayer pattern
    bit [1:0] bayer_pattern = 2'b00; // RGGB
    
    function new(string name = "isp_config");
        super.new(name);
    endfunction
endclass

// ISP Transaction
class isp_transaction extends uvm_sequence_item;
    `uvm_object_utils(isp_transaction)
    
    // Pixel data
    rand bit [11:0] pixel_data;
    bit hsync;
    bit vsync;
    
    // Position
    int x_pos;
    int y_pos;
    
    // Constraints
    constraint pixel_range {
        pixel_data inside {[0:4095]};
    }
    
    function new(string name = "isp_transaction");
        super.new(name);
    endfunction
    
    function void do_copy(uvm_object rhs);
        isp_transaction tr;
        super.do_copy(rhs);
        $cast(tr, rhs);
        pixel_data = tr.pixel_data;
        hsync = tr.hsync;
        vsync = tr.vsync;
        x_pos = tr.x_pos;
        y_pos = tr.y_pos;
    endfunction
    
    function string convert2string();
        return $sformatf("pixel=%0h, hsync=%0b, vsync=%0b, pos=(%0d,%0d)",
                         pixel_data, hsync, vsync, x_pos, y_pos);
    endfunction
endclass

// ISP Driver
class isp_driver extends uvm_driver #(isp_transaction);
    `uvm_component_utils(isp_driver)
    
    virtual isp_if vif;
    isp_config cfg;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual isp_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
        if (!uvm_config_db#(isp_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NOCFG", "Configuration not found")
    endfunction
    
    task run_phase(uvm_phase phase);
        isp_transaction tr;
        
        forever begin
            seq_item_port.get_next_item(tr);
            drive_pixel(tr);
            seq_item_port.item_done();
        end
    endtask
    
    task drive_pixel(isp_transaction tr);
        @(posedge vif.sensor_pclk);
        vif.sensor_data <= tr.pixel_data;
        vif.sensor_hsync <= tr.hsync;
        vif.sensor_vsync <= tr.vsync;
    endtask
endclass

// ISP Monitor
class isp_monitor extends uvm_monitor;
    `uvm_component_utils(isp_monitor)
    
    virtual isp_if vif;
    isp_config cfg;
    
    uvm_analysis_port #(isp_transaction) item_collected_port;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual isp_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
        if (!uvm_config_db#(isp_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NOCFG", "Configuration not found")
    endfunction
    
    task run_phase(uvm_phase phase);
        isp_transaction tr;
        
        forever begin
            tr = isp_transaction::type_id::create("tr");
            monitor_pixel(tr);
            item_collected_port.write(tr);
        end
    endtask
    
    task monitor_pixel(isp_transaction tr);
        @(posedge vif.sensor_pclk);
        tr.pixel_data = vif.sensor_data;
        tr.hsync = vif.sensor_hsync;
        tr.vsync = vif.sensor_vsync;
    endtask
endclass

// ISP Sequencer
typedef uvm_sequencer #(isp_transaction) isp_sequencer;

// Base Sequence
class isp_base_sequence extends uvm_sequence #(isp_transaction);
    `uvm_object_utils(isp_base_sequence)
    
    isp_config cfg;
    
    function new(string name = "isp_base_sequence");
        super.new(name);
    endfunction
    
    task pre_start();
        if (!uvm_config_db#(isp_config)::get(null, get_full_name(), "cfg", cfg))
            `uvm_fatal("NOCFG", "Configuration not found")
    endtask
endclass

// Test Pattern Sequence
class test_pattern_sequence extends isp_base_sequence;
    `uvm_object_utils(test_pattern_sequence)
    
    typedef enum {COLOR_BAR, RAMP, CHECKERBOARD, SOLID} pattern_t
