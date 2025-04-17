
# AWS MGN 마이그레이션 자동화 스크립트

이 프로젝트는 **Rocky Linux 8.10 서버를 AWS로 마이그레이션**하기 위한 AWS MGN(Application Migration Service) 기반 자동화 스크립트를 제공합니다.  
CloudShell에서의 리소스 구성부터, 실제 서버에서 복제 → 테스트 → 운영 전환까지의 전체 흐름을 CLI 기반으로 제어할 수 있습니다.

---

## 📦 디렉토리 구조

```
.
├── mgn_migration_flow.sh         # 전체 마이그레이션 자동화 스크립트
└── cloudshell/
    ├── create_key.sh             # EC2 키페어 생성
    ├── create_stack.sh           # CloudFormation 스택 생성
    ├── create_iam_user_with_keys.sh
    ├── delete_iam_access_keys.sh
    ├── delete_iam_user.sh
    ├── delete_key.sh
    ├── delete_stack.sh
    ├── mgn_setup.yaml            # 초기 CloudFormation 템플릿
    └── mgn_setup_updated.yaml    # 업데이트된 템플릿
```

---

## ✅ 사용 전 사전 조건

- AWS 계정 보유 및 CloudShell 사용 가능
- `jq` 및 `awscli`가 설치된 리눅스 서버 (예: VMware 기반 Rocky Linux)
- IAM 사용자 권한 (AdministratorAccess 또는 MGN 관련 최소 권한)

---

## ☁️ CloudShell에서 초기 세팅

```bash
# IAM 사용자 생성 및 권한 부여
aws iam create-user --user-name mgn-rocky-user
aws iam attach-user-policy --user-name mgn-rocky-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# 액세스 키 생성 및 저장
aws iam create-access-key --user-name mgn-rocky-user \
  | jq -r '.AccessKey | "AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nAWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)"' > mgn-access-keys.txt
```

---

## 🔐 Putty or 리눅스 서버에서 환경 변수 등록

```bash
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

## 🧰 CloudFormation 스택 + 키페어 생성

```bash
cd cloudshell

# 키페어 생성
chmod +x create_key.sh
./create_key.sh mgn-key

# CloudFormation 스택 생성
chmod +x create_stack.sh
./create_stack.sh mgn-setup-stack
```

---

## 🚀 마이그레이션 전체 자동화 실행

`mgn_migration_flow.sh`는 소스 서버 등록 후 복제 → 테스트 인스턴스 → 커버 인스턴스 → 커버 확정 → 서비스 연결 해제까지 전체 과정을 자동화합니다.

### 사용법

```bash
chmod +x mgn_migration_flow.sh
./mgn_migration_flow.sh <region> <source_server_id>
```

예시:

```bash
./mgn_migration_flow.sh ap-northeast-2 s-0123456789abcdef0
```

---

## 📌 주요 단계 요약

| 단계 | 설명 |
|------|------|
| `start-replication` | 소스 서버 복제 시작 |
| `launch-test-instance` | 테스트 인스턴스 실행 |
| `launch-cutover-instance` | 운영 전환 인스턴스 실행 |
| `finalize-cutover` | 마이그레이션 확정 |
| `disconnect-from-service` | MGN 연결 해제 및 종료 |

---

## 🧪 테스트 및 검증

```bash
aws mgn describe-source-servers --region ap-northeast-2 --output table
```


---

## 👨‍💻 Author

- Sungbin Park (https://github.com/rookieboba)
