#!/bin/bash

# 변수 설정 - 사용자 정의 가능
IAM_USER="mgn-rocky-user"
KEY_NAME="mgn-key"
STACK_NAME="mgn-setup-stack"
REGION="ap-northeast-2"

# 1. IAM Access Key 삭제
ACCESS_KEY_IDS=$(aws iam list-access-keys --user-name "$IAM_USER" --query 'AccessKeyMetadata[].AccessKeyId' --output text)
for KEY_ID in $ACCESS_KEY_IDS; do
  echo "Deleting IAM Access Key: $KEY_ID"
  aws iam delete-access-key --user-name "$IAM_USER" --access-key-id "$KEY_ID"
done

# 2. IAM 사용자 삭제
echo "Deleting IAM User: $IAM_USER"
aws iam delete-user --user-name "$IAM_USER"

# 3. EC2 키페어 삭제
echo "Deleting EC2 Key Pair: $KEY_NAME"
aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION"

# 4. CloudFormation 스택 삭제
echo "Deleting CloudFormation Stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"
