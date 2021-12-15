---
id: e5
sidebar_position: 5
sidebar_label: Exercise 5
slug: /exercises/e5
---
# Exercise 5
Transfer assets from Axelar Network to EVM-compatible chains and back via Axelar Network CLI.

## Level
Intermediate

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries)
- Have a Ethereum wallet setup and have an Ethereum address funded with some Ether (You can also choose to use the [Chrome plugin](https://chrome.google.com/webstore/detail/mew-cx/nlbmnnijcnlegkjjpcfjclmcfggfefdm?hl=en))
- You must have some `uaxl` tokens in your Axelar Network address. You can get AXL tokens from the [Axelar faucet](http://faucet.testnet.axelar.dev/).

## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.dev/)
- Latest docker image: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- [Extra commands to query Axelar Network state](/extra-commands)

## What you need
- Metamask
- Ethereum Ropsten address (generate via Metamask)

## Joining the Axelar testnet

Follow the instructions in [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries) to make sure your node is up to date and you received some test coins to your account.

## TODO set up metamask for external EVM chains [move to a new page!]

TODO

Open your Metamask wallet, go to Settings -> Advanced, then enable "Show HEX data". This way you can send a data transaction directly with the Metamask wallet.

You can now open Metamask, select "Assets", then "Import Token", then "Custom Token", and paste the Ethereum token contract address (see [Testnet Release](/testnet-releases) and look for the corresponding token address).

TODO: clarify the names of wrapped tokens on the EVM chains

TODO: You need some of the native token in your Metamask account to pay for gas.  (Example: Ethereum needs ETH, Avalanche needs C-AVAX, etc.)

## Send tokens from Axelar to an EVM chain

In what follows we assume your Axelar account name is `validator`.  This is the default name for the account that is automatically created for you when you first joined the Axelar testnet.

In what follows:
* `[token]` is `uaxl` or an ibc token
* `[chain]` is the external EVM chain to which you will transfer assets.  One of `ethereum`, `avalanche`, `fantom`, `moonbeam`, `polygon`.
* `[evm destination address]` is an address controlled by you on the external EVM chain `[chain]`.  This is where your tokens will be sent.
* `[evm gateway address]` is found at [Testnet Release](/resources/testnet-releases.md).  Find the entry "`[chain]` Axelar Gateway contract address".

1. Check that you have a sufficient `[token]` balance in your account:
```bash
axelard q bank balances $(axelard keys show validator -a)
```
Output should be something like:
```
balances:
- amount: "1000000"
 denom: uaxl
```

2. Create a temporary deposit address on Axelar.

```bash
axelard tx axelarnet link [chain] [evm destination address] [token] --from validator
```
Output should contain
```
successfully linked [axelar deposit address] and [evm destination address]
```

3. Send some `[token]` on Axelar Network to the new `[axelar deposit address]` from the previous step.
    * `[amount]` is your choice
```bash
axelard tx bank send validator [axelar deposit address] [amount]"[token]"
```

4. Confirm the deposit transaction.
    * [txhash] is from the previous step
    * [amount] and [token] are from the previous step
```bash
axelard tx axelarnet confirm-deposit [txhash] [amount]"[token]" [axelar deposit address] --from validator
```
Example:
```bash
axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752 1000000uaxl axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
```

5. Create and sign pending transfers for `[chain]`.
```bash
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2
axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
Output should contain
```
successfully started signing batched commands with ID [batched commands id]
```
TODO: Watch out for microservices!

6. Get the command data that needs to be sent in a `[chain]` transaction in order to transfer tokens
```bash
axelard q evm batched-commands ethereum [batched commands id]
```
Wait for `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`

7. Use Metamask to send a transaction on EVM chain `[chain]` with the command data.

    Reminder: set your Metamask network to the testnet for `[chain]`.  

    Send a transaction to `[evm gateway address]`, paste hex from `execute_data` above into "Hex Data" field.  (Do not send tokens!)

    You should see `[amount]` of asset `[token]` in your `[chain]` Metamask account.
    
Congratulations!  You have transferred assets from Axelar to an external EVM chain!

## Redeem tokens from an EVM chain back to Axelar

1. Create a temporary deposit address on the EVM chain `[chain]`.
```bash
axelard tx evm link [chain] axelarnet $(axelard keys show validator -a) [token] --from validator
```
Output should contain
```
successfully linked [evm deposit address] and [axelar destination address]
```

2. Use Metamask to send your wrapped AXL tokens to the temporary deposit address `[evm deposit address]` on the EVM chain `[chain]`.

Do not proceed to the next step until you have waited for sufficiently many block confirmations on the EVM chain.  (Ethereum: 35 blocks, all other EVM chains: 1 block).

3. Confirm the EVM chain transaction on Axelar.
    * `[txhash]` is from the previous step
    * `[amount]` is just a number with no token denomination.  (Example: `1000000`)
```bash
axelard tx evm confirm-erc20-deposit [chain] [txhash] [amount] [evm deposit address] --from validator
```
Example:
```bash
axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```
Wait for transaction to be confirmed on Axelar.
You can search it using `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`.

4. Execute pending deposit on Axelar and verify you received the tokens.

    First, check your balance on Axelar so you can compare after the deposit:
    ```bash
    axelard q bank balances $(axelard keys show validator -a)
    ```
    Then execute pending deposit:
    ```bash
    axelard tx axelarnet execute-pending-transfers --from validator --gas auto --gas-adjustment 1.2
    ```
    Then check your balance on Axelar again and compare with previous:
    ```bash
    axelard q bank balances $(axelard keys show validator -a)
    ```
You should see the deposited token in your balance, minus transaction fees.

Congratulations!  You have transferred assets from the external EVM chain back to Axelar!