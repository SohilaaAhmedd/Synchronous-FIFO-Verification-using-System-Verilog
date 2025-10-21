import FIFO_transaction_pkg::*;
import cnt_pkg::*;
module fifo_tb (fifo_if.TEST fif);
	FIFO_transaction txn;

	initial begin
		fif.data_in = 0;
		fif.wr_en = 0;
		fif.rd_en = 0;
		txn = new();

		//reset test
		fif.rst_n = 0;
		@(negedge fif.clk);
		-> etrigger;

		fif.rst_n = 1;

		//random test
		repeat(1000) begin
			assert(txn.randomize());
			fif.rst_n = txn.rst_n;
			fif.data_in = txn.data_in;
			fif.wr_en = txn.wr_en;
			fif.rd_en = txn.rd_en;
			@(negedge fif.clk);
			-> etrigger;
		end

		//end the test
		test_finished = 1;
	end
endmodule : fifo_tb