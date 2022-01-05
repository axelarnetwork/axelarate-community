# Network Upgrade

1. Wait for the proposed upgrade block. Your node will panic and stop once the block is reached. If you are running a validator, you will need to vote for the upgrade proposal beforehand. You can do so by running
```
axelard tx gov vote 1 yes --from validator --gas auto --gas-adjustment 1.5
```

2. Backup the state and keys.  If you used the default path then do this in the host (outside the container):
```
mv ~/.axelar_testnet ~/.axelar_testnet_upgrade-v0.12_backup
```
**Note that your state folder may exist at a different path if you are running your node with the binaries or if you used a non-default path.**

3. Reset blockchain state
```
axelard unsafe-reset-all
```

4. Wait for the Axelar team to publish the new genesis file for the new chain. The genesis files can be found at https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json

Once the new genesis file is published, place it in `/home/axelard/.axelar/config/`.

**Note that the path may be different if you are running your node with the binaries.**

5. Restart your node.

