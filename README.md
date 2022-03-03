# axelarate-community

Tools to join the Axelar network

## Disclaimer

The Axelar network is under active development. Use at your own risk with funds you're comfortable using. See [Terms of use](https://docs.axelar.dev/terms-of-use).

## Join as a node

See [Setup instructions](https://docs.axelar.dev/roles/node/join).

## Seed nodes

Lists of seed nodes:

- [mainnet/seeds.toml](/resources/mainnet/seeds.toml)
- [testnet/seeds.toml](/resources/testnet/seeds.toml)

### Add your seed node to the list

Submit a pull request!

### Use these seeds to join the Axelar network

By default, the predefined seeds in `resources/{network}/seeds.toml` (mainnet|testnet) are used. You can add additional seeds there.

####Alternative ways to define seeds
Pass seeds into `axelard` as a comma-separated list (csv) of the form `ID@host:port,ID@host:port,...` via:

- the `--p2p.seeds` flag for `axelard start`, or
- in the `seeds` entry in `config.toml`


## Bug bounty and disclosure of vulnerabilities

See [Bug bounty](https://docs.axelar.dev/bug-bounty).
