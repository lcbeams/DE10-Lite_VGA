// -- VGA Controller Physical Validation --
// Instantiate the VGA controller module for physical validation.
// (The controller has not been written yet)
// The module displays three different colors to the display,
// which can be modified by the onboard slide switches.
// Note that not all colors can be chosen.
module vga_controller_pv (
  input              MAX10_CLK1_50, // 50 MHz clock - PIN_P11
  input              KEY1,   // Push button  - PIN_A7
  input              SW0,    // Switch       - PIN_C10
  input              SW1,    // Switch       - PIN_C11
  input              SW2,    // Switch       - PIN_D12
  input              SW3,    // Switch       - PIN_C12
  input              SW4,    // Switch       - PIN_A12
  input              SW5,    // Switch       - PIN_B12
  input              SW6,    // Switch       - PIN_A13
  input              SW7,    // Switch       - PIN_A14
  output logic [3:0] VGA_R,  // VGA Red Data   - PIN_AA1, V1, Y2, Y1
  output logic [3:0] VGA_G,  // VGA Green Data - PIN_W1, T2, R2, R1
  output logic [3:0] VGA_B,  // VGA Blue Data  - PIN_P1, T1, P4, N2
  output logic       VGA_HS, // VGA hsync - PIN_N3
  output logic       VGA_VS  // VGA vsync - PIN_N1
  );

  // Constant for displaying a different color for each third of the display
  localparam ONE_THIRD_DISPLAY = 10'd213;

  // -- Variables --
  logic rst_n;              // Synchronized asynchronous reset
  // Pixel clock generator output
  logic pixel_clock;
  // Sync pulse generator connections
  logic hblank_n;
  logic vblank_n;
  logic blank_n;
  // Local use
  logic [9:0] pixel_count; // Count pixel to divide display into thirds
  logic [3:0] rgb [2:0];   // Colors to be displayed Red = MSB, Blue = LSB. 4-bit colors.

  // -- Continuous assignments --
  // Drive color output low if either blank signal is active. Otherwise, display color.
  assign blank_n = hblank_n & vblank_n;   
  assign VGA_R = blank_n ? (rgb[2]) : (4'h0);
  assign VGA_G = blank_n ? (rgb[1]) : (4'h0);
  assign VGA_B = blank_n ? (rgb[0]) : (4'h0);

  // -- Instantiations --
  reset_synchronizer    rsync (.i_clk(MAX10_CLK1_50), .i_rst_n(KEY1), .o_rst_n(rst_n));
  pixel_clock_generator pcg   (.i_clk(MAX10_CLK1_50), .i_rst_n(rst_n), .o_clk(pixel_clock));
  sync_pulse_generator  spg   (.i_clk(pixel_clock), .i_rst_n(rst_n), .o_hsync_n(VGA_HS),
                               .o_vsync_n(VGA_VS), .o_hblank_n(hblank_n), .o_vblank_n(vblank_n));

  // -- Combinatorial logic --
  // User selectable colors (does not cover the full range)
  // Display a different color in each third of the display
  always_comb begin : ColorSelect
    if (pixel_count < ONE_THIRD_DISPLAY) begin
      rgb[2] = {SW3,SW2,SW1,SW0};
      rgb[1] = {SW7,SW6,SW5,SW4};
      rgb[0] = 4'h0;
    end else if (pixel_count < (2*ONE_THIRD_DISPLAY) ) begin
      rgb[2] = 4'h0;
      rgb[1] = {SW3,SW2,SW1,SW0};
      rgb[0] = {SW7,SW6,SW5,SW4};
    end else begin
      rgb[2] = {SW7,SW6,SW5,SW4};
      rgb[1] = 4'h0;
      rgb[0] = {SW3,SW2,SW1,SW0};
    end // else
  end : ColorSelect

  // -- Sequential logic --
  // Count the number of pixels. Reset each new line.
  always_ff @ (posedge pixel_clock or negedge rst_n) begin : PixelCount
    if (~rst_n) begin
      pixel_count <= '0;
    end else if (blank_n) begin // Not blanking display
      pixel_count <= pixel_count + 10'd1;
    end else begin
      pixel_count <= '0;
    end // else
  end : PixelCount

endmodule