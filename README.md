# DE10-Lite_VGA
SystemVerilog design to use the VGA output on the DE10-Lite FPGA Development Board.

This is a simple educational exercise to create a design for VGA output to a monitor. Included are the
SystemVerilog HDL files and the Quartus SDC (constraints) and QSF (settings) files.

The device used is the Intel/Altera DE10-Lite MAX 10 FPGA Development Board which has an onboard VGA connector.
The VGA connector is attached to a Resistor Network Digital-to-Analog Converter, allowing for 4-bits of resolution
for each color (red, green, and blue). 

This design implements the logic to create the horizontal and vertical sync pulses and blanking signals to
create a 640x480 resolution VGA output with a 60 Hz refresh rate. The blanking signals are used to drive
the RGB color outputs to ground to ensure proper timing (i.e. front and back porch).

The 640x480 resolution 60 Hz refresh rate VGA standard uses a 25.175 MHz clock, however this design uses only a 25 MHz
clock, which is close enough. This was done because the MAX 10 FPGA has an onboard 50 MHz clock which was easily divided
down by two to 25 MHz. 

Included in this design is a physical validation module which instantatiates the module that generates the sync pulses,
and then displays a different color to each third of the display. The colors displayed can be modified by the user by
setting the onboard slide switches, although the full range of colors cannot be selected. 

All of the resets in this design are asynchronous and active low, and each flip-flop is designed to reset to a low value.
This decision was made based on Intel's MAX 10 FPGA Design Guidelines. Section 1.7.8 of the document mentions that the 
recommended reset architecture should allow for an asynchronously asserted and synchronously deasserted reset signal. 
A reset synchronizer module is used to implement the synchronous deassertion of the reset signal.

                                           VGA Timing Signal Widths
                            Sync   :  BackPorch  :  VisibleArea  :  FrontPorch  :  Total 
    Horizontal (pixels)  :   96          48            640              16          800
    Vertical   (lines)   :   02          31            480              11          524

Updated 5/25/2021
