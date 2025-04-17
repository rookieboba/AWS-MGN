#!/bin/bash
STACK_NAME=mgn-setup-stack

echo "[1] CloudFormation 스택 생성 시작..."
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://mgn_setup.yaml \
    --parameters ParameterKey=KeyName,ParameterValue=mgn-key \
    --capabilities CAPABILITY_NAMED_IAM

echo "[2] 스택 생성 완료를 기다리는 중..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
echo "[DONE] CloudFormation 스택 생성 완료"