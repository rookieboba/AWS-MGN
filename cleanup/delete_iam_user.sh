#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "[ERROR] 삭제할 IAM 사용자 이름을 입력하세요."
  echo "예: ./delete_iam_user.sh mgn-rocky-user"
  exit 1
fi

IAM_USER_NAME="$1"

echo "[1] AccessKey 삭제 중..."
ACCESS_KEYS=$(aws iam list-access-keys --user-name "$IAM_USER_NAME" --query 'AccessKeyMetadata[*].AccessKeyId' --output text)
for KEY_ID in $ACCESS_KEYS; do
  aws iam delete-access-key --user-name "$IAM_USER_NAME" --access-key-id "$KEY_ID"
done

echo "[2] 연결된 정책 분리 중..."
POLICIES=$(aws iam list-attached-user-policies --user-name "$IAM_USER_NAME" --query 'AttachedPolicies[*].PolicyArn' --output text)
for POLICY_ARN in $POLICIES; do
  aws iam detach-user-policy --user-name "$IAM_USER_NAME" --policy-arn "$POLICY_ARN"
done

echo "[3] 사용자 삭제 중: $IAM_USER_NAME"
aws iam delete-user --user-name "$IAM_USER_NAME" || echo "[INFO] 사용자 삭제 실패 또는 이미 없음"

echo "[DONE] IAM 사용자 삭제 완료"
