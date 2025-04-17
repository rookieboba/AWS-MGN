#!/bin/bash
set -e

IAM_USER_NAME="mgn-rocky-user"
OUTPUT_FILE="mgn-iam-user-credentials.txt"

echo "[1] MGN 전용 IAM 사용자 생성 중..."
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
