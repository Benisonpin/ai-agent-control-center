CC = gcc
CFLAGS = -Wall -g -I./hal/inc
LDFLAGS = -pthread

# 目標
all: test_ums_basic

# HAL 函式庫
hal_ums.o: hal/src/ums_wrapper.c
	$(CC) $(CFLAGS) -c $< -o $@0
	
test_ums_basic: tests/unit/test_ums_basic.c hal_ums.o
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

# 執行測試
test: test_ums_basic
	./test_ums_basic

# 清理
clean:
	rm -f *.o test_ums_basic

.PHONY: all test clean
