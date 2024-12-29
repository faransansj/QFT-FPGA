// 복소수 곱셈 모듈
module complex_multiplier #(
    parameter INT_WIDTH = 8,    // 정수부 비트 수
    parameter FRAC_WIDTH = 8    // 소수부 비트 수
) (
    input wire clk,
    input wire rst,
    
    // 입력 A (a + bi)
    input wire signed [INT_WIDTH+FRAC_WIDTH-1:0] a_real,
    input wire signed [INT_WIDTH+FRAC_WIDTH-1:0] a_imag,
    
    // 입력 B (c + di)
    input wire signed [INT_WIDTH+FRAC_WIDTH-1:0] b_real,
    input wire signed [INT_WIDTH+FRAC_WIDTH-1:0] b_imag,
    
    // 출력 (ac-bd) + (ad+bc)i
    output reg signed [INT_WIDTH+FRAC_WIDTH-1:0] out_real,
    output reg signed [INT_WIDTH+FRAC_WIDTH-1:0] out_imag,
    
    // 제어 신호
    input wire start,
    output reg done
);

    // 중간 결과 저장용 레지스터
    reg signed [2*(INT_WIDTH+FRAC_WIDTH)-1:0] ac, bd, ad, bc;
    
    // 상태 정의
    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;
    
    reg [1:0] state, next_state;
    
    // 상태 머신
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // 다음 상태 로직
    always @(*) begin
        case (state)
            IDLE: next_state = start ? CALC : IDLE;
            CALC: next_state = DONE;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end
    
    // 데이터패스 로직
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                done <= 0;
            end
            
            CALC: begin
                // 복소수 곱셈 수행
                ac <= (a_real * b_real) >>> FRAC_WIDTH;
                bd <= (a_imag * b_imag) >>> FRAC_WIDTH;
                ad <= (a_real * b_imag) >>> FRAC_WIDTH;
                bc <= (a_imag * b_real) >>> FRAC_WIDTH;
            end
            
            DONE: begin
                // 최종 결과 계산
                out_real <= ac - bd;
                out_imag <= ad + bc;
                done <= 1;
            end
        endcase
    end

endmodule
