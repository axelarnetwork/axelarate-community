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

In the `axelar-core` container: make your `validator` account into an Axelar validator by staking AXL tokens on Axelar network:

```bash
axelard tx staking create-validator --yes --amount [amount]uaxl --moniker "my_awesome_moniker" --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1" --pubkey="$(axelard tendermint show-validator)" --from validator -b block
```

Stake amount is denominated in `uaxl`. Note the tip above about how much to stake.
For example, to stake 33 AXL tokens set `--amount` as follows:
```bash
--amount 33000000uaxl
```

The output should be something like:
```
{"height":"1508","txhash":"FABB8745616EE19ADB8E33F2F7B936D1580A84C5493A06A36DF9CC28C2A57A17","codespace":"","code":0,"data":"0A2C0A2A2F636F736D6F732E7374616B696E672E763162657461312E4D736743726561746556616C696461746F72","raw_log":"[{\"events\":[{\"type\":\"coin_received\",\"attributes\":[{\"key\":\"receiver\",\"value\":\"axelar1tygms3xhhs3yv487phx3dw4a95jn7t7l94rkyz\"},{\"key\":\"amount\",\"value\":\"70000000uaxl\"}]},{\"type\":\"coin_spent\",\"attributes\":[{\"key\":\"spender\",\"value\":\"axelar1ylmsql3xc7t3qvgqjq44ntragzqn07p70nelqm\"},{\"key\":\"amount\",\"value\":\"70000000uaxl\"}]},{\"type\":\"create_validator\",\"attributes\":[{\"key\":\"validator\",\"value\":\"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5\"},{\"key\":\"amount\",\"value\":\"70000000uaxl\"}]},{\"type\":\"message\",\"attributes\":[{\"key\":\"action\",\"value\":\"/cosmos.staking.v1beta1.MsgCreateValidator\"},{\"key\":\"module\",\"value\":\"staking\"},{\"key\":\"sender\",\"value\":\"axelar1ylmsql3xc7t3qvgqjq44ntragzqn07p70nelqm\"}]}]}]","logs":[{"msg_index":0,"log":"","events":[{"type":"coin_received","attributes":[{"key":"receiver","value":"axelar1tygms3xhhs3yv487phx3dw4a95jn7t7l94rkyz"},{"key":"amount","value":"70000000uaxl"}]},{"type":"coin_spent","attributes":[{"key":"spender","value":"axelar1ylmsql3xc7t3qvgqjq44ntragzqn07p70nelqm"},{"key":"amount","value":"70000000uaxl"}]},{"type":"create_validator","attributes":[{"key":"validator","value":"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5"},{"key":"amount","value":"70000000uaxl"}]},{"type":"message","attributes":[{"key":"action","value":"/cosmos.staking.v1beta1.MsgCreateValidator"},{"key":"module","value":"staking"},{"key":"sender","value":"axelar1ylmsql3xc7t3qvgqjq44ntragzqn07p70nelqm"}]}]}],"info":"","gas_wanted":"200000","gas_used":"144641","tx":null,"timestamp":""}
```

### Optional: check how many tokens your validator has staked

```bash
axelard q staking validator "$(axelard keys show validator --bech val -a)" | grep tokens
```

### Optional: stake more coins after initial validator creation

```bash
axelard tx staking delegate [axelarvaloper address] [amount]uaxl --from validator -y
```

For example:

```bash
axelard tx staking delegate "$(axelard keys show validator --bech val -a)" 100000000uaxl --from validator -y
```
