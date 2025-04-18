
# AWS MGN 완전 자동화 마이그레이션 프로젝트

이 프로젝트는 **Rocky Linux 8.10 서버를 AWS로 마이그레이션**하기 위한 AWS MGN (Application Migration Service) 기반 **완전 자동화 스크립트**를 제공합니다.  
CloudShell에서의 초기 세팅부터 리눅스 서버에서의 agent 설치, 복제 시작, 테스트 인스턴스, 운영 전환, 마이그레이션 확정, 서비스 연결 해제까지 **모든 과정을 CLI 한 줄로 실행**할 수 있습니다.

---

## 📁 디렉토리 구조

```
.
├── mgn_migration_flow.sh         # 💡 완전 자동화 스크립트 (agent 설치 포함)
├── cloudshell/                   # CloudShell 내 초기 구성용
│   ├── create_key.sh             # EC2 키페어 생성
│   ├── create_stack.sh           # CloudFormation 스택 생성
│   ├── create_iam_user_with_keys.sh
│   ├── delete_iam_access_keys.sh
│   ├── delete_iam_user.sh
│   ├── delete_key.sh
│   ├── delete_stack.sh
│   ├── mgn_setup.yaml
│   └── mgn_setup_updated.yaml
└── cleanup/                      # 삭제 자동화 (선택)
    └── delete_all.sh            # IAM, 키페어, 스택 일괄 삭제 스크립트 (옵션)
```

---

## ✅ 요구 사항

- AWS 계정 및 CloudShell 접근 권한
- VMware 또는 기타 환경의 **Rocky Linux 8.10 서버 (인터넷 연결 필수)**
- IAM 사용자 권한: AdministratorAccess 또는 MGN 관련 최소 권한

---

## ☁️ CloudShell 초기 작업 (최초 1회)

```bash
# GitHub에서 레포지토리 클론
git clone https://github.com/rookieboba/rocky-to-aws-mgn-main.git
cd rocky-to-aws-mgn-main/cloudshell

# .env 에 사용자 설정

# IAM 사용자 및 키 발급
aws iam create-user --user-name "$IAM_USER"

# IAM 사용자에 권한 부여 (AdministratorAccess 또는 최소 권한 정책 ARN)
aws iam attach-user-policy \
  --user-name "$IAM_USER" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# CloudFormation 스택 생성
aws cloudformation create-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://mgn_setup_updated.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$AWS_REGION"


# IAM 사용자 액세스 키 발급 및 저장
aws iam create-access-key --user-name "$IAM_USER" \
  | jq -r '.AccessKey | "aws_access_key_id=\\(.AccessKeyId)\\naws_secret_access_key=\\(.SecretAccessKey)"' \
  > mgn-access-keys.txt

cat mgn-access-keys.txt

```


---

## 🔐 Rocky Linux 서버에 AWS 자격 증명 설정

```bash
# 패키지 설치
sudo dnf install -y curl jq unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws --version

# 저장한 Key 조회
cat mgn-access-keys.txt

# Key 등록
mkdir -p ~/.aws

# credentials
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = <AccessKeyId>
aws_secret_access_key = <SecretAccessKey>
EOF

# config
cat <<EOF > ~/.aws/config
[default]
region = ap-northeast-2
output = json
EOF
```

---

## 🚀 전체 마이그레이션 자동화 실행

```bash
chmod +x mgn_migration_flow.sh
./mgn_migration_flow.sh ap-northeast-2
```

이 스크립트는 다음을 자동으로 수행합니다:

1. MGN Agent 다운로드 및 설치
2. 소스 서버 등록 확인 (최대 5분 폴링)
3. 복제 시작 (`start-replication`)
4. 테스트 인스턴스 실행 (`launch-test-instance`)
5. 운영 인스턴스 실행 (`launch-cutover-instance`)
6. 마이그레이션 확정 (`finalize-cutover`)
7. 서비스 연결 해제 (`disconnect-from-service`)

---

## 🔍 MGN 삭제 및 중지 명령어

```bash
# 소스 서버 정보 조회, state 확인하기
aws mgn describe-source-servers --source-server-ids s-7a4d3dc2759164acb

#복제 중지
aws mgn disconnect-from-service --source-server-id s-7a4d3dc2759164acb

# 소스 서버 삭제 시도
aws mgn delete-source-server --source-server-id s-7a4d3dc2759164acb
```

## 🔍 상태 수동 확인 명령어

```bash
aws mgn describe-source-servers --region ap-northeast-2 --output table
```

---

## 🧹 클린업 (선택)

```bash
cd cloudshell

# IAM 사용자 및 키 삭제
./delete_iam_access_keys.sh mgn-rocky-user
./delete_iam_user.sh mgn-rocky-user

# 키페어 및 스택 삭제
./delete_key.sh mgn-key
./delete_stack.sh mgn-setup-stack
```

또는 `cleanup/delete_all.sh`로 일괄 제거

---
