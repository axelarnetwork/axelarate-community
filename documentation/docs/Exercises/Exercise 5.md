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
- Your Axelar Network address has a positive `uaxl` balance. You can get AXL tokens from the [Axelar faucet](http://faucet.testnet.axelar.dev/).

## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.dev/)
- Latest docker image: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- [Extra commands to query Axelar Network state](/extra-commands)

## What you need
- Metamask
- Ethereum Ropsten address (generate via Metamask)

## Joining the Axelar testnet

Follow the instructions in [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries) to make sure your node is up to date and you received some test coins to your account.

### Sending tokens from Axelar Network to Ethereum

In what follows we assume your Axelar account name is `validator`.  This is the default name for the account that is automatically created for you when you first joined the Axelar testnet.

1. Check that you have balances on your account

```bash
axelard q bank balances $(axelard keys show validator -a)
```
You should see your balances shows e.g.,
```bash
balances:
- amount: "1000000"
 denom: uaxl
```
2. Create a deposit address on Axelar Network (to which you'll deposit coins later)

[token] is `uaxl`.

[Ethereum Ropsten receipent address] is the address you want to receive the tokens to
```bash
axelard tx axelarnet link ethereum [Ethereum Ropsten receipent address] [token] --from validator
```
Look for `successfully linked [Axelar Network deposit address] and [Ethereum Ropsten dst addr]`

3. Send the token on Axelar Network to the deposit address specified above
```bash
axelard tx bank send validator [Axelar Network deposit address] [amount]"[token]"
```

4. Confirm the deposit transaction

[txhash] is from the above command

[amount] and [token] are the same as in step 3 above

[Axelar Network deposit address] is the address above you deposited to

```bash
axelard tx axelarnet confirm-deposit [txhash] [amount]"[token]" [Axelar Network deposit address] --from validator
```
e.g.,
```bash
axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752  1000000uaxl axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
```

5. Create transfers on Ethereum and Sign
```bash
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2
```

```bash
axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
Look for `successfully started signing batched commands with ID {batched commands ID}`.

6. Get the command data that needs to be sent in an Ethereum transaction in order to execute the mint
```bash
axelard q evm batched-commands ethereum {batched commands ID from step 5}
```
Wait for `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`

7. Send the Ethereum transaction wrapping the command data to execute the mint

- Open your Metamask wallet, go to Settings -> Advanced, then find Show HEX data and enable that option. This way you can send a data transaction directly with the Metamask wallet.

- Go to metamask, send a transaction to `Gateway smart contract address`, paste hex from `execute_data` above into Hex Data field

  Keep in mind not to transfer any tokens!

  (Note that the "To Address" is the address of Axelar Gateway smart contract, which you can find under [Testnet Release](/testnet-releases))

You can now open Metamask, select "Assets", then "Import Token", then "Custom Token", and paste the Ethereum token contract address (see [Testnet Release](/testnet-releases) and look for the corresponding token address).

You should now see [amount] tokens in your Ethereum Ropsten Metamask account.

### Burn ERC20 wrapped tokens and send back to Axelar Network
1. Create a deposit address on Ethereum

[token] is what you minted before, `uaxl`

```bash
axelard tx evm link ethereum axelarnet $(axelard keys show validator -a) [token] --from validator
```
Look for `successfully linked [Ethereum Ropsten deposit address] and [Axelar Network dst addr]`

2. External: send wrapped tokens to  [Ethereum Ropsten deposit address] (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send the transaction. Wait for 30 Ethereum block confirmations. You can monitor the status of your deposit using the testnet explorer: https://ropsten.etherscan.io/

3. Confirm the Ethereum transaction

```bash
axelard tx evm confirm-erc20-deposit ethereum [txID] [amount] [Ethereum Ropsten deposit address] --from validator
```
Here, amount should be specific in [token] (depends on what token you are sending).
(For instance, 1photon = 1000000uphoton,  1axl = 1000000uaxl)

[txID] is the Ethereum Ropsten transaction hash of your burn transaction from step 2.

Example:
```bash
axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```

Wait for transaction to be confirmed.
You can search it using `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`.

4. Execute pending deposit on Axelar Network
```bash
axelard tx axelarnet execute-pending-transfers --from validator --gas auto --gas-adjustment 1.2
```
5. Verify you received the funds
```bash
axelard q bank balances $(axelard keys show validator -a)
```

You should see the deposited token in your balance (minus gas fees)

