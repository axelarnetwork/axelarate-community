---
id: register-proxy
sidebar_position: 4
sidebar_label: Register broadcaster proxy
slug: /validator-zone/setup/register-proxy
---

# Register broadcaster proxy

Axelar validators exchange messages with one another via the Axelar blockchain.  Each validator sends these messages from a separate `broadcaster` account.

:::tip
If you forgot to copy the `broadcaster` address from the terminal output then you can display it from the `vald` container, not `axelar-core`.
```bash
docker exec -it vald sh
axelard keys show broadcaster -a
```
:::

Go to [Axelar faucet](http://faucet.testnet.axelar.network/) and get some coins on your `broadcaster` address.

Use the proxy address from above to register the broadcaster account as a proxy for your validator.

```bash
axelard tx snapshot register-proxy [proxy address] [flags]
```

For example:

```bash
axelard tx snapshot register-proxy axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs --from validator -y
```
