package com.example.demo.controller;

import com.example.demo.dto.InternshipRequest;
import com.example.demo.dto.InternshipResponse;
import com.example.demo.security.UserDetailsImpl;
import com.example.demo.service.InternshipService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/internships")
public class InternshipController {

    @Autowired
    private InternshipService internshipService;

    @GetMapping
    public ResponseEntity<List<InternshipResponse>> getAllInternships(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<InternshipResponse> internships = internshipService.getAllInternships(userDetails.getId());
        return ResponseEntity.ok(internships);
    }

    @GetMapping("/upcoming-interviews")
    public ResponseEntity<List<InternshipResponse>> getUpcomingInterviews(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<InternshipResponse> interviews = internshipService.getUpcomingInterviews(userDetails.getId());
        return ResponseEntity.ok(interviews);
    }

    @PostMapping
    public ResponseEntity<InternshipResponse> createInternship(
            @Valid @RequestBody InternshipRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        InternshipResponse response = internshipService.createInternship(userDetails.getId(), request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<InternshipResponse> updateInternship(
            @PathVariable Long id,
            @Valid @RequestBody InternshipRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        InternshipResponse response = internshipService.updateInternship(userDetails.getId(), id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteInternship(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        internshipService.deleteInternship(userDetails.getId(), id);
        return ResponseEntity.ok("Internship deleted successfully.");
    }
}
