# Exercise 4
Transfer UST tokens from Terra to EVM compatible chains and back via Terra CLI and Axelar CLI

## Level
Intermediate

## Disclaimer
!> :fire:
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.

## Prerequisites
- Complete all steps from [Setup with Docker](/setup/setup-with-docker.md) or [Setup with Binaries](/setup/setup-with-binaries.md)
- Select an EVM chain `[chain]`.  Currently supported EVM chains are: Ethereum, Avalanche, Fantom, Moonbeam, Polygon.
- Complete steps from [Metamask for EVM chains](/resources/metamask.md) to connect your Metamask to `[chain]` and get some `[chain]` testnet tokens.
- Golang (Follow the [official docs](https://golang.org/doc/install) to install)
- For Ubuntu/Debian systems: install build-essential with `apt-get install build-essential`

## Connect to the Terra testnet and get some UST tokens

1. Clone the Terra repo Github:

    ```bash
    git clone https://github.com/terra-money/core/
    cd core
    git checkout v0.5.11
    ```

2. Build from source.

    ```bash
    make install
    ```

3. Verify that Terra is properly installed.

    ```bash
    terrad version --long
    ```

    > :bulb: If you get `-bash: terrad: command not found`, make sure you do the following:
    > 
    >```bash
    >export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
    >source .profile
    >```

4. Initialize the node
    * `[moniker]` is any name you like

    ```bash
    terrad init [moniker]
    ```

5. Use any text editor to open `~/.terra/config/client.toml`, edit `chain-id` and `node` fields

    ```toml
    chain-id = "bombay-12"
    node = "tcp://adc1043f1d76249009c417dcad0bc807-1055950820.us-east-2.elb.amazonaws.com:26657"
    ```

    Verify you have access to the testnet.  You should see the latest block info

    ```bash
    terrad status
    ```

6. Create a key pair
    * `[terra-key-name]` is any name you like

    ```bash
    terrad keys add [terra-key-name]
    ```

    Note for later:
    * `[terra-address]` from the above command.  Example: `terra1syhner2ldmm7vqzkskcflaxl6wy9vn7m873vqu`

7. Get some UST for your newly created addtress from the [Terra Testnet Faucet](https://faucet.terra.money/).

    Verify that tokens have arrived.

    ```bash
    terrad q bank balances [terra-address]
    ```

## Send UST from Terra to an EVM chain

In what follows:

* We assume your Axelar account name is `validator`.  (This is the default name for the account that is automatically created for you when you first joined the Axelar testnet.)
* `[chain]` is the external EVM chain to which you will transfer UST tokens.  One of `ethereum`, `avalanche`, `fantom`, `moonbeam`, `polygon`.
* `[evm destination address]` is an address controlled by you on the external EVM chain `[chain]`.  (In your Metamask, for example.)  This is where your UST tokens will be sent.
* `[evm gateway address]` is found at [Testnet Release](/resources/testnet-releases.md).  Find the entry "`[chain]` Axelar Gateway contract address".
* `[terra channel id]` is found at [Testnet Release](/resources/testnet-releases.md).

> ### :bulb: *Reminder:* Docker vs. binaries
>For the following `axelard` terminal commands:
>* **Docker:** Commands should be entered into a shell attached to the `axelar-core` container via
>```
>  docker exec -it axelar-core sh
>```
>* **Binaries:** Commands must specify the path to the `axelard` binary and the `--home` flag.
>
>  Example: Instead of `axelard keys show validator -a` use
>  ```
>   ~/.axelar_testnet/bin/axelard keys show validator -a --home ~/.axelar_testnet/.core
>  ```

1. Create a temporary deposit address on Axelar.

    ```bash
    axelard tx axelarnet link [evm chain] [evm destination address] uusd --from validator
    ```

    Output should contain

    ```
    successfully linked [axelar deposit address] and [evm destination address]
    ```

    > :bulb: If you get `Error: rpc error: ... not found: key not found`, verify that
    > `validator` address is correct and sufficiently funded:
    > ```bash
    > axelard q bank balances validator
    > ```

2. Send an IBC transfer from Terra testnet to Axelar Network

    * `[amount]` is your choice

    In the `terrad` terminal:

    ```bash
    terrad tx ibc-transfer transfer transfer [terra channel id] [axelar deposit address] --packet-timeout-timestamp 0 --packet-timeout-height "0-20000" [amount]uusd --gas-prices 0.15uusd --from [terra-key-name] -y -b block
    ```

    Wait ~30-60 secs for the relayer to relay your transaction.

    Note for later:
    * `[txhash]` output from the previous command.

    ?> If your transfer is taking a long time then you can check if it timed out and was refunded on the [Terra explorer](https://finder.terra.money/).  Enter your Terra address and retry the transfer.

3. Check that you received the funds in Axelar.

    In the `axelard` terminal:

    ```bash
    axelard q bank balances [axelar deposit address]
    ```

    You should see balance with denomination of the form `ibc/XXX`.

    Example:

    ```bash
    amount: "1000000"
    denom: ibc/6F4968A73F90CF7DE6394BF937D6DF7C7D162D74D839C13F53B41157D315E05F
    ```

    Note for later:
    * `[ibc-token]` is the IBC denomination of the form `ibc/XXX`.  In the above example `[ibc-token]` is `ibc/6F4968A73F90CF7DE6394BF937D6DF7C7D162D74D839C13F53B41157D315E05F`

4. Confirm the deposit transaction.

    ```bash
    axelard tx axelarnet confirm-deposit [txhash] [amount]"[ibc-token]" [axelar deposit address] --from validator
    ```

    Example:

    ```bash
    axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752  1000000"ibc/6F4968A73F90CF7DE6394BF937D6DF7C7D162D74D839C13F53B41157D315E05F" axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
    ```

5. Create and sign pending transfers for `[chain]`.

    ```bash
    axelard tx evm create-pending-transfers [chain] --from validator --gas auto --gas-adjustment 1.2
    axelard tx evm sign-commands [chain] --from validator --gas auto --gas-adjustment 1.2
    ```

    Output should contain

    ```
    successfully started signing batched commands with ID [batched commands id]
    ```

6. Get the command data that needs to be sent in a `[chain]` transaction in order to transfer tokens

    ```bash
    axelard q evm batched-commands [chain] [batched commands id]
    ```

    Wait for `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`.

7. Use Metamask to send a transaction on EVM chain `[chain]` with the command data.

> [!ATTENTION]
> Manually increase the gas limit to 5 million gas (5000000).  If you don't do this then the transaction will fail due to insufficient gas and you will not receive your tokens. 
> Before you click "confirm": select "EDIT", change "Gas Limit" to 5000000, and "Save"

*Reminder:* set your Metamask network to the testnet for `[chain]`.  

Send a transaction to `[evm gateway address]`, paste hex from `execute_data` above into "Hex Data" field.  (Do not send tokens!)

You should see `[amount]` of asset UST in your `[chain]` Metamask account.
    
Congratulations!  You have transferred assets from Axelar to an external EVM chain!

## Redeem UST tokens from an EVM chain back to Terra

1. Create a temporary deposit address on the EVM chain `[chain]`.

    ```bash
    axelard tx evm link [chain] terra [terra-address] uusd --from validator
    ```

    Output should contain

    ```
    successfully linked [evm deposit address] and [terra-address]
    ```

2. Use Metamask to send `[amount]` of your wrapped UST tokens to the temporary deposit address `[evm deposit address]` on the EVM chain `[chain]`.

    Do not proceed to the next step until you have waited for sufficiently many block confirmations on the EVM chain.  (Currently 35 blocks for Ethereum, 1 block for all other EVM chains.)

    Note for later:
    * `[evm-txhash]` from Metamask.
    * `[amount]` is the amount of wrapped UST you sent denominated in `uusd`.  (Remember: `1UST = 1000000uusd`.)  It's just a number with no token denomination  (Example: `1000000`)

3. Confirm the EVM chain transaction on Axelar.

    ```bash
    axelard tx evm confirm-erc20-deposit [chain] [txhash] [amount] [evm deposit address] --from validator
    ```

    Example:

    ```bash
    axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
    ```

    Wait for transaction to be confirmed on Axelar.
    You can search for it in the logs:
    * **Docker:** `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`
    * **Binary:** `tail -f $HOME/.axelar_testnet/logs/axelard.log | grep -a -e "deposit confirmation"`

4. Route pending IBC transfer on Axelar and verify you received the UST tokens on Terra.
```bash
axelard tx axelarnet route-ibc-transfers --from [key-name] --gas auto --gas-adjustment 1.2
```
Wait ~30-60 secs for the relayer to relay your transaction.





    First, check your balance on Terra so you can compare after the deposit.  In the Terra shell:

    ```bash
    terrad q bank balances [terra-address]
    ```

    Then route the pending IBC transfer:

    ```bash
    axelard tx axelarnet route-ibc-transfers --from validator --gas auto --gas-adjustment 1.2
    ```

    Then check your UST balance on Terra again and compare with previous:

    ```bash
    terrad q bank balances [terra-address]
    ```

    You should see the deposited token in your balance, minus transaction fees.

Congratulations!  You have transferred UST from the external EVM chain back to Axelar!
