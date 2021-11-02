---
id: register-proxy
sidebar_position: 3
sidebar_label: Register broadcaster proxy
slug: /validator-zone/setup/register-proxy
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

Save a copy of your `broadcaster` mnemonic in a safe place.

:::tip
If you forgot to copy the `broadcaster` address from the terminal output then you can display it from the `vald` container, not `axelar-core`.
```bash
docker exec -it vald sh
axelard keys show broadcaster -a
```
:::

Go to [Axelar faucet](http://faucet.testnet.axelar.network/) and get some coins on your `broadcaster` address. [link to faucet instructions]

Use the proxy address from above to register the broadcaster account as a proxy for your validator.

```bash
axelard tx snapshot register-proxy [proxy address] [flags]
```

For example:

```bash
axelard tx snapshot register-proxy axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs --from validator -y
```
