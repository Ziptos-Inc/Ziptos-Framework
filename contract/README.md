# BAPT Coin Deployer

## Onchain - Move modules

### Set up - cli:
Assuming the aptos cli is not configured, and install the aptos cli from [here](https://aptos.dev/tools/aptos-cli/install-cli/)

- cd into: `cd onchain`
- setting up aptos cli: 
    - `aptos init`
        ```console
        ➜  onchain aptos init                                                                   
        Configuring for profile default
        Choose network from [devnet, testnet, mainnet, local, custom | defaults to devnet]

        No network given, using devnet...
        Enter your private key as a hex literal (0x...) [Current: None | No input: Generate new key (or keep one if present)]

        No key given, generating key...
        Account 6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b doesn't exist, creating it and funding it with 100000000 Octas
        Account 6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b funded successfully

        ---
        Aptos CLI is now set up for account 6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b as profile default!  Run `aptos --help` for more information about commands
        {
        "Result": "Success"
        }
        ```
    - fund the default account: `aptos account fund-with-faucet --account default`
        ```console
        ➜  onchain aptos account fund-with-faucet --account default                             
            {
            "Result": "Added 100000000 Octas to account 6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b"
            }
        ```

    - Publish the modules: `aptos move publish --profile default --named-addresses bapt_framework=default`
        ```console
        ➜  onchain aptos move publish --profile default --named-addresses bapt_framework=default
            Compiling, may take a little while to download git dependencies...
            UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
            INCLUDING DEPENDENCY AptosFramework
            INCLUDING DEPENDENCY AptosStdlib
            INCLUDING DEPENDENCY MoveStdlib
            BUILDING coin-deployer
            package size 2025 bytes
            Do you want to submit a transaction for a range of [205600 - 308400] Octas at a gas unit price of 100 Octas? [yes/no] >
            yes
            {
            "Result": {
                "transaction_hash": "0xc393daecb516f48b4741ecf127aee37a92f62445fd8c0a56fd48d48746202378",
                "gas_used": 2056,
                "gas_unit_price": 100,
                "sender": "6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                "sequence_number": 0,
                "success": true,
                "timestamp_us": 1695808063028340,
                "version": 4024773,
                "vm_status": "Executed successfully"
            }
            }
        ```
    - Run the script to initialize the deployer module: `aptos move run-script --compiled-script-path build/coin-deployer/bytecode_scripts/init.mv --profile default`
        ```console
        ➜  onchain aptos move run-script --compiled-script-path build/coin-deployer/bytecode_scripts/init.mv --profile default
            Do you want to submit a transaction for a range of [50300 - 75400] Octas at a gas unit price of 100 Octas? [yes/no] >
            yes
            {
            "Result": {
                "transaction_hash": "0xf16fa6453aafb2e0b418310024945eb2c57979695f17d0fde0efd4b44e453d4e",
                "gas_used": 503,
                "gas_unit_price": 100,
                "sender": "6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                "sequence_number": 1,
                "success": true,
                "timestamp_us": 1695808080229943,
                "version": 4024890,
                "vm_status": "Executed successfully"
            }
            }
        ```
    - Run the script to generate the coins: `aptos move run-script --compiled-script-path build/coin-deployer/bytecode_scripts/generate_coin.mv --profile default `
        ```console
        ➜  onchain aptos move run-script --compiled-script-path build/coin-deployer/bytecode_scripts/generate_coin.mv --profile default 
            Do you want to submit a transaction for a range of [151100 - 226600] Octas at a gas unit price of 100 Octas? [yes/no] >
            yes
            {
            "Result": {
                "transaction_hash": "0xdd9c159f575b17a311a864341385c57fbc3c763d3b6309dd6f7592f7abdc80b3",
                "gas_used": 1512,
                "gas_unit_price": 100,
                "sender": "6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                "sequence_number": 2,
                "success": true,
                "timestamp_us": 1695808094977674,
                "version": 4025005,
                "vm_status": "Executed successfully"
            }
            }
        ```
    - To verify, you can check the account list: `aptos account list`
        ```console
        ➜  onchain aptos account list                                                                                                  
            {
            "Result": [
                {
                "0x1::account::Account": {
                    "authentication_key": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                    "coin_register_events": {
                    "counter": "2",
                    "guid": {
                        "id": {
                        "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                        "creation_num": "0"
                        }
                    }
                    },
                    "guid_creation_num": "6",
                    "key_rotation_events": {
                    "counter": "0",
                    "guid": {
                        "id": {
                        "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                        "creation_num": "1"
                        }
                    }
                    },
                    "rotation_capability_offer": {
                    "for": {
                        "vec": []
                    }
                    },
                    "sequence_number": "3",
                    "signer_capability_offer": {
                    "for": {
                        "vec": []
                    }
                    }
                }
                },
                {
                "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b::Deployer::Config": {
                    "coin": {
                    "value": "1"
                    },
                    "fee": 1,
                    "owner": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b"
                }
                },
                {
                "0x1::code::PackageRegistry": {
                    "packages": [
                    {
                        "deps": [
                        {
                            "account": "0x1",
                            "package_name": "AptosFramework"
                        },
                        {
                            "account": "0x1",
                            "package_name": "AptosStdlib"
                        },
                        {
                            "account": "0x1",
                            "package_name": "MoveStdlib"
                        }
                        ],
                        "extension": {
                        "vec": []
                        },
                        "manifest": "0x1f8b08000000000002ff4d8e4baec2300c45e75e05cabc296ffa24064cd844152137313482c6919d16b17b127e62967b738e75878cfe8267729070a6cd6e633cc7d405ca57be9318584934726a3f7f766bb7067029138bd6667000038620a44aea60c45c8e27a9876e2c97a61c4d2502addd0ff56c32a540c94752bbcf85f5f0b11c9c6369ea544ad6ffbeaf715a46eb79eeb191dd15477d3f3d0bd90a18105a9b34634c896ad6650c515af522675ea9ff4e7bebdffc59f9bbcbc103d6663a1d1c010000",
                        "modules": [
                        {
                            "extension": {
                            "vec": []
                            },
                            "name": "Tokens",
                            "source": "0x1f8b08000000000002ff013400cbff6d6f64756c6520626170745f6672616d65776f726b3a3a546f6b656e73207b0a202020207374727563742042415054207b7d0a7dceb2a47234000000",
                            "source_map": "0x"
                        },
                        {
                            "extension": {
                            "vec": []
                            },
                            "name": "Deployer",
                            "source": "0x1f8b08000000000002ff9d55ef4fdb3010fdce5f7163124aa5f0a3a250082d62da34699a264d62df2614b9c925583871673b7405f1bfcfb1d3d84953d0c89726ceddbdbbf7dea5054f2b86b0204b15678214b8e2e2218abee092f1350a78dedb037d5512418770e907259c9651f47c8b2c0be1b37e78b9da1d6c0f6ccaa7fabe4e7825be2025c93135192e4caa348a24cd4b14f6d0b62795a812a57b28339ac33d91f0806bdd3b349781352dce5aecebb07dcd57ba5e04244d054ae9ce33c408aa0bf3fc629196d582d104b2aa045a5215f4888303dbdcc861132951a80f817da189b02831cf7ac92398cfe1a67b16c2f8f4743aba6aab1d1fefd241604ea542e14dd80770650afe88b1e2411fad61d075efd8b3284f28b88f300a3ba10d936fcfda4d33448f1ba60ddb4daf9a75f38ba5126b9ffc1c35005168fc31fb751db4a96963dd560b07556af4081e31515cccaa0bcf01725d2c381b7e9762420bc2646d85d06350cbcf452cabe592ad235870cecccb1190e44f45f5dcdb6c6af578c9d64018e32b4c81645a3050f7d8760d541a6351c2e813a65b2ec2bf5a6439b395af839b3ead1bbfb83ebd3d8a2257bae66c031a1a66c28685b09d38ec4de91ba853b6f59e57746770414bd5451fb04b5b454f7431999c4f279393e9e9f4e4f2ec6c7c3e3ef38a279c31ad5aac3de463fb4b5b1b6628ccadeb8066ef5cb981f1192a0d6fcaceb54f84e0ab38677c41585c546aa7969e887505291243a0ae61d15754dda782ac86d043082ce2919e579b07aaf3c9a8439a5102458e7efa81eea769f5a80e095b54b78ff5cfc7df0aa58a6b2fdff91fe0afe401e1b9131490540b3eef0f77d70a632a75d6d9a66cbe226fecd3617d81c90089aa5ada9343b7395bff4449c2ab52691105d690cd739c699f9b8e07ec7860007c06ffc3124db2cb35ff1c5ba7af0dd30675bf7b35df9bfa212cf66fbf7dfff173dfde999bcb1032bdc8e8e47bf907a0005c3ef2070000",
                            "source_map": "0x"
                        }
                        ],
                        "name": "coin-deployer",
                        "source_digest": "541C841A0FC1DCAF08BDEFDD9D96E6E0CD0D805DC196BB7F172B1A37049D4034",
                        "upgrade_number": "0",
                        "upgrade_policy": {
                        "policy": 1
                        }
                    }
                    ]
                }
                },
                {
                "0x1::coin::CoinInfo<0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b::Tokens::BAPT>": {
                    "decimals": 9,
                    "name": "BAPT",
                    "supply": {
                    "vec": []
                    },
                    "symbol": "BAPT"
                }
                },
                {
                "0x1::coin::CoinStore<0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b::Tokens::BAPT>": {
                    "coin": {
                    "value": "18446744073709551615"
                    },
                    "deposit_events": {
                    "counter": "1",
                    "guid": {
                        "id": {
                        "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                        "creation_num": "4"
                        }
                    }
                    },
                    "frozen": false,
                    "withdraw_events": {
                    "counter": "0",
                    "guid": {
                        "id": {
                        "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                        "creation_num": "5"
                        }
                    }
                    }
                }
                },
                {
                "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>": {
                    "coin": {
                    "value": "299592899"
                    },
                    "deposit_events": {
                    "counter": "3",
                    "guid": {
                        "id": {
                        "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                        "creation_num": "2"
                        }
                    }
                    },
                    "frozen": false,
                    "withdraw_events": {
                    "counter": "1",
                    "guid": {
                        "id": {
                        "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                        "creation_num": "3"
                        }
                    }
                    }
                }
                },
                {
                "0x1::managed_coin::Capabilities<0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b::Tokens::BAPT>": {
                    "burn_cap": {
                    "dummy_field": false
                    },
                    "freeze_cap": {
                    "dummy_field": false
                    },
                    "mint_cap": {
                    "dummy_field": false
                    }
                }
                }
            ]
            }
        ```
        The deployed coin info/caps are:
        ```console
        "0x1::coin::CoinInfo<0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b::Tokens::BAPT>": {
            "decimals": 9,
            "name": "BAPT",
            "supply": {
            "vec": []
            },
            "symbol": "BAPT"
        },
        "0x1::managed_coin::Capabilities<0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b::Tokens::BAPT>": {
            "burn_cap": {
            "dummy_field": false
            },
            "freeze_cap": {
            "dummy_field": false
            },
            "mint_cap": {
            "dummy_field": false
            }
        }
        ```
        Finally the Coin Store:
        ```console
        "0x1::coin::CoinStore<0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b::Tokens::BAPT>": {
            "coin": {
            "value": "18446744073709551615"
            },
            "deposit_events": {
            "counter": "1",
            "guid": {
                "id": {
                "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                "creation_num": "4"
                }
            }
            },
            "frozen": false,
            "withdraw_events": {
            "counter": "0",
            "guid": {
                "id": {
                "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                "creation_num": "5"
                }
            }
            }
        },
        "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>": {
            "coin": {
            "value": "299592899"
            },
            "deposit_events": {
            "counter": "3",
            "guid": {
                "id": {
                "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                "creation_num": "2"
                }
            }
            },
            "frozen": false,
            "withdraw_events": {
            "counter": "1",
            "guid": {
                "id": {
                "addr": "0x6e883ebdb5d98037043e6133620889b36aefd225ca8639fb19bac0f7d8d71f7b",
                "creation_num": "3"
                }
            }
            }
        }
        ```
        since we are using the same account for creating aswell we can only find the gas fee differece in apt balance


### Flow
#### Admin(bapt_framework)
1. Publish the deployer module.
2. Initialize the module with the help of the script in the `admin_script.move`.

#### End user
1. The user should publish a module under their address `coincollection.move`, which contains all the types of the coins.
2. Then he should call the function `generate_coin` to initailize the coin.

Both of the these should be generated for the user to ease the workflow and the user can simply submit the transactions.
