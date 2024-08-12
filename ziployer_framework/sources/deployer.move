module ziptos_framework::Deployer {

    use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset};
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::function_info;
    use aptos_framework::dispatchable_fungible_asset;
    use std::error;
    use std::option;

    use aptos_framework::coin::{
        Self, 
        BurnCapability, 
        FreezeCapability, 
        MintCapability
    };
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::managed_coin;
    use std::signer;
    use std::string::{Self,String,utf8};

    struct Config has key {
        owner: address,
        fee: u64
    }

    struct Capabilities<phantom CoinType> has key {
        burn_cap: BurnCapability<CoinType>,
        freeze_cap: FreezeCapability<CoinType>,
        mint_cap: MintCapability<CoinType>,
    }

    // Error Codes 
    const ERROR_INVALID_ZIPTOS_ACCOUNT: u64 = 0;
    const ERROR_ERROR_INSUFFICIENT_APT_BALANCE: u64 = 1;
    const INSUFFICIENT_APT_BALANCE: u64 = 2;

    const ASSET_SYMBOL: vector<u8> = b"FA";


    entry public fun init(ziptos_framework: &signer, fee: u64, owner: address){
        assert!(
            signer::address_of(ziptos_framework) == @ziptos_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );

        move_to(ziptos_framework, Config {
            owner,
            fee
        });
    }

    entry public fun update_fee(ziptos_framework: &signer, new_fee: u64) acquires Config {
        assert!(
            signer::address_of(ziptos_framework) == @ziptos_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );
        // only allowed after the deployer is initialized
        assert!(exists<Config>(@ziptos_framework), ERROR_ERROR_INSUFFICIENT_APT_BALANCE);

        let config = borrow_global_mut<Config>(@ziptos_framework);
        config.fee = new_fee;
    }

    entry public fun update_owner(ziptos_framework: &signer, new_owner: address) acquires Config {
        assert!(
            signer::address_of(ziptos_framework) == @ziptos_framework, 
            ERROR_INVALID_ZIPTOS_ACCOUNT
        );
        // only allowed after the deployer is initialized
        assert!(exists<Config>(@ziptos_framework), ERROR_ERROR_INSUFFICIENT_APT_BALANCE);

        let config = borrow_global_mut<Config>(@ziptos_framework);
        config.owner = new_owner;
    }

    // Generates a new coin and mints the total supply to the deployer. capabilties are then destroyed
    entry public fun generate_coin<CoinType>(
        deployer: &signer,
        name: String,
        symbol: String,
        decimals: u8,
        total_supply: u64,
        monitor_supply: bool,
    ) acquires Capabilities, Config {        
        // only allowed after the deployer is initialized
        assert!(exists<Config>(@ziptos_framework), ERROR_ERROR_INSUFFICIENT_APT_BALANCE);
        // the deployer must have enough APT to pay for the fee
        assert!(
            coin::balance<AptosCoin>(signer::address_of(deployer)) >= borrow_global<Config>(@ziptos_framework).fee,
            INSUFFICIENT_APT_BALANCE
        );
        let deployer_addr = signer::address_of(deployer);
        let (
            burn_cap, 
            freeze_cap, 
            mint_cap
        ) = coin::initialize<CoinType>(
            deployer, 
            name, 
            symbol, 
            decimals, 
            monitor_supply
        );

        // move caps
        move_to(deployer, Capabilities<CoinType> {
            burn_cap,
            freeze_cap,
            mint_cap,
        });

        coin::register<CoinType>(deployer);
        mint_internal<CoinType>(deployer_addr, total_supply);

        collect_fee(deployer);

        // destroy caps
        coin::destroy_freeze_cap<CoinType>(freeze_cap);
        coin::destroy_burn_cap<CoinType>(burn_cap);
        coin::destroy_mint_cap<CoinType>(mint_cap);
    }

    // Helper function; used to mint freshly created coin
    fun mint_internal<CoinType>(
        deployer_addr: address,
        total_supply: u64
    )acquires Capabilities {
        let caps = borrow_global<Capabilities<CoinType>>(deployer_addr);
        let coins_minted = coin::mint(total_supply, &caps.mint_cap);
        coin::deposit(deployer_addr, coins_minted);
    }

    fun collect_fee(deployer: &signer) acquires Config {
        let config = borrow_global_mut<Config>(@ziptos_framework);
        coin::transfer<AptosCoin>(deployer, config.owner, config.fee);
    }

    #[test_only]
    use aptos_framework::aptos_coin;
    #[test_only]
    use std::string;
    #[test_only]
    struct FakeZIPTOS {}

    #[test(aptos_framework = @0x1, ziptos_framework = @ziptos_framework, user = @0x123)]
    // #[expected_failure, code = 65537]
    fun test_user_deploys_coin(
        aptos_framework: signer,
        ziptos_framework: signer,
        user: &signer,
    ) acquires Capabilities, Config {
        aptos_framework::account::create_account_for_test(signer::address_of(&ziptos_framework));
        // aptos_framework::account::create_account_for_test(signer::address_of(user));
        init(&ziptos_framework, 1, signer::address_of(&ziptos_framework));
        // register aptos coin and mint some APT to be able to pay for the fee of generate_coin
        managed_coin::register<AptosCoin>(&ziptos_framework);
        let (aptos_coin_burn_cap, aptos_coin_mint_cap) = aptos_coin::initialize_for_test(&aptos_framework);
        // mint some APT to be able to pay for the fee of generate_coin
        aptos_coin::mint(&aptos_framework, signer::address_of(&ziptos_framework), 1000);
        
        generate_coin<FakeZIPTOS>(
            &ziptos_framework,
            string::utf8(b"Fake ZIPTOS"),
            string::utf8(b"ZIPTOS"),
            18,
            1000,
            true,
        );

        // destroy APT mint and burn caps
        coin::destroy_mint_cap<AptosCoin>(aptos_coin_mint_cap);
        coin::destroy_burn_cap<AptosCoin>(aptos_coin_burn_cap);
        
    }
}
