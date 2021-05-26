# Create Clocks
create_clock -period 20.000 [get_ports {MAX10_CLK1_50}]
create_generated_clock -name PIXEL_CLOCK -source [get_ports {MAX10_CLK1_50}] -divide_by 2 -duty_cycle 50 [get_nets {pcg|o_clk}]
derive_clock_uncertainty

# Set delays for asynchronous inputs/outputs
# Define each as a false path
set_input_delay -clock { MAX10_CLK1_50 } 0 [get_ports { SW* KEY* }]
set_output_delay -clock { MAX10_CLK1_50 } 0 [get_ports { VGA* }]
set_false_path -from [get_ports { SW* KEY* }]
set_false_path -to [get_ports { VGA* }]
