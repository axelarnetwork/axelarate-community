---
id: register-proxy
sidebar_position: 4
sidebar_label: Register broadcaster proxy
slug: /validator-zone/setup/register-proxy
---

# Register broadcaster proxy

Axelar validators exchange messages with one another via the Axelar blockchain.  Each validator sends these messages from a separate `broadcaster` account.

:::warning
A validator can only register one broadcaster throughout its lifetime.  This broadcaster address cannot be changed after it has been registered.  If you need to register a different proxy address then you must also create an entirely new validator.
:::

:::tip
If you forgot to copy the `broadcaster` address from the terminal output then you can display it from the `vald` container, not `axelar-core`.
```bash
docker exec -it vald sh
axelard keys show broadcaster -a
```
If using the binary, then pass in the appropriate `vald` folder.
```bash
$HOME/.axelar_testnet/bin/axelard keys show broadcaster -a --home $HOME/.axelar_testnet/.vald
```
:::

Go to [Axelar faucet](http://faucet.testnet.axelar.dev/) and get some coins on your `broadcaster` address.

In the `axelar-core` container: use the proxy address from above to register the broadcaster account as a proxy for your validator.

```bash
axelard tx snapshot register-proxy [proxy address] [flags]
```

For example:

```bash
axelard tx snapshot register-proxy axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs --from validator
```

Output should be something like:
```
{"height":"1461","txhash":"3C38BD2F7020E42AE1F5A26DEC8FD2656B1B246AB9813CDC64CC09919C17FD8E","codespace":"","code":0,"data":"0A280A262F736E617073686F742E763162657461312E526567697374657250726F787952657175657374","raw_log":"[{\"events\":[{\"type\":\"message\",\"attributes\":[{\"key\":\"action\",\"value\":\"RegisterProxy\"},{\"key\":\"module\",\"value\":\"snapshot\"},{\"key\":\"action\",\"value\":\"registerProxy\"},{\"key\":\"sender\",\"value\":\"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5\"},{\"key\":\"address\",\"value\":\"axelar1jkh7c338v0ktnuucc26r8kxt70dz20p7q0rh94\"}]}]}]","logs":[{"msg_index":0,"log":"","events":[{"type":"message","attributes":[{"key":"action","value":"RegisterProxy"},{"key":"module","value":"snapshot"},{"key":"action","value":"registerProxy"},{"key":"sender","value":"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5"},{"key":"address","value":"axelar1jkh7c338v0ktnuucc26r8kxt70dz20p7q0rh94"}]}]}],"info":"","gas_wanted":"200000","gas_used":"65425","tx":null,"timestamp":""}
```

### Optional: check your registration

Check your address for proxy registered:
```
/ # axelard q snapshot proxy $(axelard keys show validator -a --bech val)
{"address":"axelar1jkh7c338v0ktnuucc26r8kxt70dz20p7q0rh94","status":"active"}
```