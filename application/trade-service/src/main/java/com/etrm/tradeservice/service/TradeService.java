package com.etrm.tradeservice.service;

import com.etrm.tradeservice.dto.TradeRequest;
import com.etrm.tradeservice.dto.TradeResponse;
import com.etrm.tradeservice.entity.Trade;
import com.etrm.tradeservice.repository.TradeRepository;
import org.springframework.stereotype.Service;
import com.etrm.tradeservice.exception.TradeNotFoundException;

import java.util.List;

@Service
public class TradeService {

    private final TradeRepository tradeRepository;

    public TradeService(TradeRepository tradeRepository) {
        this.tradeRepository = tradeRepository;
    }

    public TradeResponse createTrade(TradeRequest request) {

        Trade trade = new Trade();

        trade.setCounterparty(request.getCounterparty());
        trade.setCommodity(request.getCommodity());
        trade.setQuantity(request.getQuantity());
        trade.setPrice(request.getPrice());
        trade.setTradeType(request.getTradeType());

        Trade savedTrade = tradeRepository.save(trade);

        return mapToResponse(savedTrade);
    }

    public List<TradeResponse> getAllTrades() {

        return tradeRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    public TradeResponse getTradeById(Long tradeId) {

        Trade trade = tradeRepository.findById(tradeId)
                .orElseThrow(() ->
                        new TradeNotFoundException(tradeId));

        return mapToResponse(trade);
    }

    public TradeResponse updateTrade(
            Long tradeId,
            TradeRequest request) {

        Trade existingTrade = tradeRepository.findById(tradeId)
                .orElseThrow(() ->
                        new TradeNotFoundException(tradeId));

        existingTrade.setCounterparty(request.getCounterparty());
        existingTrade.setCommodity(request.getCommodity());
        existingTrade.setQuantity(request.getQuantity());
        existingTrade.setPrice(request.getPrice());
        existingTrade.setTradeType(request.getTradeType());

        Trade updatedTrade = tradeRepository.save(existingTrade);

        return mapToResponse(updatedTrade);
    }

    public void deleteTrade(Long tradeId) {

        Trade existingTrade = tradeRepository.findById(tradeId)
                .orElseThrow(() ->
                        new TradeNotFoundException(tradeId));

        tradeRepository.delete(existingTrade);
    }

    private TradeResponse mapToResponse(Trade trade) {

        TradeResponse response = new TradeResponse();

        response.setTradeId(trade.getTradeId());
        response.setCounterparty(trade.getCounterparty());
        response.setCommodity(trade.getCommodity());
        response.setQuantity(trade.getQuantity());
        response.setPrice(trade.getPrice());
        response.setTradeType(trade.getTradeType());
        response.setStatus(trade.getStatus());
        response.setCreatedAt(trade.getCreatedAt());
        response.setUpdatedAt(trade.getUpdatedAt());

        return response;
    }
}
