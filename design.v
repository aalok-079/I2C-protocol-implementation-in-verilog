module i2c_slave(input scl, inout sda);

wire pedge,nedge; //declared for determining start and stop

reg sad; //stands for signal after delay used to store value of sda for determining star and stop
reg [3:0] count_a = 4'b000; //to count address+1 bits in first transaction
reg [3:0] count_d = 4'b000; //to count data bits 
reg r_w_bit = 1'b0; //to decide whether to read or write
reg [6:0] address = 7'b0000000; //to store incoming address
reg compare = 1'b0; //to compare slave's address with incoming address
reg decide = 1'b0; //to decide whether sda in input or output line
reg sda_reg = 1'b1; //register to use when sda is output line
reg [1:0] state; //to decide state
reg start = 1'b0; //to decide start
reg stop = 1'b0; // to decide stop
reg [7:0]data_s=8'b0;
reg [6:0]s_add = 7'b0101111;

parameter START=2'b01, STOP=2'b11, WRITE=2'b00;

assign sda = (decide)? sda_reg : 1'bz;

assign pedge = sda && ~sad;

assign nedge = ~sda && sad;

// block for detecting start and stop

always @(posedge scl) begin //storing previous value of signal
	$display("0");
	sad <= sda;
end

always @(pedge, nedge) begin

	if(scl)begin //this change can only when happen clock is high
	$display("1");
	if(pedge) begin
	state<=STOP;
	stop<=1;
	end
	
	if(nedge) begin
	$display("1");
	state<=START;
	start<=1;
	end
	
	end
end

// end of block for detecting start and stop

//START block for storing and comparing address and deciding whether to read ot write

always @(posedge scl,negedge scl)begin
	
	case(state) 
	
		START : begin
		
		if(scl) begin
		
			if((count_a>=0) && (count_a<7)) begin
				count_a <= count_a + 4'b0001;
				address[6-count_a] <= sda;
			end
			else if(count_a == 7)begin 
				count_a <= count_a + 4'b0001;
				r_w_bit <= sda;
				
				if(address&&s_add) begin
					compare <= 1'b1;
				end
			end
			
			else begin
				count_a <= count_a + 4'b0001;
			end
		end
		
		else begin
			
			if((!scl)&&(count_a==8)&&compare) begin
				sda_reg <= 1'b0;
				decide <= 1'b1;
				
			end
			else if((!scl)&&(count_a==9)) begin
				if(~r_w_bit) begin
					state <= WRITE;
					$display("state changed");
			        end
				decide <= 1'b0;
				sda_reg<=1'b1;
			end
		end
		
		end
		
		WRITE: begin
		if(scl) begin
		
			if((count_d>=0) && (count_d<8)) begin //storing 8 bit data
				count_d <= count_d + 4'b0001;
				data_s[7-count_d] <= sda;
			end
			else
				count_d <= count_d + 4'b0001; // for incrementing count from 8 to 9
		end
		else begin
			
			if((!scl)&&(count_d==8)) begin
				sda_reg <= 1'b0; //acknowledging
				decide <= 1'b1;	//changing of sda to input to slave to output from slave
			end
			else if((!scl)&&(count_d==9)) begin
				decide <= 1'b0;
				sda_reg<=1'b1;
				count_d<=0;
			end
			
		end
	        end
	        
	        
		
	endcase
end

endmodule
