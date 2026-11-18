// tb_top.sv의 module 본문 안에서 include되는 공통부분. 규칙이 늘어도 바뀌지 않는다.
// 전제: 같은 module 안에 chk(apb3_chk 인스턴스)와 구동 신호들이 이미 선언되어 있다.

int prev[NRULE];  // 직전 사이클까지의 fail 횟수
int cyc;  // 케이스 안의 사이클 번호(T1, T2, ...)
int case_err;  // 현재 케이스의 불일치 횟수
int total_err = 0;  // 전체 불일치 횟수
string case_name;
rules_e rule_num;

task automatic begin_case(input rules_e rule, input string name);
  rule_num = rule;
  case_name = {string'(rule), name};
  cyc = 0;
  case_err = 0;
  prev[rule_num] = chk.fail_cnt[rule_num];
endtask

task automatic end_case();
  $display("[%s] %s", case_err == 0 ? "PASS" : "FAIL", case_name);
  total_err += case_err;
endtask

// exp_mask의 비트 i = 1이면 "이 사이클에 규칙 i+1이 fail해야 함". 적지 않으면 0(아무 규칙도 fail하면 안 됨).
task automatic step(input bit presetn_ = 'b1, input logic psel_ = 'bx,
                    input logic [ADDR_WIDTH-1:0] paddr_ = 'bx, input logic pwrite_ = 'bx,
                    input logic [DATA_WIDTH-1:0] pwdata_ = 'bx, input logic penable_ = 'bx,
                    input logic pready_ = 'bx, input logic [DATA_WIDTH-1:0] prdata_ = 'bx,
                    input logic pslverr_ = 'bx, input int exp_fail = 0);
  int d;
  presetn_c = presetn_;
  psel = psel_;
  paddr = paddr_;
  pwrite = pwrite_;
  pwdata = pwdata_;
  penable = penable_;
  pready = pready_;
  prdata = prdata_;
  pslverr = pslverr_;
  @(posedge pclk);
  #0;  // assert의 reactive 영역에서 fail_cnt값이 반영되므로 지연시키기
  cyc++;
  d = chk.fail_cnt[rule_num] - prev[rule_num];
  if (d != exp_fail) begin
    $display("  [MISMATCH] T%0d R%0d exp=%0d got=%0d", cyc, int'(rule_num) + 1, exp_fail, d);
    case_err++;
  end
  prev[rule_num] = chk.fail_cnt[rule_num];
endtask
