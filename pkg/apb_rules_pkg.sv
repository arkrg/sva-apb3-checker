// 규칙 번호 -> fail_cnt 배열 인덱스. 손으로 관리하는 유일한 목록이다.
// 규칙을 추가할 때: typedef enum에 N순서대로 한 줄 추가(R<N> = N-1, // <description>).
// NRULE는 총 개수를 의미하도록 맨 끝에 유지.
// (scripts/gen_lists.sh가 chk/rules/rule<N>.svh가 있는데 R<N> 정의가 없으면 경고한다.)
package apb_rules_pkg;
  typedef enum int {
    R1 = 0,  // 규칙 1: Setup 다음 사이클은 Access
    R2 = 1,  // 규칙 2: Access 전 사이클은 Setup
    R3 = 2,  // 규칙 3: Penable은 Psel이 1일때만 1이다
    R4 = 3,  // 규칙 4: Pready 되기 전까지 Access 유지
    R5 = 4,  // 규칙 5: 전송중(Setup부터 Access+Pready)엔 Paddr, Pwrite, Pwdata(조건부) 유지
    NRULE
  } rules_e;
endpackage
