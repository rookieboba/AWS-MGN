#!/bin/bash
KEY_NAME="mgn-key"
echo "[1] 키페어 생성 중..."
aws ec2 create-key-pair --key-name $KEY_NAME --query "KeyMaterial" --output text > ${KEY_NAME}.pem
chmod 400 ${KEY_NAME}.pem
echo "[DONE] 키페어 저장 완료: ${KEY_NAME}.pem"