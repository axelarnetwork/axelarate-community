# Info about the Axelar testnet
-------

Variable  | Value
------------- | -------------
`axelar-core` version | `v0.13.6`
`tofnd` version | `v0.8.2`
Ethereum Axelar Gateway contract address | `0x81b450CA8F0e842EcC361FD64270aeb5A374A0d8`
Ethereum AXL token address | `0xBf96Dfc6AE44e880681b7221deE21E900BC0F21c`
Ethereum UST token address | `0x5f1E1bdc2c73EFA2eEEe6b30128d968791D1c55C`
Ethereum LUNA token address | `0xB7454D02D4190dAe72be2051482aCF044435C5D8`
Avalanche Axelar Gateway contract address | `0x8F19fF12a38aDa314e6fC2611E75473BBb11FebE`
Avalanche AXL token address | `0x5a3cF244040Ab7C8e6B192E8eb8eF6C78C9D612b`
Avalanche UST token address | `0x0749e7902520ab6b3DBD28a1203A2d358700655e`
Avalanche LUNA token address | `0x28EE721a8128ee8ff57f14b131535E05b88fd636`
Fantom Axelar Gateway contract address | `0xdCE436d858Cfc7d46946d8f95B466e37FA897A4a`
Fantom AXL token address | `0x0efE77aEf986684650c84C149e0e37196D9b7abc`
Fantom UST token address | `0x243615425b166719A13875A5Dc044094DDF3dA4d`
Fantom LUNA token address | `0x79e1b09d919AE79D039BB81BEB7c53C70f95719B`
Polygon Axelar Gateway contract address | `0xa4dbF01D58C4C89B96194682e48b05c0dEC62201`
Polygon AXL token address | `0x578aBd5AD95D0e85CB9b508295D4bC1B35496f8a`
Polygon UST token address | `0x1912e95A44960c785e96d43651660aF55cA84ab8`
Polygon LUNA token address | `0xaf11e7D46A146256D9178251CBe8A1e5E6218f90`
Moonbeam Axelar Gateway contract address | `0xd01C68e0cf45F99A6016f80a9C1783f497902bAC`
Moonbeam AXL token address | `0xa9d0D7b596AC9F1704E886892870daB084ECd220`
Moonbeam UST token address | `0x1c84ea8C5Fd26f8e49aF418De742982980d88593`
Moonbeam LUNA token address | `0x3a89372397265fAFd704fb8DA373926901CEFA19`
Terra -> Axelar IBC channel id | `channel-55`
Axelar -> Terra IBC channel id | `channel-0`

# Upgrade Path

Core Version  | Start Height | End Height
------------- | ------------- | -------------
v0.10.7 | 0 | 14700
v0.13.6 | 14701 | N/A

# Minimum transfer amounts

For each asset X in (AXL, UST, LUNA) and each external chain Y in (Ethereum, non-Ethereum EVM, Cosmos/IBC): any transfer of asset X to chain Y must exceed the minimum amount given in the table below.  (If Y is the origin chain for asset X then this transfer is called "redeem"/"burn"; there is no minimum in this case.)

If the total amount of asset X sent to a deposit address A is smaller than the minimum then those deposits will sit in the queue until a future deposit to A brings the total above the minimum.

Asset symbol | Ethereum | non-Ethereum EVM | Cosmos/IBC
---|---|---|---
AXL | 100 AXL | 10 AXL | 0.1 AXL
UST | 100 UST | 10 UST | 0.1 UST
LUNA | 1 LUNA | 0.1 LUNA | 0.001 LUNA
