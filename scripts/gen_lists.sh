#!/usr/bin/env bash
# chk/rules/rule<N>.svh 와 tb/cases/rule<N>_cases.svh 를 훑어서 include 목록과 호출 연결을 생성한다.
# 사용: scripts/gen_lists.sh <repo 루트> <출력 폴더>
#   생성: <출력>/chk_rules.svh   (checker가 include할 규칙 파일 목록)
#         <출력>/tb_cases.svh    (케이스 파일 include + run_rule(n) + run_all())
set -euo pipefail
root=${1:?repo 루트 경로}
out=${2:?출력 폴더}
mkdir -p "$out"

# ---- Alias ----
ws="[[:space:]]*"

nums() { # $1=폴더 $2=sed 패턴(번호를 \1로 잡는다) -> 번호를 숫자 오름차순으로 출력
    ls "$1" 2>/dev/null | sed -n "$2" | sort -n
}
chk_nums=$(nums "$root/chk/rules" 's/^rule\([0-9][0-9]*\)\.svh$/\1/p')
case_nums=$(nums "$root/tb/cases" 's/^rule\([0-9][0-9]*\)_cases\.svh$/\1/p')

# ---- 짝이 안 맞는 경우와 pkg에 R<N> = <N-1>이 없는 경우를 Warning ----
for n in $chk_nums; do
    grep -qx "$n" <<<"$case_nums" || echo "Warning: rule$n.svh is present but rule${n}_cases.svh is missing" >&2
    grep -E "\bR${n}${ws}=${ws}$((n - 1))${ws}" "$root/pkg/apb_rules_pkg.sv" ||
        echo "Warning: pkg/apb_rules_pkg.sv 에 R${n} 정의 여부, 패턴 확인" >&2
done
for n in $case_nums; do
    grep -qx "$n" <<<"$chk_nums" || echo "Warning: rule${n}_cases.svh is present but rule$n.svh is missing" >&2
done

# ---- chk_rules.svh ----
{
    echo "// 생성 파일(scripts/gen_lists.sh). 직접 고치지 않는다."
    for n in $chk_nums; do
        printf '`include "rule%s.svh"\n' "$n"
    done
} >"$out/chk_rules.svh"

# ---- tb_cases.svh ----
{
    echo "// 생성 파일(scripts/gen_lists.sh). 직접 고치지 않는다."
    for n in $case_nums; do
        printf '`include "rule%s_cases.svh"\n' "$n"
    done
    echo
    echo "task automatic run_rule(input int n);"
    echo "  case (n)"
    for n in $case_nums; do
        printf '    %s: run_rule_%s();\n' "$n" "$n"
    done
    echo '    default: begin'
    echo '      $display("  [ERROR] 케이스가 없는 규칙 번호: %0d", n);'
    echo '      total_err++;'
    echo '    end'
    echo "  endcase"
    echo "endtask"
    echo
    echo "task automatic run_all();"
    for n in $case_nums; do
        printf '  run_rule_%s();\n' "$n"
    done
    echo "endtask"
} >"$out/tb_cases.svh"

echo "생성: chk 규칙 [$(echo $chk_nums)]  케이스 규칙 [$(echo $case_nums)]"
