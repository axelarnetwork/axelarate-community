# Exercise 2
Transfer BTC to Ethereum (as a wrapped asset) and back using `c2d2cli`.

C2D2 is the axelar cross-chain dapp deamon which coordinates the necessary transactions for cross-chain asset transfers.
The C2D2 CLI automates the steps we performed manually in exercise 1.

## Status
Work in progress. 

## Level 
Intermediate

## Disclaimer 
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template. 

## Prerequisites
- Complete all steps from `README.md`

## Useful links
- Extra commands to query Axelar Network state: https://github.com/axelarnetwork/axelarate-community/blob/main/EXTRA%20COMMANDS.md

## What you need
- Bitcoin testnet wallet with some tBTC (faucet [https://testnet-faucet.mempool.co/](https://testnet-faucet.mempool.co/))
- Ethereum wallet on the Ropsten network (we reccomend Metamask)
- Some Ropsten ETH (faucet [https://faucet.ropsten.be/](https://faucet.ropsten.be/) or [https://faucet.dimensions.network/](https://faucet.dimensions.network/))

## Joining the Axelar testnet

Follow the instructions in `README.md` to make sure your node is synchronized to the latest block, and you have received some test coins to your validator account. 

### Pull and enter the `c2d2cli` container
Check [TESTNET RELEASE.md](../TESTNET%20RELEASE.md) for the latest available C2D2 version of the docker images.

On a new terminal window, enter the `c2d2cli` container by running:
```
./c2d2/c2d2cli.sh --version VERSION
```

### Generate a key on Axelar and get some test tokens

Create c2d2's Axelar blockchain account
```
c2d2cli keys add c2d2
```

Go to axelar faucet and fund your C2D2 account by providing the address to the
facuet (http://faucet.testnet.axelar.network/). You can get c2d2's account
address by running 

```shell
c2d2cli keys show c2d2 -a
```

### Fund your ethereum sender account
Add an ethereum account to c2d2cli. When prompted enter the password `passwordpassword`.
```shell
c2d2cli bridge evm accounts add ethereum 
```

You will be asked to enter a password for the account. Make a note of your password.



If you used a different password than `passwordpassword` you will need to either:
1. enter your password manually during the transfer procedure
2. **Or** provide your password to each `c2d2cli` command by adding the flag `--evm-passphrase YOUR_PASSWORD`
3. **Or** configure your password by editing the `/root/.c2d2cli/config.toml` file.
   - Change the value in the `sender-passphrase=` key to your password.

List C2D2's accounts:

```
c2d2cli bridge evm accounts list ethereum
```

Account index `0` (the first address in the list) will be used to send transactions. Go to [https://faucet.ropsten.be/](https://faucet.ropsten.be/) to get some Ropsten ETH for the sender account.

### Mint ERC20 Bitcoin tokens on Ethereum
1. Generate a Bitcoin deposit address. For this step you will need to supply an Ethereum address that you have the private key for. This will be the `[ethereum recipient address]` in the example command below. This address will then be linked to the Bitcoin deposit address generated and will receive the pegged bitcoin (Satoshi tokens) on the Ethereum testnet. 

   ```
   c2d2cli transfer satoshi [ethereum recipient address] --source-chain bitcoin --dest-chain ethereum --gas=auto --gas-adjustment=1.4
   ```

    You will see the deposit Bitcoin address printed in the terminal

    ```
      action:  (2/7) Please deposit Bitcoin to tb1qgfk6v2ut9flwwkraj6t3syvpq22g0xhh2m73atfe79jv3msjwvzqtpuvfc
    ```

2. **External**: send some TEST BTC on Bitcoin testnet to the deposit address specific above, and wait for 6 confirmations (i.e. the transaction is 6 blocks deep in the Bitcoin chain). 

  - ALERT: **DO NOT SEND ANY REAL ASSETS**
  - Bitcoin testnet faucet [https://testnet-faucet.mempool.co/](https://testnet-faucet.mempool.co/)
  - You can monitor the status of your deposit using the testnet explorer: [https://blockstream.info/testnet/](https://blockstream.info/testnet/)

Do not exit `c2d2cli` while you are waiting for your deposit to be confirmed. It will be watching the bitcoin blockchain to detect your transaction. 
- If `c2d2cli` crashes or is closed during this step you can re-run the `deposit-btc` command with the same recipient address to resume.
- If your transaction has 6 confirmations but `c2d2cli` has not detected it, you can restart `c2d2cli` and append the `--bitcoin-tx-prompt` flag.
    - The CLI will prompt you to enter the deposit tx info manually. The rest of the deposit procedure will still be automated.
    - `c2d2cli transfer satoshi [ethereum recipient address] --source-chain bitcoin --dest-chain ethereum  --bitcoin-tx-prompt --gas=auto --gas-adjustment=1.4`

Once your transaction is detected, `c2d2cli` will wait until it has 6 confirmations before proceeding.

 3. C2D2 will automate the bitcoin deposit confirmation, and mint command signing and sending. Once the minting process completes you will see the following message:

    ```
    Transferred satoshi to Ethereum address [ethereum recipient address]
    ```

You can now open Metamask and add the wrapped BTC contract address. `c2d2cli` will print the contract address like this:

```
Using AxelarGateway <address>
Using satoshi token <address>
```

The contract will show in metamask as symbol 'Satoshi'. If your recipient address is in metamask, you will have an amount of satoshi tokens in metamask equal to your bitcoin deposit. 

### Burn ERC20 wrapped Bitcoin tokens and obtain native Satoshi
1. Generate an ethereum withdrawal address. The Bitcoin address you provide will be uniquely linked to the deposit address and receive the withdrawn BTC on the Bitcoin testnet. 

   ```
   c2d2cli transfer satoshi [bitcoin recipient address] --source-chain ethereum --dest-chain bitcoin --gas=auto --gas-adjustment=1.4
   ```

   For example:
   ```
   c2d2cli transfer satoshi tb1qwtrclv55yy26awl2n40u57uck5xgty4w4h9eww --source-chain ethereum --dest-chain bitcoin --gas=auto --gas-adjustment=1.4
   ```

   You will see the deposit Ethereum address printed in the terminal.

   ```
   action:  (2/5) Please transfer satoshi tokens to Ethereum address 0xf5fccEeF24358fE24C53c1963d5d497BCD3ddF48
     | ✓ Waiting for a withdrawal transaction
   ```

2. **External**: send wrapped Satoshi tokens to withdrawal address (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send transactions.


3. Once your withdrawal transaction is detected, `c2d2cli` will wait for 30 Ropsten block confirmations before proceeding.


4. `c2d2cli` will automate the withdrawal confirmation, and satoshi token (wrapped BTC) burning. 

5. Once your Satoshi tokens have been burned, you will see this message:

    ```
    Transferred 5000 satoshi tokens to Bitcoin address [bitcoin recipient address]
    ```

6. Your withdrawn BTC will be spendable by your recipient address once Bitcoin withdrawal consolidation occurs. Consolidation will be completed by a separate process.

An automated service processes all pending transfers from the Axelar network to Bitcoin a few times a day. Come back 24 hours to check your coins at the destination Bitcoin address on the testnet.  

## Additional Notes
If your local axelar node fails, meaning `c2d2cli` cannot connect to it to broadcast transactions, you may use an Axelar public node to broadcast transactions by adding the config file flag `--conf /config.testnet.toml` like so:

```shell
   c2d2cli transfer satoshi [bitcoin recipient address] --source-chain ethereum --dest-chain bitcoin --conf /config.testnet.toml --gas=auto --gas-adjustment=1.4
```
