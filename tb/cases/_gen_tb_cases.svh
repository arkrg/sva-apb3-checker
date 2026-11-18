// 생성 파일(scripts/gen_lists.sh). 직접 고치지 않는다.
`include "rule1_cases.svh"
`include "rule2_cases.svh"
`include "rule3_cases.svh"
`include "rule4_cases.svh"

task automatic run_rule(input int n);
  case (n)
    1: run_rule_1();
    2: run_rule_2();
    3: run_rule_3();
    4: run_rule_4();
    default: begin
      $display("  [ERROR] 케이스가 없는 규칙 번호: %0d", n);
      total_err++;
    end
  endcase
endtask

task automatic run_all();
  run_rule_1();
  run_rule_2();
  run_rule_3();
  run_rule_4();
endtask
