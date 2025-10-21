module top ();
	bit clk;

	//clk generation
	initial begin
		clk = 0;
		forever
			#1 clk = ~clk;
	end

	fifo_if fif(clk);
	FIFO DUT(fif);
	fifo_tb TEST(fif);
	monitor MONITOR(fif);

	always_comb begin 
		if(!fif.rst_n) 
			a_reset_asrt: assert final ((fif.wr_ack == 1'h0) && (fif.empty == 1'h1) 
				&& (fif.full == 1'h0) && (fif.overflow == 1'h0) && (fif.underflow == 1'h0) && (fif.almostfull == 1'h0)
				&& (fif.almostempty == 1'h0));  
			a_reset_cov: cover final ((fif.wr_ack == 1'h0) && (fif.empty == 1'h1) 
				&& (fif.full == 1'h0) && (fif.overflow == 1'h0) && (fif.underflow == 1'h0) && (fif.almostfull == 1'h0)
				&& (fif.almostempty == 1'h0));  
	end 

endmodule : top