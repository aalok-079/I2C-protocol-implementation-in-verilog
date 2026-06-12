module test();

reg scl;
wire sda;

i2c_slave s1(.scl(scl),.sda(sda));

reg sda_reg =1'b1;
reg decide=1'b1;

assign sda = (decide)?sda_reg : 1'bz ;

initial begin
	decide =1'b1;
	scl = 1'b1;
end

initial begin 
	forever scl = #50 ~scl;
end

initial begin

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
	    		#100;
	    	end
	end
	
	sda=1'b1;
	$finish
end 

initial begin
 $dumpfile("write.vcd"); // specifies the VCD file
 $dumpvars(0, test); //dump all the variables
end
endmodule
