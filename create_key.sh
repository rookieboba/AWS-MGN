#!/bin/bash

# 키페어 이름 인자 확인
if [ -z "$1" ]; then
  echo "[ERROR] 키페어 이름을 인자로 입력하세요."
  echo "예: ./create_key.sh mgn-key"
  exit 1
fi

KEY_NAME="$1"

echo "[1] 키페어 [$KEY_NAME] 생성 중..."
aws ec2 create-key-pair \
  --key-name "$KEY_NAME" \
  --query "KeyMaterial" \
  --output text > "${KEY_NAME}.pem"

chmod 400 "${KEY_NAME}.pem"
echo "[DONE] 키페어 저장 완료: ${KEY_NAME}.pem"
