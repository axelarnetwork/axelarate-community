---
id: instructions
sidebar_position: 2
sidebar_label: Checklist to ask for help
slug: /faq/instructions
---

# Checklist to ask for help
When asking for help, communicate your setup and the problem succinctly but thoroughly. Use the following template: 

- Github commit you're running (run git status from the axelarate-community directory and add the output to your request - should be on main branch). Make sure you’re always on the latest.  
- Check your node blockheight & compare with the output in the dashboards to make sure you’re synced up
```bash
curl localhost:26657/status | jq '.result.sync_info'
```
- Make sure you're running the correct versions of software, check [here](https://axelardocs.vercel.app/testnet-releases) for the latest software releases and addresses

## Other interesting info that will help troubleshooting: 

- Exercise number and exact step where you face the issue 
- OS version: run cat /etc/os-release and post the output in your request 
- Docker version: docker version and post the output in your request - Your server setup (docker, separate/shared/dockerized ETH/BTC RPC nodes, etc.)
- Relevant addresses to the issue:
     - BTC address on Axelar 
     - ETH address on Axelar 
     - ETH wallet address (destination) 
     - BTC wallet address (destination) 
     - A link to the TX hash of the transaction where you experience the issue, etc.  
