////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(fifo_if.DUT fif);
localparam max_fifo_addr = $clog2(fif.FIFO_DEPTH);

reg [fif.FIFO_WIDTH-1:0] mem [fif.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge fif.clk or negedge fif.rst_n) begin
	if (!fif.rst_n) begin
		wr_ptr <= 0;
		fif.overflow <= 0; //update_2
		fif.wr_ack <= 0; //update_2
	end
	else if (fif.wr_en && count < fif.FIFO_DEPTH) begin
		mem[wr_ptr] <= fif.data_in;
		fif.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		fif.wr_ack <= 0; 
		if (fif.full & fif.wr_en)
			fif.overflow <= 1;
		else
			fif.overflow <= 0;
	end
end

always @(posedge fif.clk or negedge fif.rst_n) begin
	if (!fif.rst_n) begin
		rd_ptr <= 0;
		//fif.data_out <= 0; //update_3
		fif.underflow <= 0; //update_3
	end
	else if (fif.rd_en && count != 0) begin
		fif.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	else begin //update_4
		if (fif.empty & fif.rd_en)
			fif.underflow <= 1;
		else
			fif.underflow <= 0;
	end
end

always @(posedge fif.clk or negedge fif.rst_n) begin
	if (!fif.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({fif.wr_en, fif.rd_en} == 2'b10) && !fif.full) 
			count <= count + 1;
		else if ( ({fif.wr_en, fif.rd_en} == 2'b01) && !fif.empty)
			count <= count - 1;
		else if ( ({fif.wr_en, fif.rd_en} == 2'b11) ) begin //update_5
			if (fif.full)
				count <= count - 1;
			else if (fif.empty)
				count <= count + 1;
		end
	end
end



assign fif.full = (count == fif.FIFO_DEPTH)? 1 : 0;
assign fif.empty = (count == 0)? 1 : 0;
//assign fif.underflow = (fif.empty && fif.rd_en)? 1 : 0; //incorrect implementation
assign fif.almostfull = (count == fif.FIFO_DEPTH-1)? 1 : 0; //update_1
assign fif.almostempty = (count == 1)? 1 : 0;

`ifdef SIM
	property reset_behavior;
		@(posedge fif.clk) (!fif.rst_n) |=> (!wr_ptr && !rd_ptr && !count);
	endproperty

	property write_acknowledge;
		@(posedge fif.clk) disable iff(!fif.rst_n) (fif.wr_en && !fif.full) |=> (fif.wr_ack);
	endproperty

	property  overflow_detection;
		@(posedge fif.clk) disable iff(!fif.rst_n) (fif.wr_en && fif.full) |=> (fif.overflow);
	endproperty

	property  underflow_detection;
		@(posedge fif.clk) disable iff(!fif.rst_n) (fif.rd_en && fif.empty) |=> (fif.underflow);
	endproperty

	property  empty_flag_assrt;
		@(posedge fif.clk) disable iff(!fif.rst_n) (!count) |-> (fif.empty);
	endproperty

	property  full_flag_assrt;
		@(posedge fif.clk) disable iff(!fif.rst_n) (count == fif.FIFO_DEPTH) |-> (fif.full);
	endproperty

	property  almost_full_cond;
		@(posedge fif.clk) disable iff(!fif.rst_n) (count == fif.FIFO_DEPTH-1) |-> (fif.almostfull);
	endproperty

	property  almost_empty_cond;
		@(posedge fif.clk) disable iff(!fif.rst_n) (count == 1) |-> (fif.almostempty);
	endproperty

	property  wr_ptr_wrap;
		@(posedge fif.clk) disable iff(!fif.rst_n) (fif.wr_en && (wr_ptr == fif.FIFO_DEPTH-1) && !fif.full) |=> (!wr_ptr);
	endproperty

	property  rd_ptr_wrap;
		@(posedge fif.clk) disable iff(!fif.rst_n) (fif.rd_en && (rd_ptr == fif.FIFO_DEPTH-1)) |=> (!rd_ptr);
	endproperty

	property  wr_ptr_threshold;
		@(posedge fif.clk) disable iff(!fif.rst_n) wr_ptr < fif.FIFO_DEPTH;
	endproperty	

	property  rd_ptr_threshold;
		@(posedge fif.clk) disable iff(!fif.rst_n) rd_ptr < fif.FIFO_DEPTH;
	endproperty	

	assert property (reset_behavior);
	assert property (write_acknowledge);
	assert property (overflow_detection);
	assert property (underflow_detection);
	assert property (empty_flag_assrt);
	assert property (full_flag_assrt);
	assert property (almost_full_cond);
	assert property (almost_empty_cond);
	assert property (wr_ptr_wrap);
	assert property (rd_ptr_wrap);
	assert property (wr_ptr_threshold);
	assert property (rd_ptr_threshold);

	cover property (reset_behavior);
	cover property (write_acknowledge);
	cover property (overflow_detection);
	cover property (underflow_detection);
	cover property (empty_flag_assrt);
	cover property (full_flag_assrt);
	cover property (almost_full_cond);
	cover property (almost_empty_cond);
	cover property (wr_ptr_wrap);
	cover property (rd_ptr_wrap);
	cover property (wr_ptr_threshold);
	cover property (rd_ptr_threshold);
`endif

endmodule