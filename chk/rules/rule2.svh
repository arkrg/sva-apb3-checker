// 규칙 2: 첫 Access는 Setup 뒤에 온다
// apb3_chk interface 본문 안에 include된다. s_setup, s_access, fail_cnt, RN은 바깥에서 온다.

property p2_access_after_setup;
  @(posedge pclk) disable iff (!presetn) $rose(penable) |-> $past(psel);
endproperty

a_r2: assert property (p2_access_after_setup)
      else begin fail_cnt[R2]++; $display("%t: R2 fail", $time); end;

