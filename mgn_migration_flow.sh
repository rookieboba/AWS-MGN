#!/bin/bash

# MGN migration automation script
# Usage: ./mgn_migration_flow.sh <region> <source_server_id>

set -e

REGION="$1"
SOURCE_ID="$2"

if [[ -z "$REGION" || -z "$SOURCE_ID" ]]; then
  echo "Usage: $0 <region> <source_server_id>" >&2
  exit 1
fi

start_replication() {
  aws mgn start-replication \
    --region "$REGION" \
    --source-server-id "$SOURCE_ID"
}

launch_test_instance() {
  aws mgn launch-test-instance \
    --region "$REGION" \
    --source-server-id "$SOURCE_ID"
}

launch_cutover_instance() {
  aws mgn launch-cutover-instance \
    --region "$REGION" \
    --source-server-id "$SOURCE_ID"
}

finalize_cutover() {
  aws mgn finalize-cutover \
    --region "$REGION" \
    --source-server-id "$SOURCE_ID"
}

disconnect() {
  aws mgn disconnect-from-service \
    --region "$REGION" \
    --source-server-id "$SOURCE_ID"
}

start_replication
launch_test_instance
launch_cutover_instance
finalize_cutover
disconnect
