package com.example.demo.service;

import com.example.demo.dto.InternshipRequest;
import com.example.demo.dto.InternshipResponse;
import com.example.demo.model.Internship;
import com.example.demo.model.User;
import com.example.demo.repository.InternshipRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class InternshipService {

    @Autowired
    private InternshipRepository internshipRepository;
    
    @Autowired
    private UserRepository userRepository;

    public List<InternshipResponse> getAllInternships(Long userId) {
        List<Internship> internships = internshipRepository.findByUserId(userId);
        return internships.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public InternshipResponse createInternship(Long userId, InternshipRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Internship internship = new Internship();
        internship.setUser(user);
        internship.setCompanyName(request.getCompanyName());
        internship.setRole(request.getRole());
        internship.setLocation(request.getLocation());
        internship.setSalary(request.getSalary());
        internship.setJobLink(request.getJobLink());
        if (request.getStatus() != null) {
            internship.setStatus(request.getStatus());
        }
        internship.setAppliedDate(request.getAppliedDate());
        internship.setNotes(request.getNotes());

        Internship saved = internshipRepository.save(internship);
        return mapToResponse(saved);
    }

    public InternshipResponse updateInternship(Long userId, Long internshipId, InternshipRequest request) {
        Internship internship = internshipRepository.findByIdAndUserId(internshipId, userId)
                .orElseThrow(() -> new RuntimeException("Internship not found or unauthorized"));

        internship.setCompanyName(request.getCompanyName());
        internship.setRole(request.getRole());
        internship.setLocation(request.getLocation());
        internship.setSalary(request.getSalary());
        internship.setJobLink(request.getJobLink());
        if (request.getStatus() != null) {
            internship.setStatus(request.getStatus());
        }
        internship.setAppliedDate(request.getAppliedDate());
        internship.setNotes(request.getNotes());

        Internship updated = internshipRepository.save(internship);
        return mapToResponse(updated);
    }

    public void deleteInternship(Long userId, Long internshipId) {
        Internship internship = internshipRepository.findByIdAndUserId(internshipId, userId)
                .orElseThrow(() -> new RuntimeException("Internship not found or unauthorized"));
        
        internshipRepository.delete(internship);
    }

    private InternshipResponse mapToResponse(Internship internship) {
        InternshipResponse response = new InternshipResponse();
        response.setId(internship.getId());
        response.setCompanyName(internship.getCompanyName());
        response.setRole(internship.getRole());
        response.setLocation(internship.getLocation());
        response.setSalary(internship.getSalary());
        response.setJobLink(internship.getJobLink());
        response.setStatus(internship.getStatus());
        response.setAppliedDate(internship.getAppliedDate());
        response.setNotes(internship.getNotes());
        return response;
    }
}
