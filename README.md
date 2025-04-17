cloudshell 이용 자동화 및 간단한 실습이 목표

# 1. GitHub에서 클론

```bash
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN
```

# 2. 실행 권한 부여
```bash
chmod +x create_stack.sh create_key.sh create_iam_user_with_keys.sh
```

# 3. 키페어 생성
```bash
./create_key.sh
```

# 4. CloudFormation 스택 생성 (IAM Role, VPC, Subnet, SG 포함)
```bash
./create_stack.sh
```


# 5. IAM 사용자 생성 + AccessKey 발급 및 설정 내용 출력
```bash
./create_iam_user_with_keys.sh
```
