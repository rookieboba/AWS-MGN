#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "[ERROR] IAM 사용자 이름을 입력하세요."
  echo "예: ./delete_iam_access_keys.sh mgn-rocky-user"
  exit 1
fi

IAM_USER_NAME="$1"

echo "[1] Access Key 삭제 중..."
ACCESS_KEYS=$(aws iam list-access-keys --user-name "$IAM_USER_NAME" --query 'AccessKeyMetadata[*].AccessKeyId' --output text)

if [ -z "$ACCESS_KEYS" ]; then
  echo "[INFO] Access Key가 존재하지 않습니다."
else
  for KEY_ID in $ACCESS_KEYS; do
    aws iam delete-access-key --user-name "$IAM_USER_NAME" --access-key-id "$KEY_ID"
  done
  echo "[DONE] 모든 Access Key 삭제 완료"
fi
