module cordic_tb();
    parameter WIDTH = 16;
    
    reg clk;
    reg rst;
    reg start;
    reg signed [WIDTH-1:0] theta;
    wire signed [WIDTH-1:0] cos_out;
    wire signed [WIDTH-1:0] sin_out;
    wire done;
    
    // 테스트 케이스를 위한 각도 상수 정의
    localparam [WIDTH-1:0] 
        ANGLE_0   = 16'h0000,    //   0도
        ANGLE_30  = 16'h2183,    //  30도
        ANGLE_45  = 16'h3243,    //  45도
        ANGLE_60  = 16'h4304,    //  60도
        ANGLE_90  = 16'h6487,    //  90도
        ANGLE_180 = 16'hC90F,    // 180도
        ANGLE_270 = 16'h2D97;    // 270도
    
    // DUT 인스턴스화
    cordic #(
        .WIDTH(WIDTH),
        .ITERATIONS(16)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .theta(theta),
        .cos_out(cos_out),
        .sin_out(sin_out),
        .done(done)
    );

    // 클록 생성
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 결과 검증을 위한 태스크
    task check_result;
        input [WIDTH-1:0] angle;
        input real expected_cos;
        input real expected_sin;
        begin
            theta = angle;
            start = 1;
            #10 start = 0;
            @(posedge done);
            $display("Angle: %0d degrees", angle * 180.0 / 16'h6487);
            $display("Expected: cos = %f, sin = %f", expected_cos, expected_sin);
            $display("Got: cos = %h, sin = %h", cos_out, sin_out);
            $display("------------------------------");
            #50;
        end
    endtask

    // 테스트 시나리오
    initial begin
        // 초기화
        rst = 1;
        start = 0;
        theta = 0;
        #100 rst = 0;
        
        // 다양한 각도 테스트
        check_result(ANGLE_0,   1.0,    0.0);    //   0도
        check_result(ANGLE_30,  0.866,  0.5);    //  30도
        check_result(ANGLE_45,  0.707,  0.707);  //  45도
        check_result(ANGLE_60,  0.5,    0.866);  //  60도
        check_result(ANGLE_90,  0.0,    1.0);    //  90도
        check_result(ANGLE_180, -1.0,   0.0);    // 180도
        check_result(ANGLE_270, 0.0,    -1.0);   // 270도
        
        #100 $finish;
    end

endmodule
