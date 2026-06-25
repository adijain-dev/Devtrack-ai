package com.example.demo.controller;

import com.example.demo.dto.DsaTopicRequest;
import com.example.demo.dto.DsaTopicResponse;
import com.example.demo.security.UserDetailsImpl;
import com.example.demo.service.DsaTopicService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dsa")
public class DsaTopicController {

    @Autowired
    private DsaTopicService dsaTopicService;

    @GetMapping
    public ResponseEntity<List<DsaTopicResponse>> getAllTopics(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<DsaTopicResponse> topics = dsaTopicService.getAllTopics(userDetails.getId());
        return ResponseEntity.ok(topics);
    }

    @PostMapping
    public ResponseEntity<DsaTopicResponse> createTopic(
            @Valid @RequestBody DsaTopicRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        DsaTopicResponse response = dsaTopicService.createTopic(userDetails.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DsaTopicResponse> updateTopic(
            @PathVariable Long id,
            @Valid @RequestBody DsaTopicRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        DsaTopicResponse response = dsaTopicService.updateTopic(userDetails.getId(), id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTopic(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        dsaTopicService.deleteTopic(userDetails.getId(), id);
        return ResponseEntity.ok("DSA Topic deleted successfully.");
    }
}
