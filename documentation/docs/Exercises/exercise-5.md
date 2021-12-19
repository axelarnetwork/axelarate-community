# Exercise 5
Transfer AXL tokens from Axelar Network to EVM-compatible chains and back via Axelar CLI.

## Level
Intermediate

## Disclaimer
!> :fire:
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.

## Prerequisites

- Complete all steps from [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries)
- Select an EVM chain `[chain]`.  Currently supported EVM chains are: Ethereum, Avalanche, Fantom, Moonbeam, Polygon.
- Complete steps from [Metamask for EVM chains](/resources/metamask.md) to connect your Metamask to `[chain]` and get some `[chain]` testnet tokens.
- Get some AXL tokens in your Axelar Network address from the [Axelar faucet](http://faucet.testnet.axelar.dev/).

## Send tokens from Axelar to an EVM chain

In what follows we assume your Axelar account name is `validator`.  This is the default name for the account that is automatically created for you when you first joined the Axelar testnet.

In what follows:

* `[chain]` is the external EVM chain to which you will transfer assets.  One of `ethereum`, `avalanche`, `fantom`, `moonbeam`, `polygon`.
* `[evm destination address]` is an address controlled by you on the external EVM chain `[chain]`.  (In your Metamask, for example.)  This is where your tokens will be sent.
* `[evm gateway address]` is found at [Testnet Release](/resources/testnet-releases.md).  Find the entry "`[chain]` Axelar Gateway contract address".

1. Check that you have a sufficient `uaxl` balance in your account:

    ```bash
    axelard q bank balances $(axelard keys show validator -a)
    ```

2. Create a temporary deposit address on Axelar.

    ```bash
    axelard tx axelarnet link [chain] [evm destination address] uaxl --from validator
    ```
    Output should contain
    ```
    successfully linked [axelar deposit address] and [evm destination address]
    ```

3. Send some `uaxl` (minimum 1000uaxl) on Axelar Network to the new `[axelar deposit address]` from the previous step.

    * `[amount]` is your choice

    ```bash
    axelard tx bank send validator [axelar deposit address] [amount]uaxl
    ```

4. Confirm the deposit transaction.

    * `[txhash]` and `[amount]` are from the previous step

    ```bash
    axelard tx axelarnet confirm-deposit [txhash] [amount]uaxl [axelar deposit address] --from validator
    ```
    
    Example:
    
    ```bash
    axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752 1000000uaxl axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
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

> [!NOTE|label:Troubleshoot]
> If after performing the above steps you get the following error
>```bash
>Error: rpc error: code = InvalidArgument desc = failed to execute message; message index: 0: no commands to sign found: bridge error: invalid request
>```
>Check [this page](../faqs/ex5-problem.md) for detailed answer on how to resolve it.

6. Get the command data that needs to be sent in a `[chain]` transaction in order to transfer tokens

    ```bash
    axelard q evm batched-commands [chain] [batched commands id]
    ```

    Wait for `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`.

7. Use Metamask to send a transaction on EVM chain `[chain]` with the command data.

> [!TIP|label:Out of Gas]
> Manually increase the gas limit to 5 million gas (5000000).  If you don't do this then the transaction will fail due to insufficient gas and you will not receive your tokens.
>
> Before you click "confirm": select "EDIT", change "Gas Limit" to 5000000, and "Save"



*Reminder:* set your Metamask network to the testnet for `[chain]`.  

Send a transaction to `[evm gateway address]`, paste hex from `execute_data` above into "Hex Data" field.  (Do not send tokens!)

You should see `[amount]` of asset AXL in your `[chain]` Metamask account.
    
Congratulations!  You have transferred assets from Axelar to an external EVM chain!

## Redeem tokens from an EVM chain back to Axelar

1. Create a temporary deposit address on the EVM chain `[chain]`.

    ```bash
    axelard tx evm link [chain] axelarnet $(axelard keys show validator -a) uaxl --from validator
    ```

    Output should contain

    ```
    successfully linked [evm deposit address] and [axelar destination address]
    ```

2. Use Metamask to send your wrapped AXL tokens to the temporary deposit address `[evm deposit address]` on the EVM chain `[chain]`.

    Do not proceed to the next step until you have waited for sufficiently many block confirmations on the EVM chain.  (Currently 35 blocks for Ethereum, 1 block for all other EVM chains.)

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
