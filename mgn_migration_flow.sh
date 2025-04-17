#!/bin/bash

# MGN full automation script: from agent registration to cutover
# Usage: ./mgn_migration_flow.sh <region>

set -e

REGION="$1"
if [[ -z "$REGION" ]]; then
  echo "Usage: $0 <region>" >&2
  exit 1
fi

# Install replication agent (must run on source server)
if [[ ! -f ./aws-replication-installer-init ]]; then
  curl -O https://aws-application-migration-service-$REGION.s3.$REGION.amazonaws.com/latest/linux/aws-replication-installer-init
  chmod +x aws-replication-installer-init
fi

./aws-replication-installer-init --region "$REGION" --no-prompt

# Wait for source server registration (polling)
echo "Waiting for source server registration..."
for i in {1..30}; do
  SOURCE_ID=$(aws mgn describe-source-servers --region "$REGION" --query "items[0].sourceServerID" --output text 2>/dev/null || true)
  if [[ "$SOURCE_ID" != "None" && -n "$SOURCE_ID" ]]; then
    echo "Source server registered: $SOURCE_ID"
    break
  fi
  sleep 10
done

if [[ -z "$SOURCE_ID" || "$SOURCE_ID" == "None" ]]; then
  echo "Source server registration failed or timed out."
  exit 1
fi

# MGN steps
start_replication() {
  aws mgn start-replication --region "$REGION" --source-server-id "$SOURCE_ID"
}

launch_test_instance() {
  aws mgn launch-test-instance --region "$REGION" --source-server-id "$SOURCE_ID"
}

launch_cutover_instance() {
  aws mgn launch-cutover-instance --region "$REGION" --source-server-id "$SOURCE_ID"
}

finalize_cutover() {
  aws mgn finalize-cutover --region "$REGION" --source-server-id "$SOURCE_ID"
}

disconnect() {
  aws mgn disconnect-from-service --region "$REGION" --source-server-id "$SOURCE_ID"
}

start_replication
launch_test_instance
launch_cutover_instance
finalize_cutover
disconnect
