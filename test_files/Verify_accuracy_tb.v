module controlled_phase_rotation_tb;
    parameter WIDTH = 16;
    
    // 테스트용 상수 정의
    localparam [WIDTH-1:0] 
        // 입력 상태
        STATE_0 = 16'h0000,      // |0⟩
        STATE_1 = 16'h4000,      // |1⟩
        STATE_PLUS = 16'h2D41,   // (|0⟩ + |1⟩)/√2
        
        // 회전각
        THETA_30  = 16'h2183,    // π/6 (30°)
        THETA_45  = 16'h3243,    // π/4 (45°)
        THETA_60  = 16'h4304,    // π/3 (60°)
        THETA_90  = 16'h6487,    // π/2 (90°)
        THETA_180 = 16'hC90F;    // π   (180°)
    
    // 테스트 신호
    reg clk;
    reg rst;
    reg start;
    reg signed [WIDTH-1:0] control_real, control_imag;
    reg signed [WIDTH-1:0] target_real, target_imag;
    reg signed [WIDTH-1:0] theta;
    wire signed [WIDTH-1:0] out_real, out_imag;
    wire done;
    
    // 결과 저장용 파일
    integer file;
    
    // DUT 인스턴스화
    controlled_phase_rotation #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .control_real(control_real),
        .control_imag(control_imag),
        .target_real(target_real),
        .target_imag(target_imag),
        .theta(theta),
        .out_real(out_real),
        .out_imag(out_imag),
        .done(done)
    );
    
    // 클록 생성
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 테스트 태스크
    task run_test_case;
        input [WIDTH-1:0] ctrl_r;
        input [WIDTH-1:0] ctrl_i;
        input [WIDTH-1:0] tgt_r;
        input [WIDTH-1:0] tgt_i;
        input [WIDTH-1:0] rot_theta;
        input [63:0] test_desc;
        begin
            @(posedge clk);
            control_real = ctrl_r;
            control_imag = ctrl_i;
            target_real = tgt_r;
            target_imag = tgt_i;
            theta = rot_theta;
            
            start = 1;
            @(posedge clk);
            start = 0;
            
            @(posedge done);
            #10;
            
            // 결과 저장
            $fwrite(file, "Test Case: %s\n", test_desc);
            $fwrite(file, "Control: %h + %hi\n", ctrl_r, ctrl_i);
            $fwrite(file, "Target: %h + %hi\n", tgt_r, tgt_i);
            $fwrite(file, "Theta: %h\n", rot_theta);
            $fwrite(file, "Result: %h + %hi\n\n", out_real, out_imag);
            
            #50;
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 파일 열기
        file = $fopen("rotation_test_results.txt", "w");
        
        // 초기화
        rst = 1;
        start = 0;
        #100 rst = 0;
        #100;
        
        // 테스트 케이스 1: |0⟩ 제어, |1⟩ 타겟, 90° 회전
        run_test_case(
            STATE_0, 16'h0000,  // control = |0⟩
            STATE_1, 16'h0000,  // target = |1⟩
            THETA_90,           // 90°
            "Control |0⟩, Target |1⟩, 90° rotation"
        );
        
        // 테스트 케이스 2: |1⟩ 제어, |1⟩ 타겟, 90° 회전
        run_test_case(
            STATE_1, 16'h0000,  // control = |1⟩
            STATE_1, 16'h0000,  // target = |1⟩
            THETA_90,           // 90°
            "Control |1⟩, Target |1⟩, 90° rotation"
        );
        
        // 테스트 케이스 3: |1⟩ 제어, 중첩 상태 타겟, 45° 회전
        run_test_case(
            STATE_1, 16'h0000,  // control = |1⟩
            STATE_PLUS, STATE_PLUS,  // target = (|0⟩ + |1⟩)/√2
            THETA_45,           // 45°
            "Control |1⟩, Target (|0⟩ + |1⟩)/√2, 45° rotation"
        );
        
        // 추가 테스트 케이스들...
        
        #100;
        $fclose(file);
        $finish;
    end
    
endmodule
