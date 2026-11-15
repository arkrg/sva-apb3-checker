// Rule 1: Setup 다음 사이클은 Access, psel과 peanble만 관여
// tb_top.sv의 module 본문 안에 include하여 사용. begin_case/end_case/step은
// commmon.svh에,  R1은 apb_rules_pkg.sv에 정의되어있음
//
// step 한 줄 = 사이클 하나:
// [ psel, paddr, pwrite, pwdata, penable, pready, prdata, pslverr, exp_fail(예상 fail)]

// 기대 fail 칸이 비어 있으면 "어떤 규칙도 fail하지 않아야 함"

// ---------------- 리셋 케이스: 모든 규칙 fail 0 ----------------
task automatic r1_reset_at_1();
  begin_case(NRULE, "Reset Test: successive setup at first cycle");
  step(.presetn_(0), .psel_(1), .penable_(0));  // T1 setup at asserted reset
  step(.presetn_(1), .psel_(1), .penable_(0));  // T2 setup at de-asserted reset
  step(.presetn_(0), .psel_(0), .penable_(0));  // T3 case clear
  end_case();
endtask
task automatic r1_reset_at_2();
  begin_case(NRULE, "Reset Test: successive setup at second cycle");
  step(.presetn_(1), .psel_(1), .penable_(0));  // T1 setup at de-asserted reset
  step(.presetn_(0), .psel_(1), .penable_(0));  // T2 setup at asserted reset
  step(.presetn_(0), .psel_(0), .penable_(0));  // T3 case clear
  end_case();
endtask

// ---------------- 패턴 전이 케이스 ----------------
task automatic r1_sweep_psel_penable_transition();
  begin_case(R1, "Sweep all 16 two-cycle transitions of {psel, penable}");
  step(.psel_(0), .penable_(0));
  step(.psel_(0), .penable_(0));
  step(.psel_(0), .penable_(1));
  step(.psel_(0), .penable_(1));
  step(.psel_(0), .penable_(0));
  step(.psel_(1), .penable_(0));
  step(.psel_(1), .penable_(0), .exp_fail(1));
  step(.psel_(1), .penable_(1));
  step(.psel_(1), .penable_(1));
  step(.psel_(0), .penable_(1));
  step(.psel_(1), .penable_(1));
  step(.psel_(1), .penable_(0));
  step(.psel_(0), .penable_(1), .exp_fail(1));
  step(.psel_(1), .penable_(0));
  step(.psel_(0), .penable_(0), .exp_fail(1));
  step(.psel_(1), .penable_(1));
  step(.psel_(0), .penable_(0));
  end_case();
endtask
// ---------------- 패턴 전이 Cover Group ----------------
covergroup cg_trans_psel_penable @(posedge pclk);
  coverpoint {psel, penable} {bins t[] = ([0 : 3] => [0 : 3]);}
endgroup
cg_trans_psel_penable cg_inst_trans_psel_penable;

// 규칙 1 진입점: gen이 만드는 run_rule(1) / run_all()이 호출한다. 이름 규칙: run_rule_<N>
task automatic run_rule_1();
  r1_reset_at_1();
  r1_reset_at_2();
  cg_inst_trans_psel_penable = new();
  r1_sweep_psel_penable_transition();
  $display("[COVER] R1 Transition Coverage = %0.2f %%",
           cg_inst_trans_psel_penable.get_inst_coverage());
endtask

