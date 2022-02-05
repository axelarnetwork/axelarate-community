# Info about the Axelar mainnet
-------

Variable  | Value
------------- | -------------
`axelar-core` version | `v0.13.6`
`tofnd` version | `v0.8.2`
Ethereum Axelar Gateway contract address | `0x4F4495243837681061C4743b74B3eEdf548D56A5`
Ethereum AXL token address | `0x3eacbDC6C382ea22b78aCc158581A55aaF4ef3Cc`
Ethereum UST token address | `0x085416975fe14C2A731a97eC38B9bF8135231F62`
Ethereum LUNA token address | `0x31DAB3430f3081dfF3Ccd80F17AD98583437B213`
Avalanche Axelar Gateway contract address | `0x5029C0EFf6C34351a0CEc334542cDb22c7928f78`
Avalanche AXL token address | `0x1B7C03Bc2c25b8B5989F4Bc2872cF9342CEc80AE`
Avalanche UST token address | `0x260Bbf5698121EB85e7a74f2E45E16Ce762EbE11`
Avalanche LUNA token address | `0x120AD3e5A7c796349e591F1570D9f7980F4eA9cb`
Fantom Axelar Gateway contract address | `0x304acf330bbE08d1e512eefaa92F6a57871fD895`
Fantom AXL token address | `0xE4619601ffF110e649F68FD209080697b8c40DBC`
Fantom UST token address | `0x2B9d3F168905067D88d93F094C938BACEe02b0cB`
Fantom LUNA token address | `0x5e3C572A97D898Fe359a2Cea31c7D46ba5386895`
Polygon Axelar Gateway contract address | `0x6f015F16De9fC8791b234eF68D486d2bF203FBA8`
Polygon AXL token address | `0x161cE0D2a3F625654abF0098B06e9EAF5f308691`
Polygon UST token address | `0xeDDc6eDe8F3AF9B4971e1Fa9639314905458bE87`
Polygon LUNA token address | `0xa17927fB75E9faEA10C08259902d0468b3DEad88`
Moonbeam Axelar Gateway contract address | `0x4F4495243837681061C4743b74B3eEdf548D56A5`
Moonbeam AXL token address | `0x3eacbDC6C382ea22b78aCc158581A55aaF4ef3Cc`
Moonbeam UST token address | `0x085416975fe14C2A731a97eC38B9bF8135231F62`
Moonbeam LUNA token address | `0x31DAB3430f3081dfF3Ccd80F17AD98583437B213`
Terra -> Axelar IBC channel id | `channel-19`
Axelar -> Terra IBC channel id | `channel-0`

# Upgrade Path

Core Version  | Start Height | End Height
------------- | ------------- | -------------
v0.10.7 | 0 | 384000
v0.13.6 | 384001 | N/A

# Minimum transfer amounts

For each asset X in (AXL, UST, LUNA) and each external chain Y in (Ethereum, non-Ethereum EVM, Cosmos/IBC): any transfer of asset X to chain Y must exceed the minimum amount given in the table below.  (If Y is the origin chain for asset X then this transfer is called "redeem"/"burn"; there is no minimum in this case.)

If the total amount of asset X sent to a deposit address A is smaller than the minimum then those deposits will sit in the queue until a future deposit to A brings the total above the minimum.

Asset symbol | Ethereum | non-Ethereum EVM | Cosmos/IBC
---|---|---|---
AXL | 100 AXL | 10 AXL | 0.1 AXL
UST | 100 UST | 10 UST | 0.1 UST
LUNA | 1 LUNA | 0.1 LUNA | 0.001 LUNA
