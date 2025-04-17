# 🚀 AWS MGN 자동화 구성 (CloudShell 기반)

AWS CloudShell 환경에서 **Application Migration Service(MGN)** 관련 리소스를 자동으로 구성할 수 있도록, 
`CloudFormation` + `Shell Script` 기반으로 설계되었습니다.

---

## ✅ 사전 조건

- AWS 계정 보유 및 로그인 완료
- **서울 리전(ap-northeast-2)** 기준
- CloudShell 환경에서 아래 명령어들을 실행

---

## 📁 1. GitHub 리포지토리 클론

```bash
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN/cloudshell
```

---

## 🔐 2. 키페어 생성 (EC2 연결용)

```bash
chmod +x create_key.sh
./create_key.sh mgn-key
```

- 생성된 키페어: `mgn-key.pem`
- 퍼미션: `chmod 400` 자동 적용됨

---

## 🏗️ 3. CloudFormation 스택 생성

```bash
chmod +x create_stack.sh
./create_stack.sh mgn-setup-stack
```

**생성 리소스:**

- VPC (CIDR: 10.0.0.0/16)
- Subnet (10.0.1.0/24, ap-northeast-2a)
- Internet Gateway, Route Table
- Security Group (포트 22 허용)
- MGN용 IAM Role: `AWSApplicationMigrationReplicationServerRole`

---

## 👤 4. MGN 전용 IAM 사용자 생성 및 키 발급

```bash
chmod +x create_iam_user_with_keys.sh
./create_iam_user_with_keys.sh mgn-rocky-user
```

- 발급된 키는 다음과 같이 출력됩니다:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

- 출력된 값을 복사해서 **Rocky Linux 서버에서 `export`로 등록**

---

## 🧹 5. 리소스 삭제 (정리 시)

```bash
aws cloudformation delete-stack --stack-name mgn-setup-stack
aws ec2 delete-key-pair --key-name mgn-key
```

---

## 📌 참고사항

- **Rocky Linux** 환경에서 MGN Agent 설치를 위한 스크립트도 별도 제공 가능  
- 원하시는 경우 `install_mgn_agent.sh` 요청 시 전달 드립니다

---

## 📂 주요 구성 파일

| 파일명                        | 설명                                     |
|-----------------------------|----------------------------------------|
| `create_key.sh`             | PEM 키 생성                             |
| `create_stack.sh`           | CloudFormation 스택 생성 자동화         |
| `create_iam_user_with_keys.sh` | IAM 사용자 생성 + AccessKey 출력     |
| `mgn_setup.yaml`            | CloudFormation 템플릿 (VPC, SG 등)      |

---

> 필요한 경우 위 내용을 `.zip` 패키지로 묶어서 제공해드릴 수 있습니다.
