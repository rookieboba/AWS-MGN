
# AWS MGN 자동화 실습 가이드

이 저장소는 AWS CloudShell 및 Rocky Linux 8.10 환경에서 [AWS Application Migration Service (MGN)] 자동화를 위한 스크립트를 제공합니다.

---

## 📁 디렉토리 설명

- `cloudshell/` - AWS 리소스 생성용 스크립트 (VPC, Subnet, IAM 등)

---

## ☁️ 작업 흐름

[1단계] CloudShell / IAM 사용자 생성 및 액세스 키 발급
```bash
# Alias 설정
mgnuser='mgn-rocky-user'

# 사용자(mgn-rocky-user)의 액세스 키 목록을 확인
aws iam list-access-keys --user-name $mgnuser --output table

# IAM 사용자를 생성
aws iam create-user --user-name $mgnuser

# IAM 사용자에게 AdministratorAccess 정책을 연결
aws iam attach-user-policy \
  --user-name mgn-rocky-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# 사용자에 대한 새로운 액세스 키와 시크릿 키를 생성
aws iam create-access-key --user-name  $mgnuser \
  | jq -r '.AccessKey | "AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nAWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)"' \
  > mgn-access-keys.txt
cat mgn-access-keys.txt 
```

[2단계] Putty / 환경 변수 등록 (Access Key + Secret Key + Region)
```bash
# 가상 서버에서 아래 작업 진행
mkdir -p ~/.aws

# credentials 파일 설정
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = aaaaaaaaa
aws_secret_access_key = aaaa
EOF

# config 파일 설정
cat <<EOF > ~/.aws/config
[default]
region = ap-northeast-2
output = json
EOF
```

[3단계] AWS 스택 생성 
```bash
# 1. 레포지토리 클론
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN/cloudshell

# 2. 키페어 생성
alias key-pair-name="mgn-key"

chmod +x create_key.sh
./create_key.sh "$key-pair-name"
aws ec2 describe-key-pairs --output table

# 3. CloudFormation 스택 생성
alias stack="mgn-setup-stack"

chmod +x create_stack.sh
./create_stack.sh "$stack"
aws cloudformation describe-stack-resources --stack-name $stack --output table
# aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --output table

# 4. IAM 사용자 생성 및 출력
alias username="mgn-rocky-user"

username="mgn-rocky-user"     
./create_iam_user_with_keys.sh "$username"
```


## ☁️ Migration 작업

```bash
chmod +x mgn_migration_flow.sh
./mgn_migration_flow.sh ap-northeast-2 s-0123456789abcdef0
```


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
