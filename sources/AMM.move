module net2dev_addr::AMM{
    //use std::string::{String, utf8};
    use std::debug::print;
    use std::signer;
    use std::vector;

    const CONST_PRODUCT: u64 = 10000;

    struct Pool has drop, store, key, copy {
        amountA: u64,
        amountB: u64,
    }

    struct Trade has drop, store, key, copy{
        amount: u64,
        account: address,
    }

    struct AllTrades has drop, store, key, copy {
        trades_A: vector<Trade>,
        trades_B: vector<Trade>,
    }

    fun init_pool(account: &signer, amountA: u64, amountB: u64){
        let pool = Pool{amountA: amountA, amountB: amountB};
        move_to(account, pool);
    }

    fun get_trade(account: address): u64 acquires Trade {
        borrow_global_mut<Trade>(account).amount
    }

    fun get_all_trades(account: address): vector<Trade> acquires AllTrades {
        borrow_global_mut<AllTrades>(account).trades_A
    }
    

    fun add_trade(account: &signer, amount: u64){
        let trade = Trade{amount: amount, account: signer::address_of(account)};
        move_to(account, trade);
    }

    fun calculate_exchange_rate(amountA: u64, amountB: u64): u64 {
        amountA / amountB
    }

    fun sum_trades(trades: vector<Trade>, amount_trades: u64): u64 {
        let total_amount = 0;
        for (i in 0..amount_trades) {
            print(vector::borrow<Trade>(&trades, i));
            total_amount = total_amount + vector::borrow<Trade>(&trades, i).amount;
        };
        print(&total_amount);
        total_amount
    }

    fun add_money_to_pool_A(pool_A: &mut u64, amount: u64) {
        *pool_A = *pool_A + amount;
    }

    fun return_pool_balances(account: address): (u64, u64) acquires Pool {
        (borrow_global<Pool>(account).amountA, borrow_global<Pool>(account).amountB)
    }
    

#[test(client1 = @0x123, client2 = @0x144)]
    fun test_trade(client1: signer, client2: signer) acquires Trade {
        let trade = Trade{amount: 100, account: signer::address_of(&client1)};
        move_to(&client1, trade);

        let amount = get_trade(signer::address_of(&client1));
        assert!(amount == 100, 100);

        let trade = Trade{amount: 200, account: signer::address_of(&client2)};
        move_to(&client2, trade);

        let amount2 = get_trade(signer::address_of(&client2));
        assert!(amount2 == 200, 200);
    }

#[test(client1 = @0x123, client2 = @0x144, amm_addr = @0x155)]
    fun test_all_trades(client1: signer, client2: signer, amm_addr: signer) acquires AllTrades {

        let trade = Trade{amount: 100, account: signer::address_of(&client1)};
        move_to(&client1, trade);

        let trade2 = Trade{amount: 200, account: signer::address_of(&client2)};
        move_to(&client2, trade2);

        let all_trades = AllTrades{trades_A: vector<Trade>[trade, trade2], trades_B: vector<Trade>[]};
        move_to(&amm_addr, all_trades);

        let trades = get_all_trades(signer::address_of(&amm_addr));
        print(&trades);
    }

#[test(client1 = @0x123, client2 = @0x144, amm_addr = @0x155)]
    fun test_sum_trades(client1: signer, client2: signer, amm_addr: signer) acquires AllTrades {
        let trade = Trade{amount: 100, account: signer::address_of(&client1)};
        move_to(&client1, trade);

        let trade2 = Trade{amount: 200, account: signer::address_of(&client2)};
        move_to(&client2, trade2);

        let all_trades = AllTrades{trades_A: vector<Trade>[trade, trade2], trades_B: vector<Trade>[]};
        move_to(&amm_addr, all_trades);

        let trades = get_all_trades(signer::address_of(&amm_addr));
        let total_amount = 0;
        assert!(sum_trades(trades, 2) == 300, 300);

    }


#[test(client1 = @0x123, client2 = @0x144, amm_addr = @0x155)]
    fun test_add_money_to_pool(client1: signer, client2: signer, amm_addr: signer) acquires Pool {
        let pool = Pool{amountA: 100, amountB: 100};
        move_to(&amm_addr, pool);

        let pool_A = &mut borrow_global_mut<Pool>(signer::address_of(&amm_addr)).amountA;

        add_money_to_pool_A(pool_A, 100);
        let (total_a, total_b) = return_pool_balances(signer::address_of(&amm_addr));
        print(&total_a);
        print(&total_b);

        assert!(total_a == 200, 200);
        assert!(total_b == 100, 100);
    }

#[test(client1 = @0x123, client2 = @0x144, amm_addr = @0x155)]
    fun test_calculate_exchange_rate(client1: signer, client2: signer, amm_addr: signer) acquires AllTrades {
        let trade = Trade{amount: 100, account: signer::address_of(&client1)};
        move_to(&client1, trade);

        let trade2 = Trade{amount: 200, account: signer::address_of(&client2)};
        move_to(&client2, trade2);

        let all_trades = AllTrades{trades_A: vector<Trade>[trade, trade2], trades_B: vector<Trade>[]};
        move_to(&amm_addr, all_trades);

        let trades = get_all_trades(signer::address_of(&amm_addr));
        let total_amount = 0;
        sum_trades(trades, 2);
        let exchange_rate = calculate_exchange_rate(100, 200);
        print(&exchange_rate);
    }
}