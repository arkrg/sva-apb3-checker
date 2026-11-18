// 고정 top. 규칙이 늘어도 이 파일은 바뀌지 않는다.
// 실행할 규칙은 plusarg로 고른다:  +RULE=1  /  +RULE=all (기본값 all)
module tb_top;
  import apb_rules_pkg::*;

  bit pclk, presetn, presetn_c, presetn_t;
  logic psel = 0, penable = 0, pwrite = 0;
  logic pready = 0, pslverr = 0;
  logic [ADDR_WIDTH-1:0] paddr = 0;
  logic [DATA_WIDTH-1:0] pwdata = 0, prdata = 0;
  assign presetn = (presetn_c & presetn_t);
  apb3_chk chk (.*);
  always #5 pclk = ~pclk;

  `include "tb_common.svh"  // begin_case / end_case / step
  `include "tb_cases.svh"  // 생성 파일: 규칙별 케이스 include + run_rule(n) + run_all()

  initial begin
    string rule_str;
    if (!$value$plusargs("RULE=%s", rule_str)) rule_str = "all";

    repeat (2) @(posedge pclk);
    presetn_t = 1;
    if (rule_str == "all") run_all();
    else run_rule(rule_str.atoi());

    $display("RESULT: %s (RULE=%s, Mismatch %0d)", total_err == 0 ? "PASS" : "FAIL", rule_str,
             total_err);
    $finish;
  end
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
  end
endmodule
