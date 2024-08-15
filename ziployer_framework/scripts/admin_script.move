script {
    use ziptos_framework::Deployer;

    fun init(ziptos_framework: &signer, fee: u64, owner: address, pending_owner: address) {
        //change the fee accordingly
        Deployer::init(ziptos_framework, fee, owner, pending_owner);
    }
}

script {
    use ziptos_framework::Deployer;

    fun update_fee(ziptos_framework: &signer, new_fee: u64) {
        Deployer::update_fee(ziptos_framework, new_fee);
    }
}

script {
    use ziptos_framework::Deployer;

    fun offer_ownership(ziptos_framework: &signer, new_owner: address) {
        Deployer::offer_ownership(ziptos_framework, new_owner);
    }

}