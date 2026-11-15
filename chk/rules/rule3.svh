// 규칙 3: penable=1일 땐 psel=1이 1이어야 함
// apb3_chk interface 본문 안에 include된다. s_setup, s_access, fail_cnt, RN은 바깥에서 온다.

property p3_penable_requires_psel;
  @(posedge pclk) disable iff (!presetn) penable |-> psel;
endproperty

a_r3: assert property (p3_penable_requires_psel)
      else begin fail_cnt[R3]++; $display("%t: R3 fail", $time); end;

