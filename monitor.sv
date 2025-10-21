import cnt_pkg::*;

import FIFO_transaction_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;
module monitor (fifo_if.MONITOR fif);
	FIFO_transaction tr;
	FIFO_scoreboard sb;
	FIFO_coverage cv;


	initial begin
		tr = new();
		cv = new();
		sb = new();

		forever begin
			wait(etrigger.triggered);
			@(negedge fif.clk);
			tr.data_in = fif.data_in;
			tr.wr_en = fif.wr_en;
			tr.rd_en = fif.rd_en;
			tr.rst_n = fif.rst_n;
			tr.full = fif.full;
			tr.empty = fif.empty;
			tr.almostfull = fif.almostfull;
			tr.almostempty = fif.almostempty;
			tr.wr_ack = fif.wr_ack;
			tr.overflow = fif.overflow;
			tr.underflow = fif.underflow;
			tr.data_out = fif.data_out;

			fork
				begin
					cv.sample_data(tr);	
				end
				begin
					sb.check_data(tr);	
				end
			join

			if (test_finished) begin
				$display("Simulation Stopped");
				$display("error_count = %d, correct_count = %d",error_count, correct_count);
				$stop;
			end
		end
	end
endmodule : monitor



	