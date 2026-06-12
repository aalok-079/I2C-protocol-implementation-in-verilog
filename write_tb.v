module test();

reg scl;
wire sda;

i2c_slave s1(.scl(scl),.sda(sda));

reg sda_reg =1'b1;
reg decide=1'b1;
reg [6:0]address = 7'b0101111;

assign sda = (decide)?sda_reg : 1'bz ;

initial begin
	decide =1'b1;
	scl = 1'b1;
	forever scl = #50 ~scl;
end

initial begin
         #100
	for(integer i =0 ; i<10 ; i=i+1) begin
		if(i==0)
			#25 sda_reg = 1'b0;
	    	else if(i<8) begin
	    		#50 sda_reg = address[6-(i-1)];
	    		#50;
	    	end
	    	else if(i==8) begin
	    		#50 sda_reg = 1'b0;
	    		#100 decide = 1'b0; 
	    		#50;
	    	end
	    	else if(scl) begin
	    		if(sda==0)
	    		$display("oK");
	    		#25;
	    	end
	end
	decide = 1'b1;
	#75
	sda_reg=1'b1;
	#125
	$finish;
end 

initial begin
$monitor("time= %0t , scl = %b , sda = %b , start = %b , add_count = %d, decide_m = %b decide_s = %b",$time, scl, sda, s1.start,s1.count_a,decide, s1.decide);
end

initial begin
 $dumpfile("write.vcd"); // specifies the VCD file
 $dumpvars(0, test); //dump all the variables
end
endmodule
