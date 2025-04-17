# AWS MGN 자동화 실습 가이드

이 저장소는 AWS CloudShell 및 Rocky Linux 8.10 서버 환경에서 [AWS Application Migration Service (MGN)] 기반 마이그레이션을 자동화하기 위한 스크립트를 제공합니다.

---

## 📁 디렉토리 구조

```bash
AWS-MGN/
├── cloudshell/          # CloudShell 환경에서 실행할 스크립트
│   ├── create_key.sh
│   ├── create_stack.sh
│   ├── create_iam_user_with_keys.sh
│   └── mgn_setup.yaml
├── rocky/               # MGN Agent 설치
│   └── install_mgn_agent.sh
└── README.md            # 현재 파일
```

---

## ☁️ CloudShell 환경에서 수행할 작업

### 1. 레포지토리 클론
```bash
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN/cloudshell
```

### 2. 키페어 생성
```bash
chmod +x create_key.sh
./create_key.sh mgn-key
aws ec2 describe-key-pairs
```

### 3. CloudFormation 스택 생성 (IAM Role, VPC, Subnet, SG 구성 포함)
```bash
chmod +x create_stack.sh
./create_stack.sh mgn-setup-stack
aws cloudformation list-stacks
aws cloudformation describe-stack-resources --stack-name mgn-setup-stack  --query "StackResources[*].{Type:ResourceType,LogicalId:LogicalResourceId,Status:ResourceStatus}"   --output table

# aws cloudformation describe-stack-resources --stack-name <스택이름> \
#  --query "StackResources[*].{Type:ResourceType,LogicalId:LogicalResourceId,Status:ResourceStatus}" \
#  --output table
# aws cloudformation list-stacks --stack-name mgn-setup-stack
# aws cloudformation describe-stacks --stack-name mgn-setup-stack --query "Stacks[0].StackStatus" --output text
```

### 4. MGN용 IAM 사용자 생성 및 AccessKey 출력
```bash
chmod +x create_iam_user_with_keys.sh
./create_iam_user_with_keys.sh mgn-rocky-user

# aws iam get-user --user-name mgn-rocky-user
# aws iam list-access-keys --user-name mgn-rocky-user
```

---


## 🖥️ Rocky Linux 서버에서 수행할 작업

### 1. AWS 인증 정보 설정
> CloudShell에서 발급받은 값을 기반으로, Rocky 서버에 환경 변수 등록:

```bash
export AWS_ACCESS_KEY_ID=발급받은_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=발급받은_SECRET_ACCESS_KEY
export AWS_REGION=ap-northeast-2
```

---

### 2. 스크립트 다운로드 및 실행
> CloudShell에서 발급받은 값을 기반으로, Rocky 서버에 환경 변수 등록:

```bash
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN/rocky
chmod +x install_mgn_agent.sh
./install_mgn_agent.sh

```

## 🔗 참고

## 리소스 삭제

```bash
# CloudFormation 스택 삭제
aws cloudformation delete-stack --stack-name mgn-setup-stack

# 키페어 삭제
aws ec2 delete-key-pair --key-name mgn-key
```


