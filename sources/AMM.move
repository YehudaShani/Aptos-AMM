module net2dev_addr::AMM{
    //use std::string::{String, utf8};
    use std::debug::print;
    use std::signer;

    struct Pool has drop, store, key {
        amountA: u64,
        amountB: u64,
    }

    struct Trade has drop, store, key, copy{
        amount: u64,
    }

    struct AllTrades has drop, store, key, copy {
        trades: vector<Trade>,
    }

    fun init_pool(account: &signer, amountA: u64, amountB: u64){
        let pool = Pool{amountA: amountA, amountB: amountB};
        move_to(account, pool);
    }

    fun get_trade(account: address): u64 acquires Trade {
        borrow_global_mut<Trade>(account).amount
    }

    fun get_all_trades(account: address): vector<Trade> acquires AllTrades {
        borrow_global_mut<AllTrades>(account).trades
    }
    

    fun add_trade(account: &signer, amount: u64){
        let trade = Trade{amount: amount};
        move_to(account, trade);
    }

#[test(client1 = @0x123, client2 = @0x144)]
    fun test_trade(client1: signer, client2: signer) acquires Trade {
        let trade = Trade{amount: 100};
        move_to(&client1, trade);
        let amount = get_trade(signer::address_of(&client1));
        assert!(amount == 100, 100);

        let trade2 = Trade{amount: 200};
        move_to(&client2, trade2);
        let amount2 = get_trade(signer::address_of(&client2));
        assert!(amount2 == 200, 200);
    }

#[test(client1 = @0x123, client2 = @0x144, amm_addr = @0x155)]
    fun test_all_trades(client1: signer, client2: signer, amm_addr: signer) acquires AllTrades {

        let trade = Trade{amount: 100};
        move_to(&client1, trade);

        let trade2 = Trade{amount: 200};
        move_to(&client2, trade2);

        let all_trades = AllTrades{trades: vector<Trade>[trade, trade2]};
        move_to(&amm_addr, all_trades);

        let trades = get_all_trades(signer::address_of(&amm_addr));
        print(&trades);
    }
}