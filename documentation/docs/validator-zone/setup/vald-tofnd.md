---
id: vald-tofnd
sidebar_position: 2
sidebar_label: Launch companion processes for the first time
slug: /validator-zone/setup/companion-processes
---

# Launch companion processes for the first time

Axelar validators need two companion processes called `vald` and `tofnd`.  Launch these processes for the first time by running `./join/launch-validator.sh`.  The output should be something like:

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