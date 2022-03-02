# axelarate-community

Tools to join the Axelar network

## Disclaimer

The Axelar network is under active development. Use at your own risk with funds you're comfortable using. See [Terms of use](https://docs.axelar.dev/terms-of-use).

## Join as a node

See [Setup instructions](https://docs.axelar.dev/roles/node/join).

## Seed nodes

Lists of seed nodes:

- [mainnet/seeds.json](/resources/mainnet/seeds.json)
- [testnet/seeds.json](/resources/testnet/seeds.json)

### Add your seed node to the list

Submit a pull request!

### Use these seeds to join the Axelar network

Pass seeds into `axelard` as a comma-separated list (csv) of the form `ID@host:port,ID@host:port,...` via:

- the `--p2p.seeds` flag for `axelard start`, or
- in the `seeds` entry in `config.toml`

Use the `seeds.json` files in this repo to produce a csv list via

```bash
cat seeds.json | jq -r '. | map(.seed) | join(",")'
```

## Bug bounty and disclosure of vulnerabilities

See [Bug bounty](https://docs.axelar.dev/bug-bounty).
