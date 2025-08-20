#!/bin/bash

# ----------------------
# 配置项
# ----------------------
WALLET_ADDRESS="A9NBEQeCYzvqidFnh7UVZsBrW2T5df4cqnBjxCBQRJ88"
RPC_URL="https://mainnet.helius-rpc.com/?api-key=225e1777-98e1-499f-9b14-945da0b99067"
# ----------------------

# 获取余额 (lamports)
LAMPORTS=$(curl -s -X POST $RPC_URL \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"getBalance\",\"params\":[\"$WALLET_ADDRESS\",{\"commitment\":\"finalized\"}]} " \
  | jq '.result.value')

SOL=$(echo "scale=4; $LAMPORTS/1000000000" | bc)

# 获取 SOL 当前 USD 价格
PRICE=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd" | jq '.solana.usd')

# 计算 USD 金额
USD=$(echo "scale=2; $SOL*$PRICE" | bc)

# 当前时间 (UTC+8)
UPDATED=$(TZ="Asia/Shanghai" date '+%Y-%m-%d %H:%M:%S')

# 写入 balance.json
cat > balance.json <<EOF
{
  "balance": $SOL,
  "usd": $USD,
  "price": $PRICE,
  "updated": "$UPDATED",
  "timezone": "UTC+8"
}
EOF

echo "balance.json 已更新: $SOL SOL, $USD USD, $PRICE USD/SOL"
