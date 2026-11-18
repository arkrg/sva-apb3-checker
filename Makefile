#   make compile          생성 목록 갱신 + xvlog + xelab
#   make run RULE=1       규칙 하나 실행 (기본 RULE=all)
#   make regress (보류)   chk/rules 에 있는 규칙을 하나씩 따로 실행하고 결과를 모은다
#   make gen              include 목록만 생성
#   make clean
#   make cov RULE=1
RULE            ?= all

SHELL := /bin/bash
ROOT  := $(CURDIR)
BUILD   := build
TOP := tb_top
COV := cov_report/rule$(RULE)

# 컴파일 순서: pkg -> chk -> tb. .svh는 컴파일 목록에 넣지 않고 include 경로로만 찾는다.
SRCS    := $(wildcard pkg/*.sv) $(sort $(wildcard chk/*.sv)) $(wildcard tb/*.sv)
INCDIRS := -i ../chk/rules -i ../tb -i ../tb/cases
RULE_NUMS := $(shell ls tb/cases | sed -n 's/^rule\([0-9][0-9]*\)_cases\.svh$$/\1/p' | sort -n)
# RULE_NUMS := $(shell ls tb/cases 2>/dev/null | sed -n 's/^rule\([0-9][0-9]*\)_cases\.svh$$/\1/p' | sort -n)

.PHONY: all gen compile sim run log regress clean
all: run

gen:
	scripts/gen_lists.sh $(ROOT)

compile: gen
	@mkdir -p $(BUILD)
	cd $(BUILD) && xvlog -sv $(INCDIRS) $(addprefix ../,$(SRCS)) -log xvlog.log
	cd $(BUILD) && xelab -debug typical -s $(TOP)_snap work.$(TOP) -log xelab.log

# compile 없이 실행만. 로그에서 판정 줄을 읽는다(xsim은 TB가 FAIL이어도 종료 코드가 0이다).
sim:
	cd $(BUILD) && xsim $(TOP)_snap -R -testplusarg RULE=$(RULE) -log run_$(RULE).log > /dev/null
	@grep -E '\[(PASS|FAIL)\]|MISMATCH|ERROR|RESULT|COVER|DEBUG' $(BUILD)/run_$(RULE).log || true

log:
	@grep -E '\[(PASS|FAIL)\]|MISMATCH|ERROR|RESULT|COVER|DEBUG' $(BUILD)/run_$(RULE).log || true

cov:
	mkdir -p $(BUILD)/$(COV)
	cd $(BUILD) && xcrg -dir ./xsim.covdb -report_dir $(COV) -report_format html
	cd $(BUILD) && firefox ./cov_report/rule$(RULE)/*.html &

run: compile
	@$(MAKE) --no-print-directory sim RULE=$(RULE)

regress: compile
	@fail=0; \
	for n in $(RULE_NUMS); do \
	  echo "=== rule $$n ==="; \
	  $(MAKE) --no-print-directory sim RULE=$$n || fail=1; \
	done; \
	if [ $$fail -eq 0 ]; then echo "REGRESS: PASS"; else echo "REGRESS: FAIL"; fi; \
	exit $$fail

clean:
	rm -rf $(BUILD)/*

wave:
	gtkwave $(BUILD)/wave.vcd &

