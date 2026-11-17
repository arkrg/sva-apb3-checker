package apb_checker_pkg;
  localparam int WIDTH_DATA = 32;
  localparam int WIDTH_ADDR = 32;

  typedef enum int {
    R1 = 0,  // 규칙 1: Setup 다음 사이클은 Access
    R2 = 1,  // 규칙 2: Access 전 사이클은 Setup
    R3 = 2,  // 규칙 3: Penable은 Psel이 1일때만 1이다
    R4 = 3,  // 규칙 4: Pready 되기 전까지 Access 유지
    R5 = 4,  // 규칙 5: 전송중(Setup부터 Access+Pready)엔 Paddr, Pwrite, Pwdata(조건부) 유지
    NRULE
  } rules_e;

endpackage

import apb_checker_pkg::*;
