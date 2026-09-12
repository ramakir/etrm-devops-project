package com.etrm.tradeservice.controller;

import com.etrm.tradeservice.dto.TradeRequest;
import com.etrm.tradeservice.dto.TradeResponse;
import com.etrm.tradeservice.service.TradeService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/trades")
public class TradeController {

    private final TradeService tradeService;

    public TradeController(TradeService tradeService) {
        this.tradeService = tradeService;
    }

    @PostMapping
    public ResponseEntity<TradeResponse> createTrade(
            @Valid @RequestBody TradeRequest request) {

        TradeResponse response =
                tradeService.createTrade(request);

        return new ResponseEntity<>(
                response,
                HttpStatus.CREATED
        );
    }

    @GetMapping
    public ResponseEntity<List<TradeResponse>> getAllTrades() {

        return ResponseEntity.ok(
                tradeService.getAllTrades()
        );
    }

    @GetMapping("/{tradeId}")
    public ResponseEntity<TradeResponse> getTradeById(
            @PathVariable Long tradeId) {

        return ResponseEntity.ok(
                tradeService.getTradeById(tradeId)
        );
    }

    @PutMapping("/{tradeId}")
    public ResponseEntity<TradeResponse> updateTrade(
            @PathVariable Long tradeId,
            @Valid @RequestBody TradeRequest request) {

        return ResponseEntity.ok(
                tradeService.updateTrade(
                        tradeId,
                        request
                )
        );
    }

    @DeleteMapping("/{tradeId}")
    public ResponseEntity<Void> deleteTrade(
            @PathVariable Long tradeId) {

        tradeService.deleteTrade(tradeId);

        return ResponseEntity.noContent().build();
    }
}
