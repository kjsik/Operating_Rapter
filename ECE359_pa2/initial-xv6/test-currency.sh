#!/bin/bash
set -e 

GREEN='\033[0;32m'
RED='\033[0;31m'
NONE='\033[0m'

XV6_DIR="xv6-public"
TEST_DIR="tests"
TESTS_OUT="tests-out"

TEST_LIST=("cur2" "cur3")

C_FILE_TESTS=("test_currency2" "test_currency3")
TEST_NAMES_STR=$(IFS=,; echo "${C_FILE_TESTS[*]}")


echo "=====  Initializing Test Environment ====="
echo "Cleaning $XV6_DIR..."
(cd $XV6_DIR && make clean) > /dev/null 2>&1 || true

echo "Generating temporary Makefile ($XV6_DIR/Makefile.test)..."
gawk -vtestnames=$TEST_NAMES_STR '
BEGIN {
    n = split(testnames, x, ",");
}
($1 == "_mkdir\\") {
    for (i = 1; i <= n; i++) {
        printf("\t_%s\\\n", x[i]);
    }
} 
{
    print $0;
}
END {
    for (i = 1; i <= n; i++) {
        printf("\nifneq ($(wildcard %s.c),%s.c)\n", x[i], x[i]);
        printf("%s.o:\n", x[i]);
        printf("endif\n");
    }
}
' $XV6_DIR/Makefile > $XV6_DIR/Makefile.test

echo "Copying object files to $XV6_DIR..."
cp $TEST_DIR/test_currency2.o $XV6_DIR/
cp $TEST_DIR/test_currency3.o $XV6_DIR/

echo "Building xv6 (linking files using Makefile.test)..."
(cd $XV6_DIR && make -f Makefile.test) > /dev/null 2>&1
echo "Build complete."
echo ""

mkdir -p $TESTS_OUT

for test_name in "${TEST_LIST[@]}"
do
    echo "===== Running Test: $test_name ====="
    
    RUN_FILE="$TEST_DIR/$test_name.run"
    GOLDEN_OUT_FILE="$TEST_DIR/$test_name.out"
    ACTUAL_OUT_FILE="$TESTS_OUT/$test_name.out"

    if [ ! -f "$RUN_FILE" ]; then
        echo -e "${RED}ERROR: Cannot find run script $RUN_FILE${NONE}"
        continue
    fi
    if [ ! -f "$GOLDEN_OUT_FILE" ]; then
        echo -e "${RED}ERROR: Cannot find golden output file $GOLDEN_OUT_FILE${NONE}"
        continue
    fi

    chmod +x $RUN_FILE
    
    echo "Executing $RUN_FILE..."
    
    $RUN_FILE > $ACTUAL_OUT_FILE 2>&1
    
    echo "Comparing results..."
    if diff -q $GOLDEN_OUT_FILE $ACTUAL_OUT_FILE >/dev/null; then
        echo -e "test $test_name: ${GREEN}passed${NONE}"
    else
        echo -e "test $test_name: ${RED}FAILED${NONE}"
        echo "    Compare $GOLDEN_OUT_FILE (Expected) vs $ACTUAL_OUT_FILE (Actual)"
        echo "    To debug, run: diff $GOLDEN_OUT_FILE $ACTUAL_OUT_FILE"
    fi
    echo ""
done