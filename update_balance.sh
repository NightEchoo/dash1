#!/bin/bash
set -e

ADDRESS="A9NBEQeCYzvqidFnh7UVZsBrW2T5df4cqnBjxCBQRJ88"
API="https://solbalance.z9023814.workers.dev/?address=$ADDRESS"
FILE="balance.json"

# 读取本地 balance.json
if [ -f "$FILE" ]; then
  OLD_JSON=$(cat $FILE)
else
  OLD_JSON='{"balance":0,"usd":0,"price":0,"updated":"N/A","timezone":"UTC+8"}'
fi

# 尝试请求 API（加超时和重试）
for i in 1 2 3; do
  NEW_JSON=$(curl -s --max-time 15 "$API" || echo "")
  if [[ -n "$NEW_JSON" ]]; then
    break
  else
    echo "[$i] 请求失败，重试中..."
    sleep 5
  fi
done

# 判断是否成功
if [[ -n "$NEW_JSON" && "$NEW_JSON" == *"balance"* ]]; then
  echo "$NEW_JSON" > $FILE
  echo "✅ 成功更新 balance.json"
else
  echo "⚠️ 获取数据失败，保留旧数据"
  echo "$OLD_JSON" > $FILE
fi
