// Rule 4: access 에서 pready가 0이면 다음도 access
// tb_top.sv의 module 본문 안에 include하여 사용. begin_case/end_case/step은
// commmon.svh에,  RN은 apb_rules_pkg.sv에 정의되어있음
//
// step 한 줄 = 사이클 하나:
// [ psel, paddr, pwrite, pwdata, penable, pready, prdata, pslverr, exp_fail(예상 fail)]

// ---------------- 리셋 케이스: 모든 규칙 fail 0 ----------------
task automatic r4_reset_at_1();
  begin_case(R4, "Reset Test: successive setup at first cycle");
  step(.presetn_(0), .psel_(1), .penable_(1), .pready_(0));  // T1 wait at asserted reset
  step(.presetn_(1), .psel_(1), .penable_(0));  // T2 setup at de-asserted reset
  end_case();
endtask
task automatic r4_reset_at_2();
  begin_case(R4, "Reset Test: successive setup at second cycle");
  step(.presetn_(1), .psel_(1), .penable_(1));  // T1 wait at de-asserted reset
  step(.presetn_(0), .psel_(1), .penable_(0));  // T2 setup at asserted reset
  end_case();
endtask

// ---------------- Access 아닌 경우 ----------------
task automatic r4_vacuous_pass();
  begin_case(R4, "Expected Vacuous Pass: Not Access");
  for (bit [3:0] fst = 0; fst < 4'b1000; fst = fst + 1'b1) begin
    if (fst != 3'b110) begin
      for (bit [2:0] scnd = 0; scnd < 3'b100; scnd = scnd + 1'b1) begin
        step(.psel_(fst[2]), .penable_(fst[1]), .pready_(fst[0]));
        step(.psel_(scnd[1]), .penable_(scnd[0]), .pready_(&scnd[1:0]));
      end
    end
  end
  end_case();
endtask

// ---------------- Setup에서 전이 ----------------
task automatic r4_from_access_wo_pready();
  begin_case(R4, "from Access wo Pready");
  for (bit [2:0] intr = 0; intr < 3'b100; intr = intr + 1) begin
    step(.psel_(1), .penable_(1), .pready_(0));
    step(.psel_(intr[1]), .penable_(intr[0]), .pready_(&intr), .exp_fail(~&intr[1:0]));
  end
  end_case();
endtask
// ---------------- Covergroup 정의 ---------------
covergroup cg_trans_p3_to_p2 with function sample (bit [2:0] prev, bit [1:0] curr);
  cp_prev: coverpoint prev {bins t[] = {[0 : 7]};}
  cp_curr: coverpoint {psel, penable} {bins t[] = {[0 : 3]};}
  trans_corss: cross cp_prev, cp_curr;
endgroup
cg_trans_p3_to_p2 cg_inst_trans_p3_to_p2;
task automatic cv_rule_4();
  logic [2:0] prev_;
  cg_inst_trans_p3_to_p2 = new();
  forever begin
    prev_ = {psel, penable, pready};
    @(posedge pclk);
    cg_inst_trans_p3_to_p2.sample(prev_, {psel, penable});
  end
endtask

// 규칙 4 진입점: gen이 만드는 run_rule(4) / run_all()이 호출한다. 이름 규칙: run_rule_<N>
task automatic run_rule_4();
  r4_reset_at_1();
  r4_reset_at_2();
  fork
    cv_rule_4();
    begin
      r4_vacuous_pass();
      r4_from_access_wo_pready();
    end
  join_any
  disable fork;
  @(posedge pclk);
  $display("[COVER] R4 Transition Coverage = %0.2f %%", cg_inst_trans_p3_to_p2.get_inst_coverage());
endtask

