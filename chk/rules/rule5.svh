// 규칙 5: 전송 중 안정성 psel, paddr, pwrite[, pwdata (pwrite==1이면)]
// apb3_chk interface 본문 안에 include된다. s_setup, s_access, fail_cnt, RN은 바깥에서 온다.

property p5_stable_until_pready;
  @(posedge pclk) disable iff (!presetn) s_setup |=>
      $stable({paddr, pwrite})
      and pwrite |-> $stable(pwdata);
endproperty

a_r5: assert property (p5_stable_until_pready)
      else begin fail_cnt[R5]++; $display("%t: R5 fail", $time); end;

