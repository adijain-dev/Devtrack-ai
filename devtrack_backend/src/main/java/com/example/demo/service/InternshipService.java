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

    @Autowired
    private com.example.demo.repository.NotificationRepository notificationRepository;

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
        internship.setInterviewDate(request.getInterviewDate());
        internship.setReminderEnabled(request.getReminderEnabled() != null ? request.getReminderEnabled() : (request.getInterviewDate() != null));
        internship.setResumeUrl(request.getResumeUrl());
        internship.setResumeFileName(request.getResumeFileName());
        internship.setNotes(request.getNotes());

        Internship saved = internshipRepository.save(internship);

        // Auto-generate notification
        notificationRepository.save(new com.example.demo.model.Notification(
            user,
            "Internship Added",
            String.format("Added application for %s at %s.", saved.getRole(), saved.getCompanyName())
        ));

        // Auto-generate interview alarm notification if interview date is set
        if (saved.getInterviewDate() != null) {
            notificationRepository.save(new com.example.demo.model.Notification(
                user,
                "Interview Reminder",
                String.format("Interview scheduled with %s for %s on %s.", 
                    saved.getCompanyName(), saved.getRole(), saved.getInterviewDate().toString().replace("T", " at "))
            ));
        }

        return mapToResponse(saved);
    }

    public InternshipResponse updateInternship(Long userId, Long internshipId, InternshipRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Internship internship = internshipRepository.findByIdAndUserId(internshipId, userId)
                .orElseThrow(() -> new RuntimeException("Internship not found or unauthorized"));

        com.example.demo.model.ApplicationStatus oldStatus = internship.getStatus();
        java.time.LocalDateTime oldInterviewDate = internship.getInterviewDate();

        internship.setCompanyName(request.getCompanyName());
        internship.setRole(request.getRole());
        internship.setLocation(request.getLocation());
        internship.setSalary(request.getSalary());
        internship.setJobLink(request.getJobLink());
        if (request.getStatus() != null) {
            internship.setStatus(request.getStatus());
        }
        internship.setAppliedDate(request.getAppliedDate());
        internship.setInterviewDate(request.getInterviewDate());
        if (request.getReminderEnabled() != null) {
            internship.setReminderEnabled(request.getReminderEnabled());
        }
        internship.setResumeUrl(request.getResumeUrl());
        internship.setResumeFileName(request.getResumeFileName());
        internship.setNotes(request.getNotes());

        Internship updated = internshipRepository.save(internship);

        // Auto-generate notification if status changed
        if (oldStatus != updated.getStatus()) {
            notificationRepository.save(new com.example.demo.model.Notification(
                user,
                "Status Updated",
                String.format("%s at %s status changed from %s to %s.", 
                    updated.getRole(), updated.getCompanyName(), oldStatus, updated.getStatus())
            ));
        }

        // Auto-generate notification if interview scheduled or rescheduled
        if (updated.getInterviewDate() != null && !updated.getInterviewDate().equals(oldInterviewDate)) {
            notificationRepository.save(new com.example.demo.model.Notification(
                user,
                "Interview Scheduled",
                String.format("Interview with %s for %s is set for %s.", 
                    updated.getCompanyName(), updated.getRole(), updated.getInterviewDate().toString().replace("T", " at "))
            ));
        }

        return mapToResponse(updated);
    }

    public List<InternshipResponse> getUpcomingInterviews(Long userId) {
        return internshipRepository.findByUserIdAndInterviewDateIsNotNullOrderByInterviewDateAsc(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
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
        response.setInterviewDate(internship.getInterviewDate());
        response.setReminderEnabled(internship.getReminderEnabled());
        response.setResumeUrl(internship.getResumeUrl());
        response.setResumeFileName(internship.getResumeFileName());
        response.setNotes(internship.getNotes());
        return response;
    }
}
