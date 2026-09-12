package com.etrm.tradeservice.repository;

import com.etrm.tradeservice.entity.Trade;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TradeRepository extends JpaRepository<Trade, Long> {
}
