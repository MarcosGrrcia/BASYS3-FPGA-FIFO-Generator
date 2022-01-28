# BASYS3-FPGA-FIFO-Generator
An implementation of a FIFO bit generator on a BASYS3 FPGA using a single-port BRAM instantiation.

I used Vivado IP catalog to generate a single-port block memory setting the R/W width to 8 and the depth to 16.
Afterwards, I made the BRAM core a component of my TOP module. I then made a single-pulse
push button instantiation to use as a component as a clock to sync the reading and writing
operations. I made three inputs, the internal clock, the button, and the 8-bit data inputted by the
user. There are eight outputs, which include two LEDs to indicate the read and write functions,
four LEDs to show indicators determining if FIFO flags were full, empty, almost full, or almost
empty, and a 7-bit LED output to the 7 Segment Display cathodes and 4-bit output to the
7-Segment Display anodes.

I made several processes. The first process increments a refresh counter for the 7
Segment Display. The second process takes a 4-bit input and transfers it to a 7 Segment Display
code in order to output it as a decimal. The third process sets the FIFO flags and updates a buffer
address with sensitivity to the read/write enable. The fourth process controls the switching
between the LEDs on the 7 Segment Display. Then, the last process is the actual FIFO logic,
which increments or decrements a counter for the num of elements in the BRAM and adds to the
read or write addresses based on the read/write enable. The counter also checks for the FIFO
flags.
