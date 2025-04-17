#!/bin/bash
set -e

# 사용자 이름 인자를 받지 않았을 경우 예외 처리
if [ -z "$1" ]; then
  echo "[ERROR] IAM 사용자 이름을 인자로 입력하세요."
  echo "예: ./create_iam_user_with_keys.sh mgn-rocky-user"
  exit 1
fi

IAM_USER_NAME="$1"
OUTPUT_FILE="${IAM_USER_NAME}-credentials.txt"

echo "[1] MGN 전용 IAM 사용자 [$IAM_USER_NAME] 생성 중..."
aws iam create-user --user-name "$IAM_USER_NAME" || echo "[INFO] 사용자 이미 존재"

echo "[2] 권한 정책 연결 중..."
aws iam attach-user-policy \
  --user-name "$IAM_USER_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AWSApplicationMigrationFullAccess

echo "[3] Access Key 생성 중..."
aws iam create-access-key --user-name "$IAM_USER_NAME" > "$OUTPUT_FILE"

echo "[4] 생성된 IAM 사용자 인증 정보:"
cat "$OUTPUT_FILE" | jq -r '
"export AWS_ACCESS_KEY_ID=\(.AccessKey.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=\(.AccessKey.SecretAccessKey)"'

echo "[DONE] 인증 정보가 ${OUTPUT_FILE} 파일에 저장되었습니다."
