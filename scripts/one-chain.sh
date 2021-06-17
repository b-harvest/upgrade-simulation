#!/bin/sh

#
# Stop if it is already running
#

if pgrep -x "$BINARY" >/dev/null; then
    echo "Terminating $BINARY..."
    killall $BINARY
fi

#
# Set variables 
#

BINARY=gaiad
CHAIN_ID=cosmoshub-4
CHAIN_DIR=./data

VAL_1_CHAIN_DIR=$CHAIN_DIR/$CHAIN_ID/val1
VAL_1_MNEMONIC="guard cream sadness conduct invite crumble clock pudding hole grit liar hotel maid produce squeeze return argue turtle know drive eight casino maze host"
VAL_1_KEY_NAME="val1"
VAL_1_MONIKER="Binance"
VAL_1_GENESIS_COINS=10000000000000000stake
VAL_1_STAKE_COIN=5000000000000000stake
VAL_1_P2P_PORT=26656
VAL_1_RPC_PORT=26657
VAL_1_GRPC_PORT=9090
VAL_1_API_PORT=1317

#
# Remove previous data
#

# Remove previous data
rm -rf $VAL_1_CHAIN_DIR

# Add directory for chain, exit if error
if ! mkdir -p $CHAIN_DIR/$CHAIN_ID 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

#
# Validator 1
#

echo "Initializing $CHAIN_ID..."
$BINARY --home $VAL_1_CHAIN_DIR init test --chain-id=$CHAIN_ID

echo "Adding genesis accounts..."
echo $VAL_1_MNEMONIC | $BINARY --home $VAL_1_CHAIN_DIR keys add $VAL_1_KEY_NAME --recover --keyring-backend=test 
$BINARY --home $VAL_1_CHAIN_DIR add-genesis-account $($BINARY --home $VAL_1_CHAIN_DIR keys show $VAL_1_KEY_NAME --keyring-backend test -a) $VAL_1_GENESIS_COINS

echo "Creating and collecting gentx..."
$BINARY --home $VAL_1_CHAIN_DIR gentx $VAL_1_KEY_NAME $VAL_1_STAKE_COIN --moniker $VAL_1_MONIKER  --chain-id $CHAIN_ID --keyring-backend test
$BINARY --home $VAL_1_CHAIN_DIR collect-gentxs

echo "Change settings in config.toml file..."
sed -i '' 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:'"$VAL_1_RPC_PORT"'"#g' $VAL_1_CHAIN_DIR/config/config.toml
sed -i '' 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$VAL_1_P2P_PORT"'"#g' $VAL_1_CHAIN_DIR/config/config.toml
sed -i '' 's/index_all_keys = false/index_all_keys = true/g' $VAL_1_CHAIN_DIR/config/config.toml
sed -i '' 's#"tcp://0.0.0.0:1317"#"tcp://0.0.0.0:'"$VAL_1_API_PORT"'"#g' $VAL_1_CHAIN_DIR/config/app.toml
sed -i '' 's#"tcp://0.0.0.0:9090"#"tcp://0.0.0.0:'"$VAL_1_GRPC_PORT"'"#g' $VAL_1_CHAIN_DIR/config/app.toml
sed -i '' 's/enable = false/enable = true/g' $VAL_1_CHAIN_DIR/config/app.toml
sed -i '' 's/swagger = false/swagger = true/g' $VAL_1_CHAIN_DIR/config/app.toml

#
# [References]
#
# export BINARY=gaiad
# export HOME1=./data/cosmoshub-4/val1
# export HOME2=./data/cosmoshub-4/val2
#
# [Useful CLI Commands]
# 
# $BINARY start --home $HOME1 --log_level debug --x-crisis-skip-assert-invariants
# $BINARY start --home $HOME2 --log_level info --x-crisis-skip-assert-invariants
# 
# $BINARY unsafe-reset-all --home $HOME1
# $BINARY unsafe-reset-all --home $HOME2
#
# $BINARY tendermint show-node-id --home $HOME1
# $BINARY tendermint show-node-id --home $HOME2
# $BINARY tendermint show-address --home $HOME1
# $BINARY tendermint show-address --home $HOME2
#
# [APIs]
# http://localhost:26657
# http://localhost:1317/staking/validators