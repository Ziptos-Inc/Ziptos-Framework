module zipdrip_framework::Zipdrip_Framework {

    use std::string::{String};
    use 0x1::object;
    use 0x1::object::Object;
    use std::vector;
    use aptos_token::token_transfers;
    use aptos_token::token;
    use 0x1::primary_fungible_store::transfer;
    use 0x1::aptos_account::batch_transfer_coins;
    use std::signer;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;
    
    const ERROR_LENGTH_NOT_SAME: u64 = 1;
    const ERROR_INVALID_ZIPTOS_ACCOUNT: u64 = 0;
    const INSUFFICIENT_APT_BALANCE: u64 = 2;
    const ERROR_ERROR_INSUFFICIENT_APT_BALANCE: u64 = 3;

    struct Config has key {
        owner: address,
        legacyCoinFee : u64,
        fungibleAssetFee : u64,
        nftFee : u64
    }

       entry public fun init(zipdrip_framework: &signer, legacyCoinFee : u64,
        fungibleAssetFee : u64,
        nftFee : u64,
        owner: address){
        assert!(
            signer::address_of(zipdrip_framework) == @zipdrip_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );

        move_to(zipdrip_framework, Config {
            owner,
            legacyCoinFee,
            fungibleAssetFee,
            nftFee
        });
    }

     entry public fun update_owner(zipdrip_framework: &signer, new_owner: address) acquires Config {
        assert!(
            signer::address_of(zipdrip_framework) == @zipdrip_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );
        // only allowed after the deployer is initialized
        assert!(exists<Config>(@zipdrip_framework), ERROR_ERROR_INSUFFICIENT_APT_BALANCE);

        let config = borrow_global_mut<Config>(@zipdrip_framework);
        config.owner = new_owner;
    }

     fun collect_fungibleAssetFee(deployer: &signer, size : u64) acquires Config {
        let config = borrow_global_mut<Config>(@zipdrip_framework);
        coin::transfer<AptosCoin>(deployer, config.owner, size * config.fungibleAssetFee);
    }

    fun collect_legacyCoinFee(deployer: &signer, size : u64 ) acquires Config {
        let config = borrow_global_mut<Config>(@zipdrip_framework);
        coin::transfer<AptosCoin>(deployer, config.owner, size * config.legacyCoinFee);
    }

    fun collect_nftFee(deployer: &signer, size : u64) acquires Config {
        let config = borrow_global_mut<Config>(@zipdrip_framework);
        coin::transfer<AptosCoin>(deployer, config.owner, size * config.nftFee);
    }

    entry public fun update_legacyCoinFee(zipdrip_framework: &signer, new_fee: u64) acquires Config {
        assert!(
            signer::address_of(zipdrip_framework) == @zipdrip_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );
        // only allowed after the deployer is initialized
        assert!(exists<Config>(@zipdrip_framework), ERROR_ERROR_INSUFFICIENT_APT_BALANCE);

        let config = borrow_global_mut<Config>(@zipdrip_framework);
        config.legacyCoinFee = new_fee;
    }

    entry public fun update_fungibleAssetFee(zipdrip_framework: &signer, new_fee: u64) acquires Config {
        assert!(
            signer::address_of(zipdrip_framework) == @zipdrip_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );
        // only allowed after the deployer is initialized
        assert!(exists<Config>(@zipdrip_framework), ERROR_ERROR_INSUFFICIENT_APT_BALANCE);

        let config = borrow_global_mut<Config>(@zipdrip_framework);
        config.fungibleAssetFee = new_fee;
    }

    entry public fun update_nftFee(zipdrip_framework: &signer, new_fee: u64) acquires Config {
        assert!(
            signer::address_of(zipdrip_framework) == @zipdrip_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );
        // only allowed after the deployer is initialized
        assert!(exists<Config>(@zipdrip_framework), ERROR_ERROR_INSUFFICIENT_APT_BALANCE);

        let config = borrow_global_mut<Config>(@zipdrip_framework);
        config.nftFee = new_fee;
    }
    

    entry fun bulkSendNftV2<Token : key>(deployer: &signer, nftAddresses: vector<Object<Token>>,to: vector<address>) acquires Config {
        let length_Nft: u64 = vector::length<Object<Token>>(&nftAddresses);
        let length_to: u64 = vector::length<address>(&to);

        assert!(
            length_Nft == length_to, 
            ERROR_LENGTH_NOT_SAME
        );

        for (i in 0..length_Nft) {
           object::transfer( deployer, *vector::borrow(&nftAddresses, i), *vector::borrow(&to, i));
        };

        collect_nftFee(deployer,length_Nft);
        
    }

     entry fun bulkSendNftV1(deployer: &signer,
        receiver: vector<address>,
        creator: address,
        collection: String,
        name: vector<String>,
        property_version: vector<u64>,
        amount: u64,) acquires Config  {
        
        let length_Name: u64 = vector::length<String>(&name);
        let length_To: u64 = vector::length<address>(&receiver);
        let length_property: u64 = vector::length<u64>(&property_version);

          assert!(
            length_Name == length_To, 
            ERROR_LENGTH_NOT_SAME
        );

        assert!(
            length_Name == length_property, 
            ERROR_LENGTH_NOT_SAME
        );

           for (i in 0..length_Name) {
            let token_id = token::create_token_id_raw(creator, collection, *vector::borrow(&name, i), *vector::borrow(&property_version, i));
            token_transfers::offer(deployer,*vector::borrow(&receiver, i),token_id,amount);
        };

        collect_nftFee(deployer,length_To);
    }

    entry fun bulkSendFungibleAsset<Metadata : key>(sender: &signer, metadata: object::Object<Metadata>, recipient: vector<address>, amount: vector<u64>) acquires Config {

        let length_Amount: u64 = vector::length<u64>(&amount);
        let length_Recipient: u64 = vector::length<address>(&recipient);

        assert!(
            length_Amount == length_Recipient, 
            ERROR_LENGTH_NOT_SAME
        );

        for (i in 0..length_Amount) {
             transfer(sender, metadata, *vector::borrow(&recipient, i), *vector::borrow(&amount, i));
        };

        collect_fungibleAssetFee(sender,length_Amount);
    }

    public entry fun bulkSendLegacyCoin<CoinType>(deployer: &signer, to:  vector<address>, amount: vector<u64>) acquires Config  {
        batch_transfer_coins<CoinType>(deployer,to,amount);
        let length_to: u64 = vector::length<address>(&to);
        collect_legacyCoinFee(deployer,length_to)
    }
    

}