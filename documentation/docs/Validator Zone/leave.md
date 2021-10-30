---
id: leave-validator
sidebar_position: 8
sidebar_label: Leave as a validator
slug: /validator-zone/leave
---

# Leaving the Network as a Validator

1. Deactivate your broadcaster account.
```bash
axelard tx snapshot deactivate-proxy --from validator -y -b block
```

2. Wait until the next key rotation for the changes to take place. In this release, we're triggering key rotation about once a day. So come back in 24 hours, and continue to the next step. If you still get an error after 24 hours, reach out to a team member.

3. Release your staked coins.
```bash
axelard tx staking unbond {axelarvaloper address} {amount} --from validator -y -b block
```

eg)

```bash
axelard tx staking unbond "$(axelard keys show validator --bech val -a)" "100000000uaxl" --from validator -y -b block
```

`amount` refers to how many coins you wish to remove from the stake. You can change the amount.

To preserve network stability, the staked coins are held for roughly 1 day starting from the unbond request before being unlocked and returned to the `validator` account.
