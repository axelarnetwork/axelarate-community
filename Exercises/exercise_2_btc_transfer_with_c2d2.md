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

### Generate a key on Axelar and get test tokens

Create c2d2's Axelar blockchain account
```
c2d2cli keys add c2d2
```

Go to axelar faucet and get some coins on your c2d2 address (http://faucet.testnet.axelar.network/)\
You can get c2d2's account address by running
```
c2d2cli keys show c2d2 -a
```

### Mint ERC20 Bitcoin tokens on Ethereum
1. Create a deposit address on Bitcoin
    ```
    c2d2cli deposit-btc ethereum [ethereum recipient address]
    ```
    You will see the deposit Bitcoin address printed in the terminal
    ```
    > Please deposit Bitcoin to bcrt1qk4s6ya3gqakzmpv95tvgp00rhpkal9jyx243y8dr2dzmttkcdurq4dqj4t
    > Waiting for deposit transaction
    ```
2. External: send a TEST BTC on Bitcoin testnet to the deposit address specific above, and wait for 6 confirmations (i.e. the transaction is 6 blocks deep in the Bitcoin chain). 
  - ALERT: DO NOT SEND ANY REAL ASSETS
  - (https://testnet-faucet.mempool.co/)
  - You can monitor the status of your deposit using the testnet explorer: https://blockstream.info/testnet/
- Do not exit c2d2cli while you are waiting for your deposit to be confirmed. c2d2 will be watching for an event from the bitcoin bridge node that it needs to detect your transaction.

    ```
    c2d2cli deposit-btc ethereum [ethereum recipient address]
    ```
 3. c2d2 will automate all the signing and verification process. After completion, you can see a message says
    ```
    Mint command <commandId> completed at ethereum txID <transactionId>
    ```
You can now open Metamask, add the custom asset (Bitcoin) with contract address (ask Axelar on discord if you can't find it) and see the minted Bitcoin tokens appear in it. 

### Burn ERC20 wrapped Bitcoin tokens and obtain native Satoshi
1. Create a deposit address on Ethereum
   ```
   c2d2cli withdraw-btc ethereum [bitcoin recipient address] [fee]
   ```
   e.g. 
   ```
   c2d2cli withdraw-btc ethereum tb1qg2z5jatp22zg7wyhpthhgwvn0un05mdwmqgjln 10000satoshi
   ```
   You will see the deposit Ethereum address printed in the terminal
   ```
   > Please transfer satoshi tokens to 0xC21f7876a23E2E7EB7e4A92E1AF03cacf14B59d5
   > Waiting for withdrawal transaction...
   ```
2. External: send wrapped tokens to deposit address (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send transactions. Wait for 30 Ethereum block confirmations. 

3. c2d2 will automate all the signing and verification process.

(To be continued here)