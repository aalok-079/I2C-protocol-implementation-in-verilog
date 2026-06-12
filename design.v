module i2c_slave(input scl, inout sda);

wire pedge,negde; //declared for determining start and stop

reg sad; //stands for signal after delay used to store value of sda for determining star and stop
reg [2:0] count_a = 3'b000; //to count address+1 bits in first transaction
reg [2:0] count_d = 3'b000; //to count data bits 
reg r_w_bit = 1'b0; //to decide whether to read or write
reg [6:0] address = 7'b0000000; //to store incoming address
reg compare = 1'b0; //to compare slave's address with incoming address
reg decide = 1'b0; //to decide whether sda in input or output line
reg sda_reg = 1'b1; //register to use when sda is output line
reg [1:0] state = 2'b00; //to decide state
reg start = 1'b0; //to decide start
reg stop = 1'b0; // to decide stop

reg [6:0]s_add = 7'b0001110;

parameter START=2'b01, STOP=2'b11, WRITE=2'b00;

assign sda = (decide)? sda_reg : 1'bz;

assign pedge = sda && ~sad;

assign nedge = ~sda && sad;

// block for detecting start and stop

always @(posedge scl) begin //storing previous value of signal
	
	sad <= sda;
end

always @(pedge, negde) begin

	if(scl)begin //this change can only when happen clock is high
	
	if(pedge)
	state<=STOP;
	
	if(nedge)
	state<=START;
	
	end
end

// end of block for detecting start and stop

//START block for storing and comparing address and deciding whether to read ot write

always @(scl)begin
	
	case(state) 
	
		START : begin
		
		if(scl) begin
		
			if((count_a>=0) && (count_a<7)) begin
				count_a <= count_a + 3'b001;
				address[6-count_a] <= sda;
			end
			
		end
		else if(count_a==7) begin
			
			count_a <= count_a + 3'b001;
			r_w_bit <= sda;
			
			if(address&&s_add) begin
				
				compare <= 1'b1;
				decide <= 1'b1;
				
			end
		
		end
		else begin
			
			if(!scl) begin
			
				sda_reg <= 1'b0;
			
				if(!r_w_bit)
					state <= WRITE;
			
			end
		end
		
		end
	
	endcase
end

endmodule
