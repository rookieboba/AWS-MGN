#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "[ERROR] 삭제할 CloudFormation 스택 이름을 입력하세요."
  echo "예: ./delete_stack.sh mgn-setup-stack"
  exit 1
fi

STACK_NAME="$1"
echo "[1] CloudFormation 스택 삭제 중: $STACK_NAME"
aws cloudformation delete-stack --stack-name "$STACK_NAME"
echo "[DONE] 스택 삭제 명령이 실행되었습니다."
