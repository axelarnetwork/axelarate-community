# Exercise 2
Transfer BTC to Ethereum (as a wrapped asset) and back using `c2d2cli`.

C2D2 is the axelar cross-chain dapp deamon which coordinates the necessary transactions for cross-chain asset transfers.
The C2D2 CLI automates the steps we performed manually in exercise 1.

## Disclaimer 
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template. 

## Prerequisites
- Complete all steps from `README.md`

## What you need
- Bitcoin testnet faucet to send some test BTC: https://testnet-faucet.mempool.co/
- Metamask
- Ethereum Ropsten address (generate via Metamask) 

## Joining the Axelar testnet

Follow the instructions in `README.md` to make sure your node is up to date and you received some test coins to your validator account. 

### Pull c2d2 docker image
Check [TESTNET RELEASE.md](../TESTNET%20RELEASE.md) for the latest available c2d2 version of the docker images.

```
docker pull axelarnet/c2d2:VERSION
```

### Enter the c2d2cli container
On a new terminal window, enter the c2d2 container by running:
```
./c2d2/c2d2cli.sh
```

### Generate a key on Axelar and get some test tokens

Create c2d2's Axelar blockchain account
```
c2d2cli keys add c2d2
```

Go to axelar faucet and fund your c2d2 account by providing the address to the
facuet (http://faucet.testnet.axelar.network/).\ You can get c2d2's account
address by running 

```
c2d2cli keys show c2d2 -a
```

### Mint ERC20 Bitcoin tokens on Ethereum
1. Generate a Bitcoin deposit address. The Ethereum address you provide will be linked to the deposit address and receive the pegged bitcoin (Satoshi tokens) on the Ethereum testnet. 

    ```
    c2d2cli deposit-btc ethereum [ethereum recipient address]
    ```

    You will see the deposit Bitcoin address printed in the terminal

    ```
    > Please deposit Bitcoin to bcrt1qk4s6ya3gqakzmpv95tvgp00rhpkal9jyx243y8dr2dzmttkcdurq4dqj4t
    > Waiting for deposit transaction
    ```

2. *External*: send some TEST BTC on Bitcoin testnet to the deposit address specific above, and wait for 6 confirmations (i.e. the transaction is 6 blocks deep in the Bitcoin chain). 

  - ALERT: **DO NOT SEND ANY REAL ASSETS***
  - Bitcoin testnet faucet [https://testnet-faucet.mempool.co/](https://testnet-faucet.mempool.co/)
  - You can monitor the status of your deposit using the testnet explorer: [https://blockstream.info/testnet/](https://blockstream.info/testnet/)

Do not exit c2d2cli while you are waiting for your deposit to be confirmed. It will be watching for an event from the bitcoin bridge node which it needs to detect your transaction.

If your bitcoin deposit transaction has at least one confirmation but is not
detected, you can restart c2d2cli and append the `--bitcoin-tx-prompt` flag.
The CLI will prompt you to enter the deposit tx info manually. The rest of the
deposit procedure will still be automated.

    ```
    c2d2cli deposit-btc ethereum [ethereum recipient address] --bitcoin-tx-prompt
    ```

Once your transaction is detected, c2d2cli will wait until it has 6 confirmations before proceeding.

 3. c2d2 will automate the bitcoin deposit confirmation, and mint command signing and sending. Once the minting process completes you will see the following message:

    ```
    Mint command <commandId> completed at ethereum txID <transactionId>
    ```

You can now open Metamask and add the wrapped BTC contract address. c2d2cli will print the contract address like this:

```
Using satoshi token <address>
```

The contract will show in metamask as symbol 'Satoshi'. If your recipient address is in metamask, you will have an amount of satoshi tokens in metamask equal to your bitcoin deposit. 

### Burn ERC20 wrapped Bitcoin tokens and obtain native Satoshi
1. Generate an ethereum withdrawal address. The Bitcoin address you provide will be uniquely linked to the deposit address and receive the withdrawn BTC on the Bitcoin testnet. 

   ```
   c2d2cli withdraw-btc ethereum [bitcoin recipient address] [fee]
   ```

For example:
   ```
   c2d2cli withdraw-btc ethereum tb1qg2z5jatp22zg7wyhpthhgwvn0un05mdwmqgjln 10000satoshi
   ```

You will see the deposit Ethereum address printed in the terminal.

   ```
   > Please transfer satoshi tokens to 0xC21f7876a23E2E7EB7e4A92E1AF03cacf14B59d5
   > Waiting for withdrawal transaction...
   ```

2. External: send wrapped Satoshi tokens to withdrawal address (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send transactions. 

3. Once your withdrawal transaction is detected, c2d2cli will wait for 30 Ethereum block confirmations before proceeding.

4. c2d2 will automate the withdrawal confirmation, and bitcoin transaction signing and sending. It will then complete the bitcoin change outpoint confirmation and satoshi token burning.

5. Once your bitcoin is withdrawn and your Satoshi tokens have been burned, you will see this message:

```
Burn command <command id> completed at ethereum txID <tx hash>
```
