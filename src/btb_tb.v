`timescale 1ns / 1ps

module btb_tb;

    reg clk;
    reg rst;

    // Lookup interface
    reg fetch_valid;
    reg [31:0] pc_in;

    // Lookup outputs
    wire pred_valid;
    wire [31:0] pred_target;

    // Update interface
    reg update_req;
    reg [31:0] update_pc;
    reg [31:0] update_target;

    // Instantiate BTB
    btb uut (
        .clk(clk),
        .rst(rst),
        .fetch_valid(fetch_valid),
        .pc_in(pc_in),
        .pred_valid(pred_valid),
        .pred_target(pred_target),
        .update_req(update_req),
        .update_pc(update_pc),
        .update_target(update_target)
    );

    // Clock generator (10 ns period)
    always #5 clk = ~clk;

    // =======================================================================
    // MONITOR - prints whenever ANY watched signal changes
    // =======================================================================
    initial begin
        $monitor("Time=%0t | pc_in=%h | fetch_valid=%b | pred_valid=%b | pred_target=%h | update_req=%b | update_pc=%h | update_target=%h",
                  $time, pc_in, fetch_valid, pred_valid, pred_target, update_req, update_pc, update_target);
    end

    // =======================================================================
    // TEST SEQUENCE - 10 COMPLETE TESTCASES
    // =======================================================================

    initial begin
        // Default initial values
        clk = 0;
        rst = 1;
        fetch_valid = 0;
        update_req = 0;
        pc_in = 0;
        update_pc = 0;
        update_target = 0;

        // Hold reset
        #20 rst = 0;

        // ------------------ TESTCASE 1 ------------------
        // Lookup MISS (empty BTB)
        fetch_valid = 1;
        pc_in = 32'h0000_1000;
        #10;

        // ------------------ TESTCASE 2 ------------------
        // Update entry for PC=0x1000 -> target=0x2000
        update_req = 1;
        update_pc = 32'h0000_1000;
        update_target = 32'h0000_2000;
        #10 update_req = 0;

        // ------------------ TESTCASE 3 ------------------
        // Lookup HIT at same PC
        pc_in = 32'h0000_1000;
        fetch_valid = 1;
        #10;

        // ------------------ TESTCASE 4 ------------------
        // Lookup MISS for different PC
        pc_in = 32'h0000_3000;   // different tag → MISS
        #10;

        // ------------------ TESTCASE 5 ------------------
        // Conflict test: different PC with same INDEX as 0x1000
        // INDEX bits = 5:2, so choose a PC with same bits [5:2]
        // pc = 0x00005000 → index = (0x5000 >> 2) & 0xF = same index
        pc_in = 32'h0000_5000;
        #10;

        // ------------------ TESTCASE 6 ------------------
        // Update conflicting PC to overwrite entry
        update_req = 1;
        update_pc = 32'h0000_5000;
        update_target = 32'h0000_6000;
        #10 update_req = 0;

        // ------------------ TESTCASE 7 ------------------
        // Now previous PC (0x1000) should MISS (because overwritten)
        pc_in = 32'h0000_1000;
        #10;

        // ------------------ TESTCASE 8 ------------------
        // New PC update for different entry
        update_req = 1;
        update_pc = 32'h0000_A000;
        update_target = 32'h0000_A100;
        #10 update_req = 0;

        // Lookup should HIT
        pc_in = 32'h0000_A000;
        #10;

        // ------------------ TESTCASE 9 ------------------
        // Test sequence of random PCs (misses)
        pc_in = 32'h1234_5678;
        #10;
        pc_in = 32'hABCD_EF00;
        #10;
        pc_in = 32'hFFFF_1111;
        #10;

        // ------------------ TESTCASE 10 ------------------
        // Reset again to test if BTB clears properly
        rst = 1;
        #10 rst = 0;

        // After reset, everything should MISS
        pc_in = 32'h0000_1000;
        #10;

        $stop;
    end

endmodule
