// testbench.sv
`timescale 1ns/1ps

module testbench;

    // ---------- DUT instantiation ----------
    logic clk, rst;
    top_module dut (.*);  // assumes top_module ports are clk, rst

    // ---------- Clock generation ----------
    always #5 clk = ~clk; // 100 MHz

    // ---------- References and shadow state ----------
    reg [31:0] regs_ref [0:31];
    reg [31:0] dmem_ref [0:255];
    reg [31:0] pc_ref;

    // ---------- Helper tasks ----------
    // Load program into instruction memory
    task load_program(input [31:0] prog[0:255]);
        for (int i=0; i<256; i++) begin
            dut.imem_inst.imem[i] = prog[i];
        end
    endtask

    // Reset CPU
    task reset_cpu();
        rst = 1;
        #20;
        rst = 0;
        #20;
        // Initialize reference state
        for (int i=0; i<32; i++) regs_ref[i] = 32'd0;
        for (int i=0; i<256; i++) dmem_ref[i] = 32'd0;
        pc_ref = 32'd0;
    endtask

    // Run for a given number of cycles
    task run_cycles(int cycles);
        repeat (cycles) @(posedge clk);
    endtask

    // Check register file against reference
    task check_regs();
        bit err = 0;
        for (int i=0; i<32; i++) begin
            if (dut.regfile_inst.registers[i] !== regs_ref[i]) begin
                $display("ERROR: reg[%0d] expected %h, got %h", i, regs_ref[i], dut.regfile_inst.registers[i]);
                err = 1;
            end
        end
        if (!err) $display("Register file OK");
    endtask

    // Check data memory
    task check_dmem();
        bit err = 0;
        for (int i=0; i<256; i++) begin
            if (dut.dmem_inst.dmem[i] !== dmem_ref[i]) begin
                $display("ERROR: dmem[%0d] expected %h, got %h", i, dmem_ref[i], dut.dmem_inst.dmem[i]);
                err = 1;
            end
        end
        if (!err) $display("Data memory OK");
    endtask

    // ---------- Reference model update ----------
    // We update refs after each instruction by decoding and executing
    // This is a simplified model; we'll implement a full model in the test.
    // For brevity, we show a partial implementation.
    function automatic [31:0] ref_alu(input [31:0] a, b, input [3:0] alu_ctrl);
        // as defined earlier
    endfunction

    // This task executes one instruction in the reference model
    task ref_step(input [31:0] instr, input [31:0] pc_val);
        // Decode and update regs_ref and dmem_ref
        // ... full implementation (see final code)
    endtask

    // ---------- Directed tests ----------
    task test_r_type();
        $display("Running R‑type test...");
        reset_cpu();
        // Load program (simplified) – full program in final code
        // ...
        run_cycles(50);
        check_regs();
    endtask

    // ... (similar for each test group)

    task test_all_directed();
        test_r_type();
        test_i_type();
        test_load_store();
        test_branches();
        test_jumps();
        test_lui_auipc();
        test_corners();
    endtask

    // ---------- Random test ----------
    task test_random(int num_instr);
        $display("Running %0d random instructions...", num_instr);
        reset_cpu();
        for (int i=0; i<num_instr; i++) begin
            // Generate random instruction (constrained)
            // Write to memory at current PC
            // Step DUT for one cycle
            // Update reference and compare
        end
        $display("Random test completed.");
    endtask

    // ---------- Main test sequence ----------
    initial begin
        $display("Starting RISC‑V CPU verification...");
        clk = 0;
        rst = 1;
        #20 rst = 0;

        // Run directed tests
        test_all_directed();

        // Run random tests
        test_random(100);

        // Final report
        $display("Verification complete.");
        $finish;
    end

    // ---------- Coverage (optional) ----------
    // covergroup, etc.

endmodule