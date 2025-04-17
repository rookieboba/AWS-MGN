
# AWS MGN 자동화 실습 가이드

이 저장소는 AWS CloudShell 및 Rocky Linux 8.10 환경에서 [AWS Application Migration Service (MGN)] 자동화를 위한 스크립트를 제공합니다.

---

## 📁 디렉토리 설명

- `cloudshell/` - AWS 리소스 생성용 스크립트 (VPC, Subnet, IAM 등)
- `rocky/` - 온프레미스 서버(Rocky Linux)에서 실행할 에이전트 설치용 스크립트
- `cleanup/` - 리소스 삭제를 위한 명령어 및 스크립트

---

## ☁️ CloudShell 작업 흐름

```bash
# 1. 레포지토리 클론
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN/cloudshell

# 2. 키페어 생성
chmod +x create_key.sh
./create_key.sh mgn-key

# 3. CloudFormation 스택 생성
chmod +x create_stack.sh
./create_stack.sh mgn-setup-stack

# 4. IAM 사용자 생성 및 AccessKey 출력
chmod +x create_iam_user.sh
./create_iam_user.sh mgn-rocky-user
```

---

## 🖥️ Rocky Linux에서 수행할 작업

```bash
# 1. 환경 변수 등록 (CloudShell에서 발급받은 값 사용)
export AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxx
export AWS_REGION=ap-northeast-2

# 2. 스크립트 실행
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN/rocky
chmod +x install_mgn_agent.sh
./install_mgn_agent.sh
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
chmod +x ../cleanup/delete_iam_user.sh
../cleanup/delete_iam_user.sh mgn-rocky-user
```

---

## 🛠️ TODO (확장 계획)

- [ ] EC2 Launch Template을 포함한 CloudFormation 확장
- [ ] MGN 이벤트 트리거 모니터링
- [ ] 삭제용 스크립트 일괄 실행 버전 추가
- [ ] `SSM`을 이용한 Agent 자동 설치 연동
