// checker: SVA + 규칙별 fail 카운터만 담는다. TB를 알지 못한다.
// 규칙 파일(rules/rule<N>.svh)은 이 interface 본문 안에 include된다.
// include 목록은 Makefile(scripts/gen_lists.sh)이 sim/gen/chk_rules.svh로 생성한다.
// 컴파일 미확인. s_setup / s_access는 PREADY를 보지 않는 정의로 새로 썼다(기존 사용자 정의 원문과 다를 수 있음).
module apb3_chk (
    input logic pclk,
    presetn,
    input logic psel,
    penable,
    pready,
    pwrite,
    input logic [WIDTH_ADDR-1:0] paddr,
    input logic [WIDTH_DATA-1:0] pwdata
);
  import apb_rules_pkg::*;

  int fail_cnt[NRULE];  // 규칙별 fail 횟수 (int는 0으로 시작)
  wire setup = psel && !penable;
  wire access = psel && penable;
  // 여러 규칙이 공유하는 sequence

  sequence s_setup; setup; endsequence
  sequence s_access; access; endsequence

  `include "chk_rules.svh"  // 생성 파일: 규칙 파일 include 목록
endmodule
