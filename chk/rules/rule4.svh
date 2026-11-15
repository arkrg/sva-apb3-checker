// 규칙 4: PREADY=0 없는 Access 다음 cycle은 Access
// apb3_chk interface 본문 안에 include된다. s_setup, s_access, fail_cnt, RN은 바깥에서 온다.

property p4_access_held_until_pready;
  @(posedge pclk) disable iff (!presetn) access && (!pready) |=> s_access;
endproperty

a_r4: assert property (p4_access_held_until_pready)
      else begin fail_cnt[R4]++; $display("%t: R4 fail", $time); end;

