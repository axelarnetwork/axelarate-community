---
id: register-proxy
sidebar_position: 3
sidebar_label: Register broadcaster proxy
slug: /validator-zone/register-proxy
---

# Register broadcaster proxy

Axelar validators exchange messages with one another via the Axelar blockchain.  Each validator sends these messages from a separate `broadcaster` account.

:::warning
Your validator will be slashed if you do not register a proxy.  A proxy is required in order to fulfill your obligations as a validator.
:::

Open a new terminal and run the `./join/launch-validator.sh` script with the same arguments you used when you ran `./join/join-testnet.sh`.

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

_[TODO backup your broadcaster mnemonic [link to backup page].]_

Go to [Axelar faucet](http://faucet.testnet.axelar.network/) and get some coins on your `broadcaster` address. [link to faucet instructions]

Use the proxy address from above to register the broadcaster account as a proxy for your validator.

```bash
axelard tx snapshot register-proxy [proxy address] [flags]
```

For example:

```bash
axelard tx snapshot register-proxy axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs --from validator -y
```

## [move elsewhere] Health checks

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

## [move elsewhere] Post-Setup Checklist

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