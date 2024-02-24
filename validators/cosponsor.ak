type GovernanceAction {
    ParameterChange
    HardForkInitiation
    TreasuryWithdrawals
    NoConfidence
    UpdateCommittee
    NewConstitution
    InfoAction
}

type ProposalProcedure {
    deposit: Int,
    return_addr: Credential,
    governance_action: GovernanceAction,
}

type Datum {
    // Before the governance action is created, the only people who can withdraw
    // are the people who cosponsored the proposal
    Before {
        // The proposal this UTXO is destined to cosponsor
        cosponsored: ProposalProcedure
    },
    // After the governance action has returend its deposit, anybody can withdraw
    After
}

validator {
    // The spend script always defers to the observations, which can either aggregate or publish
    fn spend(datum: Datum, redeemer: Redeemer, ctx: ScriptContext) {
        expect Spend(output_reference) = ctx.purpose
        expect Some(
            Input{
                output: Output{
                    address: Address(ScriptCredential(own_script_hash), ..)
                }
            }
        ) = transaction.find_input(output_reference)
        
        expect Some(self) = transaction.find_input(output_reference)
        expect ScriptCredential(own_script_hash) = self.output.address.payment_credential
        list.any(ctx.transaction.observations, fn(sh) { sh == own_script_hash })
    }

    fn govern(_r: Data, ctx: ScriptContext) {
        when ctx.purpose is {
            // Make sure we're also in the observers, so we can do it all in one pass
            Mint(own_policy_id) -> {
                list.any(ctx.transaction.observations, fn(sh) { sh == own_policy_id })
            }
            // If we're withdrawing from the reward account, create the appropriate UTXO
            // For now, assume this produces no yield, and ADA in is ADA out
            WithdrawFrom(own_credential) -> {
                // Find our own script hash
                expect Inline(ScriptCredential(own_script_hash)) = own_credential
                list.any(ctx.transaction.observations, fn(sh) { sh == own_script_hash })
            }
            // Allow many UTXOs to be aggregated into one
            // Or for the proposal to be published
            Observe(own_index) -> {
                // Work out a zero-sum game for the inputs, outputs, minting, withdrawal, and deposits

                // Sum up all the ADA grouped by the hash of the governance ID on the inputs
                // All of this ADA has to "go somewhere"

                // Add in each minted self token using token name as the ID
                // If the token is minted, this represents *additional ADA* that must end up in that output
                // If the token is burned, this represents *less ADA* that must end up in that output

                // Add the withdrawal amount of self to the Done category
                // This basically says when we withdrawal, we have to do so into a `Done` datum

                // Subtract off the governance deposit amount for each proposal created
                // Handle change into the done category if we're over 100k?
                // Can we over-deposit?
                // This is 100k per gov proposal that's going to disappear, so we let it, so long as we have the inputs to cover it

                // Subtract off each output by the hash of the governance ID on the outputs, or Done
                // This should now bring us down to zero for each one, since that ADA is going into the correct output

                // With one exception; maybe we withdrew from the Done category,
                // in which case anything that remains now must be negative or zero, and
                // the sum of all non-Done categories must be equal to the Done category
                // This corresponds to burning a mixed bag of tokens to withdraw the appropriate ADA
            }
            // For now, disallow delegation, so we don't earn yield
            Publish(delegation) -> {
                False
            }
            // Note allowed to register as a dRep or anything like that
            _ -> False
        }
    }
}