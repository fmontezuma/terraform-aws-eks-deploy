version: 0.2
phases:
  install:
    runtime-versions:
      docker: 18
    commands:
      #- DATE=`date +%Y-%m-%d-%H%M`
      - CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::${account_id}:role/kubectl --role-session-name codebuild-kubectl --duration-seconds 900)
      - export AWS_ACCESS_KEY_ID="$(echo $${CREDENTIALS} | jq -r '.Credentials.AccessKeyId')"
      - export AWS_SECRET_ACCESS_KEY="$(echo $${CREDENTIALS} | jq -r '.Credentials.SecretAccessKey')"
      - export AWS_SESSION_TOKEN="$(echo $${CREDENTIALS} | jq -r '.Credentials.SessionToken')"
      - export AWS_EXPIRATION=$(echo $${CREDENTIALS} | jq -r '.Credentials.Expiration')
      - aws eks update-kubeconfig --name ${eks_cluster_name}
  build:
    commands:
      - kubectl apply -f . -R
