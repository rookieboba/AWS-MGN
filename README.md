
# AWS MGN 자동화 실습 가이드

이 저장소는 AWS CloudShell 및 Rocky Linux 8.10 환경에서 [AWS Application Migration Service (MGN)] 자동화를 위한 스크립트를 제공합니다.

---

## 📁 디렉토리 설명

- `cloudshell/` - AWS 리소스 생성용 스크립트 (VPC, Subnet, IAM 등)

---

## ☁️ CloudShell 작업 흐름

```bash
# 1. 레포지토리 클론
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN/cloudshell

# 2. 키페어 생성
chmod +x create_key.sh
./create_key.sh {key-pair-name}
# ./create_key.sh mgn-key
aws ec2 describe-key-pairs --output table

# 3. CloudFormation 스택 생성
chmod +x create_stack.sh
./create_stack.sh {stack-name}
# ./create_stack.sh mgn-setup-stack
aws cloudformation describe-stack-resources --stack-name mgn-setup-stack --output table
# aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --output table

# 4. IAM 사용자 출력
chmod +x create_iam_user_with_keys.sh
./create_iam_user_with_keys.sh {user-name}
#./create_iam_user_with_keys.sh mgn-rocky-user

# 5. Key 조회
cat *-credentials.txt
#export AWS_ACCESS_KEY_ID=\(.AccessKey.AccessKeyId)
#export AWS_SECRET_ACCESS_KEY=\(.AccessKey.SecretAccessKey)
```

---

## 🖥️ Rocky Linux에서 수행할 작업

```bash
# 1. 환경 변수 등록 (*-credentials.txt 확인. CloudShell에서 발급받은 값 사용)
export AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxx
export AWS_REGION=ap-northeast-2

sudo wget -O ./aws-replication-installer-init https://aws-application-migration-service-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/linux/aws-replication-installer-init
chmod +x aws-replication-installer-init
./aws-replication-installer-init --region "$AWS_REGION" --no-prompt
```

---

## 🧹 리소스 삭제 명령어

CloudShell 기준:

```bash
# CloudFormation 스택 삭제
aws cloudformation delete-stack --stack-name mgn-setup-stack

# 키페어 삭제
aws ec2 delete-key-pair --key-name mgn-key

# IAM Access Key 및 사용자 삭제
chmod +x ./cloudshell/delete_iam_user.sh
sh -x ./cloudshell/delete_iam_user.sh {user-name}
# sh -x ./cloudshell/delete_iam_user.sh mgn-rocky-user
```

---

## 🛠️ TODO (확장 계획)

- [ ] EC2 Launch Template을 포함한 CloudFormation 확장
- [ ] MGN 이벤트 트리거 모니터링
- [ ] 삭제용 스크립트 일괄 실행 버전 추가
- [ ] `SSM`을 이용한 Agent 자동 설치 연동
