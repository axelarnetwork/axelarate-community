---
id: e3
sidebar_position: 3
sidebar_label: Exercise 3
slug: /exercises/e3
---
# Exercise 3
Transfer BTC to Axelar Network (as a wrapped asset) and back via Axelar Network CLI.

## Level
Intermediate

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup](/setup.md)

## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.network/)
- Latest docker image: https://hub.docker.com/repository/docker/axelarnet/axelar-core,
- [Extra commands to query Axelar Network state](/extra-commands)

## What you need
- Bitcoin testnet faucet to send some test BTC: https://testnet-faucet.mempool.co/


## Joining the Axelar testnet

Follow the instructions in [Setup](/setup.md) to make sure your node is up to date.

## Instructions to mint and burn tokens
These instructions are a step by step guide to run commands to move an asset from a source to a destination chain and back. The assets are minted as wrapped assets on the Axelar Network. The commands are submitted to the Axelar Network that's responsible for (a) generating deposit/withdrawal addresses, (b) routing and finalizing transactions, and (c) minting/burning the corresponding assets.

To perform these tests, you'll need some test Bitcoins on the Bitcoin testnet, and a destination Axelar Network address on the Axelar Network Testnet.

### Mint Wrapped Bitcoin tokens on Axelar Network
1. Generate a new axelar address
   ```
    axelard keys add [key-name]
    ```
    Go to axelar faucet and get some coins on your newly created address. http://faucet.testnet.axelar.network/
    
    Check that you received the funds
    ```
    axelard q bank balances [output address above]
    ```

2. Create a deposit address on Bitcoin (to which you'll deposit coins later)
   
    The [axelar network dst addr] is the address you created in step 1, associated with your [key-name]
    [key name] is the name you used in step1
    ```
    axelard tx bitcoin link axelarnet [Axelar Network dst addr] --from [key-name]
    -> returns deposit address
    ```

    e.g.,
    ```bash
    axelard tx bitcoin link axelarnet axelar1xr04qffe0f0gf4sjzswefx0npadsxfmrs7kry6 --from my-key
    ```

    Look for `successfully linked [bitcoin deposit address] and [Axelar Network dst addr]`

3. External: send a TEST BTC on Bitcoin testnet to the deposit address specific above, and wait for 6 confirmations (i.e. the transaction is 6 blocks deep in the Bitcoin chain).
- ALERT: DO NOT SEND ANY REAL ASSETS
- You can use a bitcoin faucet such as https://bitcoinfaucet.uo1.net/ to send TEST BTC to the deposit address
- You can monitor the status of your deposit using the testnet explorer: https://blockstream.info/testnet/


4. Confirm the Bitcoin outpoint
   
   [key name] is the name you used in step1
    ```bash
    axelard tx bitcoin confirm-tx-out "[txID:vout]" "[amount]btc" "[deposit address]" --from [key-name]
    ```

    e.g.,

    ```bash
    axelard tx bitcoin confirm-tx-out 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0 0.0001btc tb1qlteveekr7u2qf8faa22gkde37epngsx9d7vgk98ujtzw77c27k7qk2qvup --from my-key
    ```

    Wait for transaction to be confirmed (~10 Axelar blocks, ~50 secs).
    Eventually, you'll see something like this in the node terminal:

    ```bash
    bitcoin outpoint confirmation result is
    ```

    You can search it using `docker logs -f axelar-core 2>&1 | grep -a -e outpoint`.
5. Execute pending deposit on Axelar Network
   [key name] is the name you used in step1
   ```
   axelard tx axelarnet execute-pending-transfers --from [key-name] --gas auto --gas-adjustment 1.2
   ```
6. Check tokens are arrived
   
   The [Axelar Network dst addr] is the address you created in step 1, associated with your [key-name]
   ```
   axelard q bank balances [Axelar Network dst addr]
   ```
   You should see the minted Bitcoin in satoshi
   ```
   balances:
   - amount: "10000"
   denom: satoshi
   ```

### Burn wrapped Satoshi tokens and obtain native Bitcoin

To send wrapped Bitcoin back to Bitcoin, run the following commands:

1. Create a deposit address on Axelar Network
   
   [key name] is the name you used in step1
   ```bash
   axelard tx axelarnet link bitcoin [destination bitcoin addr] satoshi --from [key-name]
   -> returns deposit address
   ```

   e.g.,
   ```bash
   axelard tx axelarnet link bitcoin tb1qtc2rjxezqumzxwe0kucj36k7mf83psa253684k satoshi --from my-key
   ```

   Look for the Axelarnet deposit address as the first output in this line (`axelar...`):

   ```bash
   successfully linked {axelar12xywfpt5cq3fgc6jtrumq5n46chuq9xzsajj5v} and {tb1qtc2rjxezqumzxwe0kucj36k7mf83psa253684k}
   ```
   :::note
   Make sure to link a Bitcoin address that is controlled by you, e.g. if you link it to an address controlled by Axelar your withdrawal will be considered a donation and added to the pool of funds
   :::

2. send the satoshi token on Axelar Network to the deposit address specific above
   ```
   axelard tx bank send [key-name] [Axelar Network deposit address] [amount]satoshi
   ```
   e.g.,
   ```
   axelard tx bank send my-key axelar12xywfpt5cq3fgc6jtrumq5n46chuq9xzsajj5v 10000satoshi
   ```
   :::tip
   Please do not send the whole amount, you will need some satoshi in Exercise 5 
   :::


3. Confirm the deposit transaction
   
   [txhash] is from the above command
   
   [amount] is same as was sent

   [key name] is the name you used in step1
   
   ```
   axelard tx axelarnet confirm-deposit [txhash] [amount]satoshi [Axelar Network deposit address] --from [my-key]
   ```

   Here, amount should be specific in Satoshi. (For instance, 0.0001BTC = 10000)
   e.g.,
   
   ```bash
   axelard tx axelarnet confirm-deposit 12B7795C49905194C5433E3413AABBF3C6AA27BFD1F20303C66DA4319B143A91 10000satoshi axelar12xywfpt5cq3fgc6jtrumq5n46chuq9xzsajj5v --from my-key
   ```

You're done! In the next step, a withdrawal must be signed and submitted to the Bitcoin network.

:::tip
In this release, we're triggering these commands about once a day. So come back in 24 hours, and check the balance on the Bitcoin testnet address to which you submitted the withdrawal.
:::

   
