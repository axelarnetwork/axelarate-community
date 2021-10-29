---
slug: /validator-zone
sidebar_position: 1
---

# [DRAFT] Axelar Validator Zone
![img](../images/Axelar.png)

Interested in becoming an Axelar validator?  Get started:
* [Setup as Validator with Docker](/setup-validator-docker)
* [Setup as Validator with Binaries](/setup-validator-binaries)

# TODO

* Split bitcoin/ethereum node setup into separate pages
* Merge docker/binaries into a single doc?
    * If not then refactor repeated docs in docker/binaries into separate pages.  link to those pages from both docker and binaries instructions.
    * Is it possible to toggle which of docker/binary terminal commands are visible in the doc?  That way we have only 1 doc to maintain and yet docker/binary redundancy is eliminated.
* Drop script-based startup and force validators to do the steps themselves?
* New stuff:
    * validators now need to explicitly say their broadcaster is ready
    * Validators will send heartbeat that contains keys they have per X blocks.=