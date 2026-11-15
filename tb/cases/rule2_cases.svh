// Rule 2: 첫 Access는 Setup을 뒤따름
// tb_top.sv의 module 본문 안에 include하여 사용. begin_case/end_case/step은
// commmon.svh에,  R1은 apb_rules_pkg.sv에 정의되어있음
//
// step 한 줄 = 사이클 하나:
// [ psel, paddr, pwrite, pwdata, penable, pready, prdata, pslverr, exp_fail(예상 fail)]

// ---------------- 리셋 케이스: 모든 규칙 fail 0 ----------------
task automatic r2_reset_at_1();
  begin_case(R2, "Reset Test: successive setup at first cycle");
  step(.presetn_(0), .psel_(0), .penable_(0));  // T1 setup at asserted reset
  step(.presetn_(1), .psel_(1), .penable_(1));  // T2 setup at de-asserted reset
  step(.presetn_(0), .psel_(0), .penable_(0));  // T3 case clear
  end_case();
endtask
task automatic r2_reset_at_2();
  begin_case(R2, "Reset Test: successive setup at second cycle");
  step(.presetn_(1), .psel_(0), .penable_(0));  // T1 setup at de-asserted reset
  step(.presetn_(0), .psel_(1), .penable_(1));  // T2 setup at asserted reset
  step(.presetn_(0), .psel_(0), .penable_(0));  // T3 case clear
  end_case();
endtask

// ---------------- 패턴 전이 케이스 ----------------
task automatic r2_sweep_psel_penable_transition();
  begin_case(R2, "Sweep all 16 two-cycle transitions of {psel, penable}");
  step(.psel_(0), .penable_(0));
  step(.psel_(0), .penable_(0));
  step(.psel_(0), .penable_(1), .exp_fail(1));
  step(.psel_(0), .penable_(1));
  step(.psel_(0), .penable_(0));
  step(.psel_(1), .penable_(0));
  step(.psel_(1), .penable_(0));
  step(.psel_(1), .penable_(1));
  step(.psel_(1), .penable_(1));
  step(.psel_(0), .penable_(1));
  step(.psel_(1), .penable_(1));
  step(.psel_(1), .penable_(0));
  step(.psel_(0), .penable_(1));
  step(.psel_(1), .penable_(0));
  step(.psel_(0), .penable_(0));
  step(.psel_(1), .penable_(1), .exp_fail(1));
  step(.psel_(0), .penable_(0));
  end_case();
endtask


// 규칙 2 진입점: gen이 만드는 run_rule(2) / run_all()이 호출한다. 이름 규칙: run_rule_<N>
task automatic run_rule_2();
  r2_reset_at_1();
  r2_reset_at_2();
  cg_inst_trans_psel_penable = new();
  r2_sweep_psel_penable_transition();
  $display("[COVER] R2 Transition Coverage = %0.2f %%",
           cg_inst_trans_psel_penable.get_inst_coverage());
endtask

