# cosponsor

This is a script that allows a collective co-sponsor protocol for governance actions.

Users can deposit ADA, earmarked to cosponsor a specific governance proposal.
In return, they get a temporary tracking token, which they can burn to retrieve their ADA if the proposal hasn't reached the minimum amount.

These ADA pots can be aggregated into larger pots if needed, or if the proposal amount is reached, can be used to cover the deposit and create the appropriate governance proposal.

When the proposal expires, the deposit goes back to the reward account. From there, they can be withdrawn into a UTXO marked as "Done".

Users can burn *any* of the temporary tokens to withdraw from the done state, so you don't have to worry about where the rewards came from.

Note: this doesn't currently handle yield, but we could mint some kind of "yield" token that was able to claim a portion of the staking rewards earned by the funds while they waited for cosponsorship and create a sort of proto-treasury.