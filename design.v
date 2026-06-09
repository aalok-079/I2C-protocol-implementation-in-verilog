module i2c_slave(input scl, inout sda);

wire pedge,negde; //declared for determining start and stop

reg sad; //stands for signal after delay used to store value of sda for determining star and stop
reg [2:0] count_a = 3'b000; //to count address+1 bits in first transaction
reg [2:0] count_d = 3'b000; //to count data bits 
reg r_w_bit = 1'b0 //to decide whether to read or write
reg [6:0] address = 7'b0000000; //to store incoming address
reg compare = 1'b0; //to compare slave's address with incoming address
reg decide = 1'b0; //to decide whether sda in input or output line
reg sda_reg = 1'b1; //register to use when sda is output line
reg [1:0] state = 2'b00; //to decide state
reg start = 1'b0; //to decide start
reg start = 1'b0; // to decide stop

endmodule
