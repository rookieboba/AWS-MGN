#!/bin/bash

# 입력 파라미터 확인
if [ -z "$1" ]; then
  echo "[ERROR] 스택 이름을 인자로 입력하세요."
  echo "예: ./create_stack.sh my-mgn-stack"
  exit 1
fi

STACK_NAME="$1"

echo "[1] CloudFormation 스택 [$STACK_NAME] 생성 시작..."
aws cloudformation create-stack \
    --stack-name "$STACK_NAME" \
    --template-body file://mgn_setup.yaml \
    --parameters ParameterKey=KeyName,ParameterValue=mgn-key \
    --capabilities CAPABILITY_NAMED_IAM

echo "[2] 스택 생성 완료를 기다리는 중..."
aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"
echo "[DONE] CloudFormation 스택 [$STACK_NAME] 생성 완료"
