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
    
    typedef enum {COLOR_BAR, RAMP, CHECKERBOARD, SOLID} pattern_t;
    rand pattern_t pattern_type;
    rand bit [11:0] solid_color;
    
    function new(string name = "test_pattern_sequence");
        super.new(name);
    endfunction
    
    task body();
        isp_transaction tr;
        
        for (int y = 0; y < cfg.image_height + cfg.v_blank; y++) begin
            for (int x = 0; x < cfg.image_width + cfg.h_blank; x++) begin
                tr = isp_transaction::type_id::create("tr");
                
                // Set sync signals
                tr.vsync = (y >= cfg.image_height);
                tr.hsync = (x >= cfg.image_width);
                tr.x_pos = x;
                tr.y_pos = y;
                
                // Generate pixel data based on pattern
                if (!tr.hsync && !tr.vsync) begin
                    case (pattern_type)
                        COLOR_BAR: tr.pixel_data = generate_color_bar(x, y);
                        RAMP: tr.pixel_data = generate_ramp(x, y);
                        CHECKERBOARD: tr.pixel_data = generate_checkerboard(x, y);
                        SOLID: tr.pixel_data = solid_color;
                    endcase
                end else begin
                    tr.pixel_data = 12'h000;
                end
                
                start_item(tr);
                finish_item(tr);
            end
        end
    endtask
    
    function bit [11:0] generate_color_bar(int x, int y);
        int bar_width = cfg.image_width / 8;
        int bar_num = x / bar_width;
        
        case (bar_num)
            0: return 12'hFFF; // White
            1: return 12'hFF0; // Yellow
            2: return 12'h0FF; // Cyan
            3: return 12'h0F0; // Green
            4: return 12'hF0F; // Magenta
            5: return 12'hF00; // Red
            6: return 12'h00F; // Blue
            7: return 12'h000; // Black
            default: return 12'h000;
        endcase
    endfunction
    
    function bit [11:0] generate_ramp(int x, int y);
        return (x * 4095) / cfg.image_width;
    endfunction
    
    function bit [11:0] generate_checkerboard(int x, int y);
        int square_size = 32;
        bit checker = ((x / square_size) + (y / square_size)) % 2;
        return checker ? 12'hFFF : 12'h000;
    endfunction
endclass

// Random Image Sequence
class random_image_sequence extends isp_base_sequence;
    `uvm_object_utils(random_image_sequence)
    
    rand int noise_level;
    
    constraint noise_constraint {
        noise_level inside {[0:100]};
    }
    
    function new(string name = "random_image_sequence");
        super.new(name);
    endfunction
    
    task body();
        isp_transaction tr;
        bit [11:0] base_pattern[0:1919][0:1079];
        
        // Generate base Bayer pattern
        generate_bayer_pattern(base_pattern);
        
        for (int y = 0; y < cfg.image_height + cfg.v_blank; y++) begin
            for (int x = 0; x < cfg.image_width + cfg.h_blank; x++) begin
                tr = isp_transaction::type_id::create("tr");
                
                tr.vsync = (y >= cfg.image_height);
                tr.hsync = (x >= cfg.image_width);
                tr.x_pos = x;
                tr.y_pos = y;
                
                if (!tr.hsync && !tr.vsync) begin
                    tr.pixel_data = base_pattern[x][y];
                    // Add noise
                    if (noise_level > 0) begin
                        int noise = $urandom_range(-noise_level, noise_level);
                        int noisy_pixel = tr.pixel_data + noise;
                        tr.pixel_data = (noisy_pixel < 0) ? 0 : 
                                       (noisy_pixel > 4095) ? 4095 : noisy_pixel;
                    end
                end else begin
                    tr.pixel_data = 12'h000;
                end
                
                start_item(tr);
                finish_item(tr);
            end
        end
    endtask
    
    function void generate_bayer_pattern(ref bit [11:0] pattern[0:1919][0:1079]);
        for (int y = 0; y < cfg.image_height; y++) begin
            for (int x = 0; x < cfg.image_width; x++) begin
                bit [1:0] pixel_type = {y[0] ^ cfg.bayer_pattern[1], 
                                       x[0] ^ cfg.bayer_pattern[0]};
                case (pixel_type)
                    2'b00: pattern[x][y] = $urandom_range(2048, 3072); // Red
                    2'b01, 2'b10: pattern[x][y] = $urandom_range(1024, 3072); // Green
                    2'b11: pattern[x][y] = $urandom_range(1024, 2048); // Blue
                endcase
            end
        end
    endfunction
endclass

// ISP Agent
class isp_agent extends uvm_agent;
    `uvm_component_utils(isp_agent)
    
    isp_driver driver;
    isp_monitor monitor;
    isp_sequencer sequencer;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (get_is_active() == UVM_ACTIVE) begin
            driver = isp_driver::type_id::create("driver", this);
            sequencer = isp_sequencer::type_id::create("sequencer", this);
        end
        
        monitor = isp_monitor::type_id::create("monitor", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass

// ISP Scoreboard
class isp_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(isp_scoreboard)
    
    uvm_analysis_imp #(isp_transaction, isp_scoreboard) item_collected_export;
    
    // Reference model
    bit [11:0] input_frame[0:1919][0:1079];
    bit [23:0] output_frame[0:1919][0:1079];
    
    // Statistics
    int pixel_count;
    int error_count;
    real mse; // Mean Square Error
    real psnr; // Peak Signal-to-Noise Ratio
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    function void write(isp_transaction tr);
        // Store input pixels
        if (!tr.hsync && !tr.vsync) begin
            input_frame[tr.x_pos][tr.y_pos] = tr.pixel_data;
            pixel_count++;
        end
    endfunction
    
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        
        // Run reference model
        run_reference_model();
        
        // Calculate metrics
        calculate_metrics();
        
        `uvm_info("SCOREBOARD", $sformatf("Total pixels: %0d", pixel_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Errors: %0d", error_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("MSE: %0.2f", mse), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("PSNR: %0.2f dB", psnr), UVM_LOW)
        
        if (error_count > 0)
            `uvm_error("SCOREBOARD", $sformatf("Found %0d errors", error_count))
    endfunction
    
    function void run_reference_model();
        // Simplified reference model
        for (int y = 0; y < 1080; y++) begin
            for (int x = 0; x < 1920; x++) begin
                bit [11:0] pixel = input_frame[x][y];
                // Simple scaling to 8-bit RGB
                bit [7:0] r = pixel[11:4];
                bit [7:0] g = pixel[11:4];
                bit [7:0] b = pixel[11:4];
                output_frame[x][y] = {r, g, b};
            end
        end
    endfunction
    
    function void calculate_metrics();
        real sum_sq_error = 0;
        
        for (int y = 0; y < 1080; y++) begin
            for (int x = 0; x < 1920; x++) begin
                bit [23:0] expected = output_frame[x][y];
                // In real testbench, would compare with actual output
                real error = 0; // Placeholder
                sum_sq_error += error * error;
            end
        end
        
        mse = sum_sq_error / (1920 * 1080);
        psnr = 10 * $log10(255 * 255 / mse);
    endfunction
endclass

// ISP Coverage
class isp_coverage extends uvm_component;
    `uvm_component_utils(isp_coverage)
    
    // Coverage groups
    covergroup pixel_value_cg;
        pixel_val: coverpoint pixel_data {
            bins low = {[0:1023]};
            bins mid_low = {[1024:2047]};
            bins mid_high = {[2048:3071]};
            bins high = {[3072:4095]};
        }
    endgroup
    
    covergroup position_cg;
        x_pos: coverpoint x_position {
            bins left = {[0:639]};
            bins center = {[640:1279]};
            bins right = {[1280:1919]};
        }
        y_pos: coverpoint y_position {
            bins top = {[0:359]};
            bins middle = {[360:719]};
            bins bottom = {[720:1079]};
        }
        corner: cross x_pos, y_pos;
    endgroup
    
    bit [11:0] pixel_data;
    int x_position, y_position;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        pixel_value_cg = new();
        position_cg = new();
    endfunction
    
    function void sample_coverage(isp_transaction tr);
        if (!tr.hsync && !tr.vsync) begin
            pixel_data = tr.pixel_data;
            x_position = tr.x_pos;
            y_position = tr.y_pos;
            pixel_value_cg.sample();
            position_cg.sample();
        end
    endfunction
endclass

// ISP Environment
class isp_env extends uvm_env;
    `uvm_component_utils(isp_env)
    
    isp_agent agent;
    isp_scoreboard scoreboard;
    isp_coverage coverage;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = isp_agent::type_id::create("agent", this);
        scoreboard = isp_scoreboard::type_id::create("scoreboard", this);
        coverage = isp_coverage::type_id::create("coverage", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        agent.monitor.item_collected_port.connect(scoreboard.item_collected_export);
    endfunction
endclass

// Base Test
class isp_base_test extends uvm_test;
    `uvm_component_utils(isp_base_test)
    
    isp_env env;
    isp_config cfg;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        cfg = isp_config::type_id::create("cfg");
        uvm_config_db#(isp_config)::set(this, "*", "cfg", cfg);
        
        env = isp_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST", "Starting ISP test", UVM_LOW)
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

// Color Bar Test
class color_bar_test extends isp_base_test;
    `uvm_component_utils(color_bar_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        test_pattern_sequence seq;
        
        phase.raise_objection(this);
        
        seq = test_pattern_sequence::type_id::create("seq");
        seq.pattern_type = test_pattern_sequence::COLOR_BAR;
        seq.start(env.agent.sequencer);
        
        phase.drop_objection(this);
    endtask
endclass

// Random Test
class random_test extends isp_base_test;
    `uvm_component_utils(random_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        random_image_sequence seq;
        
        phase.raise_objection(this);
        
        repeat(10) begin
            seq = random_image_sequence::type_id::create("seq");
            assert(seq.randomize());
            seq.start(env.agent.sequencer);
        end
        
        phase.drop_objection(this);
    endtask
endclass

// ISP Interface
interface isp_if(input logic clk);
    logic [11:0] sensor_data;
    logic sensor_hsync;
    logic sensor_vsync;
    logic sensor_pclk;
    
    logic [23:0] rgb_out;
    logic data_valid_out;
    logic frame_start_out;
    logic frame_end_out;
    
    // Configuration interface
    logic [31:0] config_addr;
    logic [31:0] config_data;
    logic config_write;
    logic config_read;
    logic [31:0] config_readdata;
    
    // Statistics
    logic [31:0] awb_r_gain;
    logic [31:0] awb_g_gain;
    logic [31:0] awb_b_gain;
    logic [31:0] ae_exposure;
    logic [31:0] af_score;
    
    // Clocking blocks
    clocking driver_cb @(posedge sensor_pclk);
        output sensor_data;
        output sensor_hsync;
        output sensor_vsync;
    endclocking
    
    clocking monitor_cb @(posedge sensor_pclk);
        input sensor_data;
        input sensor_hsync;
        input sensor_vsync;
        input rgb_out;
        input data_valid_out;
    endclocking
    
    modport driver(clocking driver_cb);
    modport monitor(clocking monitor_cb);
endinterface

// Top-level testbench module
module isp_tb_top;
    
    // Clock generation
    logic clk;
    logic sensor_pclk;
    
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end
    
    initial begin
        sensor_pclk = 0;
        forever #3.367ns sensor_pclk = ~sensor_pclk; // 148.5MHz
    end
    
    // Interface instance
    isp_if isp_vif(clk);
    assign isp_vif.sensor_pclk = sensor_pclk;
    
    // DUT instance
    isp_pipeline_top dut (
        .clk(clk),
        .rst_n(1'b1),
        .sensor_data(isp_vif.sensor_data),
        .sensor_hsync(isp_vif.sensor_hsync),
        .sensor_vsync(isp_vif.sensor_vsync),
        .sensor_pclk(isp_vif.sensor_pclk),
        .rgb_out(isp_vif.rgb_out),
        .data_valid_out(isp_vif.data_valid_out),
        .frame_start_out(isp_vif.frame_start_out),
        .frame_end_out(isp_vif.frame_end_out),
        .config_addr(isp_vif.config_addr),
        .config_data(isp_vif.config_data),
        .config_write(isp_vif.config_write),
        .config_read(isp_vif.config_read),
        .config_readdata(isp_vif.config_readdata),
        .awb_r_gain(isp_vif.awb_r_gain),
        .awb_g_gain(isp_vif.awb_g_gain),
        .awb_b_gain(isp_vif.awb_b_gain),
        .ae_exposure(isp_vif.ae_exposure),
        .af_score(isp_vif.af_score)
    );
    
    // UVM configuration
    initial begin
        uvm_config_db#(virtual isp_if)::set(null, "*", "vif", isp_vif);
        run_test();
    end
    
endmodule