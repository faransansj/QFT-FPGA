`timescale 1ns / 1ps

module complex_multiplier_tb();
    // Parameters
    parameter INT_WIDTH = 8;
    parameter FRAC_WIDTH = 8;
    
    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [INT_WIDTH+FRAC_WIDTH-1:0] a_real;
    reg [INT_WIDTH+FRAC_WIDTH-1:0] a_imag;
    reg [INT_WIDTH+FRAC_WIDTH-1:0] b_real;
    reg [INT_WIDTH+FRAC_WIDTH-1:0] b_imag;
    
    // Outputs
    wire [INT_WIDTH+FRAC_WIDTH-1:0] out_real;
    wire [INT_WIDTH+FRAC_WIDTH-1:0] out_imag;
    wire done;
    
    // Instantiate the Unit Under Test (UUT)
    complex_multiplier uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .out_real(out_real),
        .out_imag(out_imag),
        .done(done)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        start = 0;
        a_real = 0;
        a_imag = 0;
        b_real = 0;
        b_imag = 0;
        
        // Wait 100 ns for global reset
        #100;
        rst = 0;
        
        // Test case
        #100;
        a_real = 16'h0100;  // 1.0
        a_imag = 16'h0000;  // 0.0
        b_real = 16'h0100;  // 1.0
        b_imag = 16'h0000;  // 0.0
        start = 1;
        
        #10;
        start = 0;
        
        // Wait for done signal
        @(posedge done);
        
        // Add more test cases as needed
        
        #1000;
        $finish;
    end
endmodule
