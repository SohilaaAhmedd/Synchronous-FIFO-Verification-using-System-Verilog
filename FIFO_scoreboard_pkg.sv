package FIFO_scoreboard_pkg;
	import FIFO_transaction_pkg::*;
	import cnt_pkg::*;
	
	class FIFO_scoreboard;
		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;

		logic [FIFO_WIDTH-1:0] data_out_ref;

		//we will use a queue for testing
		logic [FIFO_WIDTH-1:0] test_queue[$];

		function void check_data(FIFO_transaction tr);
			reference_model(tr);

			if (data_out_ref !== tr.data_out) begin
				error_count = error_count + 1;
				$display("Error at time %0t",$time);
			end
			else begin
				correct_count = correct_count + 1;
				$display("Correct implenmentation");
			end
		endfunction : check_data

		function void reference_model(FIFO_transaction tr);
			if(!tr.rst_n) begin
                test_queue.delete();
            end
            else begin
                if (tr.wr_en && tr.rd_en) begin
                    if(test_queue.size() == 0)
                        test_queue.push_back(tr.data_in);
                    else if (test_queue.size() == FIFO_DEPTH) 
                        data_out_ref = test_queue.pop_front();
                    else begin
                        data_out_ref = test_queue.pop_front();
                        test_queue.push_back(tr.data_in);
                    end    
                end

                else if (tr.wr_en && !tr.rd_en) begin
                    if (test_queue.size() != FIFO_DEPTH)
                    	test_queue.push_back(tr.data_in);
                end
                
                else if (!tr.wr_en && tr.rd_en) begin
                    	if (test_queue.size() != 0)
                        	data_out_ref = test_queue.pop_front();
                end

            end

		endfunction : reference_model
	endclass : FIFO_scoreboard


endpackage : FIFO_scoreboard_pkg