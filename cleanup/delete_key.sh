#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "[ERROR] 삭제할 키페어 이름을 입력하세요."
  echo "예: ./delete_key.sh mgn-key"
  exit 1
fi

KEY_NAME="$1"
echo "[1] 키페어 삭제 중: $KEY_NAME"
aws ec2 delete-key-pair --key-name "$KEY_NAME" || echo "[INFO] 키페어가 존재하지 않거나 이미 삭제됨"
echo "[DONE] 키페어 삭제 완료"
