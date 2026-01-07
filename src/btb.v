// Branch Target Buffer (BTB) - Direct Mapped, 16 Entries

module btb (
    input clk,                // Clock
    input rst,                // Reset (active high)

    // ---------------------- LOOKUP INTERFACE (FETCH STAGE) -----------------
    input fetch_valid,        // High when PC_in is valid (fetch stage)
    input [31:0] pc_in,       // Current PC from fetch stage
    output reg pred_valid,    // Output: Prediction valid (hit)
    output reg [31:0] pred_target, // Output: Predicted target address

    // ---------------------- UPDATE INTERFACE (EXEC/MEM STAGE) --------------
    input update_req,         // High when CPU wants to update BTB
    input [31:0] update_pc,   // PC of branch to update
    input [31:0] update_target // Actual target after branch resolves
);

    // BTB configuration
    parameter ENTRIES     = 16;
    parameter INDEX_BITS  = 4;   // log2(16)
    parameter TAG_BITS    = 26;  // 32 - INDEX_BITS - 2

    // ------------------------ INTERNAL BTB STORAGE --------------------------
    reg [TAG_BITS-1:0]   tag_array    [0:ENTRIES-1];  // Stored tags
    reg [31:0]           target_array [0:ENTRIES-1];  // Stored target addresses
    reg                  valid_array  [0:ENTRIES-1];  // Valid bit

    // Extract fields from PC for lookup
    wire [INDEX_BITS-1:0] index;
    wire [TAG_BITS-1:0]   tag_in;
    assign index = pc_in[5:2];       // 4 bits for 16 entries
    assign tag_in = pc_in[31:6];     // Remaining upper bits

    // Stored entry at given index
    wire [TAG_BITS-1:0]  stored_tag    = tag_array[index];
    wire [31:0]          stored_target = target_array[index];
    wire                 stored_valid  = valid_array[index];

    // Tag comparison using XNOR reduction
    wire tag_match = &(~(stored_tag ^ tag_in));  // tag_match = 1 when equal

    // ------------------------- BTB LOOKUP LOGIC -----------------------------
    always @(*) begin
        if (fetch_valid && stored_valid && tag_match) begin
            pred_valid  = 1'b1;
            pred_target = stored_target;  // HIT: use BTB target
        end else begin
            pred_valid  = 1'b0;           // MISS: CPU will fetch PC+4
            pred_target = 32'b0;
        end
    end

    // ------------------------- BTB UPDATE LOGIC -----------------------------
    wire [INDEX_BITS-1:0] upd_index = update_pc[5:2];
    wire [TAG_BITS-1:0]   upd_tag   = update_pc[31:6];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Clear all entries on reset
            for (i = 0; i < ENTRIES; i = i + 1) begin
                valid_array[i]  <= 1'b0;
                tag_array[i]    <= 0;
                target_array[i] <= 0;
            end
        end else if (update_req) begin
            // Write new entry during update
            valid_array[upd_index]  <= 1'b1;
            tag_array[upd_index]    <= upd_tag;
            target_array[upd_index] <= update_target;
        end
    end

endmodule
