// 규칙 1: Setup 다음 사이클은 Access
// apb3_chk interface 본문 안에 include된다. s_setup, s_access, fail_cnt, RN은 바깥에서 온다.

property p1_setup_then_access;
  @(posedge pclk) disable iff (!presetn) s_setup |=> s_access;
endproperty

a_r1: assert property (p1_setup_then_access)
      else begin fail_cnt[R1]++; $display("%t: R1 fail", $time); end;

// c_r1: cover property (@(posedge pclk) disable iff (!presetn) s_setup ##1 s_access);
