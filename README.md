cloudshell 이용 자동화 및 간단한 실습이 목표

# 1. GitHub에서 클론

```bash
git clone https://github.com/rookieboba/AWS-MGN.git
cd AWS-MGN
```

# 2. 키페어 생성
```bash
chmod +x create_stack.sh 
./create_key.sh mgn-key
```

# 3. CloudFormation 스택 생성 (IAM Role, VPC, Subnet, SG 포함)
```bash
chmod =x create_stack.sh
./create_stack.sh mgn-setup-stack
```


# 4. IAM 사용자 생성 + AccessKey 발급 및 설정 내용 출력
```bash
chmod =x create_iam_user_with_keys.sh
./create_iam_user_with_keys.sh
```
