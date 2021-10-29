---
id: join-as-validator
sidebar_position: 3
sidebar_label: Become an Axelar validator
slug: /validator-zone/join
---

# Join the Axelar network as a validator

## Prerequisites

* Have an ordinary (non-validator) Axelar node running using the `join/join-testnet.sh` script.
* Have some AXL tokens in your local `validator` account.  If you don't yet have AXL tokens then get some from the faucet [TODO link].

## Become a validator by staking AXL tokens

You currently have an account named `validator` but that's just a name.  Make your `validator` account into an Axelar validator by staking AXL tokens on Axelar network:

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

Decide how many AXL tokens you wish to stake.

:::tip
* You need at least `1 axl` to participate in consensus on the Axelar network
* You need at least `2\%` of total bonded stake to participate in multi-party cryptography protocols with other validators.
:::

:::tip
Need more AXL tokens than the faucet can give you?  Ping the Axelar team in the Discord #testnet channel to ask for more AXL tokens. The team will verify that your validator is set up correctly and will send additional AXL tokens to your Axelar address.
:::

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

## Register broadcaster proxy

Axelar validators exchange messages with one another via the Axelar blockchain.  Each validator sends these messages from a separate `broadcaster` account.

:::warning
Your validator will be slashed if you do not register a proxy.  A proxy is required in order to fulfill your obligations as a validator.
:::

Open a new terminal and run the `./join/launch-validator.sh` script using the same parameters as before.

:::warning
Do NOT use the `--reset-chain` flag or your node will have to sync again from the beginning.
:::

The output should be something like:

```
Tofnd & Vald running.

Proxy address: axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs

To become a validator get some uaxl tokens from the faucet and stake them


- name: broadcaster
  type: local
  address: axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs
  pubkey: axelarpub1addwnpepqg648uzk668g0e93y9sekaufgdp96fksjugk6e6c3eddypzc8qm525yhx2m
  mnemonic: ""
  threshold: 0
  pubkeys: []


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

admit come proud swear view stomach industry elephant extend bracket reveal dinner july absorb beef stick say pact sick
Do not forget to also backup the tofnd mnemonic (/Users/talalashraf/.tofnd/export)

To follow tofnd execution, run 'docker logs -f tofnd'
To follow vald execution, run 'docker logs -f vald'
To stop tofnd, run 'docker stop tofnd'
To stop vald, run 'docker stop vald'
```

_[TODO if you forgot to copy the broadcaster address from the terminal output then you can display your broadcaster address from vald container, not axelar-core.]_

Go to [Axelar faucet](http://faucet.testnet.axelar.network/) and get some coins on your `broadcaster` address. [link to faucet instructions]

Use the proxy address from above to register the broadcaster account as a proxy for your validator.

```bash
axelard tx snapshot register-proxy [proxy address] [flags]
```

For example:

```bash
axelard tx snapshot register-proxy axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs --from validator -y
```

## Health checks

Check that your node's `vald` and `tofnd` are connected properly. As a validator, your `axelar-core` will talk with your `tofnd` through `vald`. This is important when events such as key rotation happens on the network.

### Check: vald, tofnd containers running

In a new terminal:

```bash
docker ps --format '{{.Names}}'
```

Should see output like:
```
vald
tofnd
validator
```

### Check: vald can communicate with tofnd

Etner the `vald` CLI:

```bash
docker exec -ti vald sh
```

From inside the `vald` container run
```bash
axelard tofnd-ping --tofnd-host tofnd
```

You should see
```
PONG!
```

### [move elsewhere] Post-Setup Checklist

Check that:

1. All three containers are running (`axelar-core`, `vald`, and `tofnd`).
2. You can ping (see `tofnd-ping` above) `tofnd` from `vald` container.
3. Your external nodes (Bitcoin, Ethereum, etc) are running and correctly expose the endpoints.
4. You backed-up your mnemonics following [this manual](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/validator-backup.md)
5. After the team gives you enough stake and confirms that rotations are complete, you can explore various shares you hold following [this](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/validator-extra-commands.md).
6. A reminder that you need at least `1 axl` to participate in consensus, and at least `2\%` of total bonded stake to participate in threshold MPC.
7. Check that you have some `uaxl` on your `broadcaster` address. Use [Axelar faucet](http://faucet.testnet.axelar.network/) to get some coins if it is not funded.
8. After that, you're an active validator and should guard your node and all keys with care.

## [move elsewhere] Get AXL tokens from a faucet

Enter Axelar node CLI
```bash
docker exec -it axelar-core sh
```
Find the address of your `validator` account with
```bash
axelard keys show validator -a
```
Go to [Axelar faucet](http://faucet.testnet.axelar.network/) and send some coins on your validator address.

Check that you received the funds:
```bash
axelard q bank balances $(axelard keys show validator -a)
# or paste your address:
axelard q bank balances axelar1p5nl00z6h5fuzyzfylhf8w7g3qj6lmlyryqmhg
```