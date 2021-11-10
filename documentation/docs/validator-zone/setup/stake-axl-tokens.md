---
id: stake-axl-tokens
sidebar_position: 5
sidebar_label: Stake AXL tokens
slug: /validator-zone/setup/stake
---

# Stake AXL tokens on the Axelar network

Decide how many AXL tokens you wish to stake.

:::tip
* You need at least 1 AXL to participate in consensus on the Axelar network
* You need at least 2% of total bonded stake to participate in multi-party cryptography protocols with other validators.
:::

:::tip
Need more AXL tokens than the faucet can give you?  Ping the Axelar team in the Discord #testnet channel to ask for more AXL tokens. The team will verify that your validator is set up correctly and will send additional AXL tokens to your Axelar address.
:::

Make your `validator` account into an Axelar validator by staking AXL tokens on Axelar network:

```bash
axelard tx staking create-validator --yes \
--amount "$STAKE_AMOUNT" \       # see below
--moniker "my_awesome_moniker" \ # choose a cool moniker
--commission-rate="0.10" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1" \
--pubkey "$(axelard tendermint show-validator)" \
--from validator \
-b block
```

Stake amount is denominated in `uaxl`.
_[TODO Really? User can choose denomination, right? No need to enforce only `uaxl`.]_
For example, to stake 33 AXL tokens substitute the following:
```bash
--amount 33000000uaxl \
```

### Optional: check how many tokens your validator has staked

```bash
axelard q staking validator "$(axelard keys show validator --bech val -a)" | grep tokens
```

### Optional: stake more coins after initial validator creation

```bash
axelard tx staking delegate {axelarvaloper address} {amount} --from validator -y
```

For example:

```bash
axelard tx staking delegate "$(axelard keys show validator --bech val -a)" "100000000uaxl" --from validator -y
```
