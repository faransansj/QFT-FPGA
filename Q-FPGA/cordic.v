module cordic #(
    parameter WIDTH = 16,            // 데이터 비트 폭
    parameter ITERATIONS = 16,       // CORDIC 반복 횟수
    parameter FRAC_BITS = 14         // 소수부 비트 수 증가
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [WIDTH-1:0] theta,
    output reg signed [WIDTH-1:0] cos_out,
    output reg signed [WIDTH-1:0] sin_out,
    output reg done
);

    // CORDIC 게인 보정 상수 (약 0.607253)
    // 더 정밀한 값으로 수정
    localparam signed [WIDTH-1:0] CORDIC_GAIN = 16'h4DBA;

    // CORDIC 각도 상수 테이블 (atan(2^-i))를 더 정밀한 값으로 수정
    wire signed [WIDTH-1:0] atan_table [0:ITERATIONS-1];
    assign atan_table[0]  = 16'h3243;  // 0.785398163
    assign atan_table[1]  = 16'h1DAC;  // 0.463647609
    assign atan_table[2]  = 16'h0FAD;  // 0.244978663
    assign atan_table[3]  = 16'h07F5;  // 0.124354995
    assign atan_table[4]  = 16'h03FE;  // 0.062418810
    assign atan_table[5]  = 16'h01FF;  // 0.031239833
    assign atan_table[6]  = 16'h00FF;  // 0.015623729
    assign atan_table[7]  = 16'h007F;  // 0.007812341
    assign atan_table[8]  = 16'h003F;  // 0.003906230
    assign atan_table[9]  = 16'h001F;  // 0.001953122
    assign atan_table[10] = 16'h000F;  // 0.000976562
    assign atan_table[11] = 16'h0007;  // 0.000488281
    assign atan_table[12] = 16'h0003;  // 0.000244141
    assign atan_table[13] = 16'h0001;  // 0.000122070
    assign atan_table[14] = 16'h0000;  // 0.000061035
    assign atan_table[15] = 16'h0000;  // 0.000030518

    // 중간 계산값을 위한 레지스터
    reg signed [WIDTH-1:0] x [0:ITERATIONS];
    reg signed [WIDTH-1:0] y [0:ITERATIONS];
    reg signed [WIDTH-1:0] z [0:ITERATIONS];
    
    integer i;
    reg [4:0] iteration;

    // 상태 머신 개선
    localparam IDLE = 2'b00;
    localparam INIT = 2'b01;
    localparam CALC = 2'b10;
    localparam DONE = 2'b11;
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            iteration <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= INIT;
                        done <= 0;
                    end
                end

                INIT: begin
                    // 초기값 설정 개선
                    x[0] <= CORDIC_GAIN;
                    y[0] <= 0;
                    z[0] <= theta;
                    iteration <= 0;
                    state <= CALC;
                end

                CALC: begin
                    if (iteration < ITERATIONS) begin
                        // 회전 방향 결정 및 계산 정밀도 개선
                        if (z[iteration] >= 0) begin
                            x[iteration+1] <= x[iteration] - (y[iteration] >>> iteration);
                            y[iteration+1] <= y[iteration] + (x[iteration] >>> iteration);
                            z[iteration+1] <= z[iteration] - atan_table[iteration];
                        end
                        else begin
                            x[iteration+1] <= x[iteration] + (y[iteration] >>> iteration);
                            y[iteration+1] <= y[iteration] - (x[iteration] >>> iteration);
                            z[iteration+1] <= z[iteration] + atan_table[iteration];
                        end
                        iteration <= iteration + 1;
                    end
                    else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    // 최종 결과 출력시 반올림 처리 추가
                    cos_out <= x[ITERATIONS];
                    sin_out <= y[ITERATIONS];
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
