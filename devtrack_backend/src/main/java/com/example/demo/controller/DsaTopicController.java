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

    @Autowired
    private com.example.demo.service.CodingProfileSyncService codingProfileSyncService;

    @GetMapping
    public ResponseEntity<List<DsaTopicResponse>> getAllTopics(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<DsaTopicResponse> topics = dsaTopicService.getAllTopics(userDetails.getId());
        return ResponseEntity.ok(topics);
    }

    @GetMapping("/revisions")
    public ResponseEntity<List<DsaTopicResponse>> getTopicsDueForRevision(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<DsaTopicResponse> revisions = dsaTopicService.getTopicsDueForRevision(userDetails.getId());
        return ResponseEntity.ok(revisions);
    }

    @PostMapping("/{id}/review")
    public ResponseEntity<DsaTopicResponse> reviewTopic(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        DsaTopicResponse response = dsaTopicService.reviewTopic(userDetails.getId(), id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/sync")
    public ResponseEntity<com.example.demo.dto.CodingProfileStatsDto> syncProfile(
            @Valid @RequestBody com.example.demo.dto.SyncProfileRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        com.example.demo.dto.CodingProfileStatsDto stats =
                codingProfileSyncService.syncProfile(userDetails.getId(), request);
        return ResponseEntity.ok(stats);
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
