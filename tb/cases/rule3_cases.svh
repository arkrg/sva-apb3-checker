// Rule 3: penable은 psel=1일때만 1이다 Rule1과 마찬가지로 penable과 psel만 관여
// tb_top.sv의 module 본문 안에 include하여 사용. begin_case/end_case/step은
// commmon.svh에,  R1은 apb_rules_pkg.sv에 정의되어있음
//
// step 한 줄 = 사이클 하나:
// [ psel, paddr, pwrite, pwdata, penable, pready, prdata, pslverr, exp_fail(예상 fail)]

// 기대 fail 칸이 비어 있으면 "어떤 규칙도 fail하지 않아야 함"
// ---------------- 리셋 케이스: 모든 규칙 fail 0 ----------------
task automatic r3_reset();
  begin_case(R3, "Reset Test: successive setup at first cycle");
  step(.presetn_(1), .psel_(0), .penable_(1), .exp_fail(1));  // T1 peanble =1, psel = 0
  step(.presetn_(0), .psel_(0), .penable_(1));  // T2 assert reset
  step(.presetn_(0), .psel_(0), .penable_(0));  // T3 case clear
  end_case();
endtask

// ---------------- 패턴 전이 케이스 ----------------
task automatic r3_sweep_psel_penable();
  begin_case(R3, "Sweep all 4 value of {psel, penable}");
  step(.psel_(0), .penable_(0));
  step(.psel_(0), .penable_(1), .exp_fail(1));
  step(.psel_(1), .penable_(0));
  step(.psel_(1), .penable_(1));
  end_case();
endtask
// ---------------- 패턴 전이 Cover Group ----------------
covergroup cg_comb_psel_penable @(posedge pclk);
  coverpoint {psel, penable};
endgroup
cg_comb_psel_penable cg_inst_comb_psel_penable;

// 규칙 3 진입점: gen이 만드는 run_rule(3) / run_all()이 호출한다. 이름 규칙: run_rule_<N>
task automatic run_rule_3();
  r3_reset();
  cg_inst_comb_psel_penable = new();
  r3_sweep_psel_penable();
  $display("[COVER] R2 Transition Coverage = %0.2f %%",
           cg_inst_comb_psel_penable.get_inst_coverage());
endtask

