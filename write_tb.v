module test();

reg scl; // clock line
wire sda; // declaration of sda or data line as wire because it is a inout line

i2c_slave s1(.scl(scl),.sda(sda)); // instantiation of module

reg [7:0] data = 8'b01010101;
reg sda_reg =1'b1; 
reg decide=1'b1;
reg [6:0]address = 7'b0101111;

assign sda = (decide)?sda_reg : 1'bz ; //line for deciding sda as input for 0 and output for 1

initial begin
	decide =1'b1; // making sda as output line from MASTER
	scl = 1'b1; // starting of clock
	forever scl = #50 ~scl; // period of 100 time units
end

initial begin
         #100
	for(integer i =0 ; i<10 ; i=i+1) begin //loop for transferring address and read write bit
		if(i==0) //for start bit
			#25 sda_reg = 1'b0;
	    	else if(i<8) begin  // for transferring data
	    		#50 sda_reg = address[6-(i-1)];
	    		#50;
	    	end
	    	else if(i==8) begin //for transferrin read write bit
	    		#50 sda_reg = 1'b0;
	    		#100 decide = 1'b0; 
	    		#50;
	    	end
	    	else if(scl) begin  //condition for chechking acknowledge from SLAVE
	    		if(sda==0)
	    		$display("ACK");
	    		#25;
	    	end
	end
	decide = 1'b1;

	for(integer j=0;j<8;j=j+1) begin
		if(!scl) begin
			sda_reg=data[7-j];
			#101;	
		end
	end
	
	if(!scl) begin
		decide =1'b0;
		#50;
	end
		
	if(scl) begin
		if(sda==0)
		$display("ACK");
	end
	#50
	decide =1'b1;
	sda_reg=1'b0;
	#50
	if(scl)
		sda_reg=1'b1;
	#125;
	$finish;
end

//block for printing variables on terminal
initial begin
$monitor("time= %0t , scl = %b , sda = %b , start = %b , add_count = %d, decide_m = %b decide_s = %b",$time, scl, sda, s1.start,s1.count_a,decide, s1.decide);
end

// block for dumping variables
initial begin
 $dumpfile("write.vcd"); // specifies the VCD file
 $dumpvars(0, test); //dump all the variables
end

endmodule
