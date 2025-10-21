package FIFO_coverage_pkg;
	import FIFO_transaction_pkg::*;

	class FIFO_coverage;
		FIFO_transaction F_cvg_txn;

		covergroup covgrp;
			wr_cp: coverpoint F_cvg_txn.wr_en;
			rd_cp: coverpoint F_cvg_txn.rd_en;
			ack_cp: coverpoint F_cvg_txn.wr_ack;
			over_cp: coverpoint F_cvg_txn.overflow;
			full_cp: coverpoint F_cvg_txn.full;
			empty_cp: coverpoint F_cvg_txn.empty;
			almostfull_cp: coverpoint F_cvg_txn.almostfull;
			almostempty_cp: coverpoint F_cvg_txn.almostempty;
			under_cp: coverpoint F_cvg_txn.underflow;

			crs_1: cross wr_cp,rd_cp,ack_cp{
				ignore_bins ack_zero_wr = binsof(wr_cp) intersect {0} && binsof(ack_cp) intersect {1};
			}
			crs_2: cross wr_cp,rd_cp,over_cp{
				ignore_bins ack_zero_wr = binsof(wr_cp) intersect {0} && binsof(over_cp) intersect {1};
			}
			crs_3: cross wr_cp,rd_cp,full_cp{
				ignore_bins ack_zero_wr = binsof(rd_cp) intersect {1} && binsof(full_cp) intersect {1};
			}
			crs_4: cross wr_cp,rd_cp,empty_cp;
			crs_5: cross wr_cp,rd_cp,almostfull_cp;
			crs_6: cross wr_cp,rd_cp,almostempty_cp;
			crs_7: cross wr_cp,rd_cp,under_cp{
				ignore_bins ack_zero_wr = binsof(rd_cp) intersect {0} && binsof(under_cp) intersect {1};
			}
		endgroup : covgrp

		function new();
			covgrp = new;
			F_cvg_txn = new;
		endfunction

		function void sample_data(FIFO_transaction F_txn);
			F_cvg_txn = F_txn;
			covgrp.sample();
		endfunction
	endclass : FIFO_coverage
	
endpackage : FIFO_coverage_pkg