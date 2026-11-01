package com.example.demo.service;

import com.example.demo.dto.DsaTopicRequest;
import com.example.demo.dto.DsaTopicResponse;
import com.example.demo.model.DsaTopic;
import com.example.demo.model.User;
import com.example.demo.repository.DsaTopicRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DsaTopicService {

    @Autowired
    private DsaTopicRepository dsaTopicRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.example.demo.repository.NotificationRepository notificationRepository;

    public List<DsaTopicResponse> getAllTopics(Long userId) {
        List<DsaTopic> topics = dsaTopicRepository.findByUserId(userId);
        return topics.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public DsaTopicResponse createTopic(Long userId, DsaTopicRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        DsaTopic topic = new DsaTopic();
        topic.setUser(user);
        topic.setTopicName(request.getTopicName());
        topic.setCategory(request.getCategory());
        topic.setDifficulty(request.getDifficulty());
        topic.setSolved(request.isSolved());
        topic.setSolvedDate(request.getSolvedDate());
        topic.setPlatform(request.getPlatform() != null ? request.getPlatform() : "MANUAL");
        topic.setProblemUrl(request.getProblemUrl());
        topic.setNotes(request.getNotes());
        topic.setPracticeCount(request.getPracticeCount());

        if (topic.isSolved()) {
            if (topic.getSolvedDate() == null) topic.setSolvedDate(java.time.LocalDate.now());
            int interval = (request.getRevisionIntervalDays() != null) ? request.getRevisionIntervalDays() : 7;
            topic.setRevisionIntervalDays(interval);
            topic.setNextRevisionDate(request.getNextRevisionDate() != null ? request.getNextRevisionDate() : java.time.LocalDate.now().plusDays(interval));
        }

        DsaTopic saved = dsaTopicRepository.save(topic);

        // Auto-generate notification
        notificationRepository.save(new com.example.demo.model.Notification(
            user,
            "DSA Question Added",
            String.format("Added practice topic: %s (%s).", saved.getTopicName(), saved.getDifficulty())
        ));

        return mapToResponse(saved);
    }

    public DsaTopicResponse updateTopic(Long userId, Long topicId, DsaTopicRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        DsaTopic topic = dsaTopicRepository.findByIdAndUserId(topicId, userId)
                .orElseThrow(() -> new RuntimeException("DSA Topic not found or unauthorized"));

        boolean oldSolved = topic.isSolved();

        topic.setTopicName(request.getTopicName());
        topic.setCategory(request.getCategory());
        topic.setDifficulty(request.getDifficulty());
        topic.setSolved(request.isSolved());
        topic.setSolvedDate(request.getSolvedDate());
        if (request.getPlatform() != null) topic.setPlatform(request.getPlatform());
        if (request.getProblemUrl() != null) topic.setProblemUrl(request.getProblemUrl());
        topic.setNotes(request.getNotes());
        topic.setPracticeCount(request.getPracticeCount());

        if (topic.isSolved()) {
            if (topic.getSolvedDate() == null) topic.setSolvedDate(java.time.LocalDate.now());
            if (topic.getNextRevisionDate() == null || (!oldSolved && topic.isSolved())) {
                int interval = (topic.getRevisionIntervalDays() != null) ? topic.getRevisionIntervalDays() : 7;
                topic.setRevisionIntervalDays(interval);
                topic.setNextRevisionDate(java.time.LocalDate.now().plusDays(interval));
            }
        }

        DsaTopic updated = dsaTopicRepository.save(topic);

        // Auto-generate notification if solved state changed to true
        if (!oldSolved && updated.isSolved()) {
            notificationRepository.save(new com.example.demo.model.Notification(
                user,
                "DSA Solved! 🎉",
                String.format("Congratulations! You solved '%s' in category %s. Next revision scheduled for %s.", 
                    updated.getTopicName(), updated.getCategory(), updated.getNextRevisionDate())
            ));
        }

        return mapToResponse(updated);
    }

    public List<DsaTopicResponse> getTopicsDueForRevision(Long userId) {
        return dsaTopicRepository.findByUserIdAndSolvedTrueAndNextRevisionDateLessThanEqualOrderByNextRevisionDateAsc(
                userId, java.time.LocalDate.now())
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public DsaTopicResponse reviewTopic(Long userId, Long topicId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        DsaTopic topic = dsaTopicRepository.findByIdAndUserId(topicId, userId)
                .orElseThrow(() -> new RuntimeException("DSA Topic not found"));

        // Spaced Repetition Progression: 7d -> 14d -> 30d -> 60d
        int currentInterval = (topic.getRevisionIntervalDays() != null) ? topic.getRevisionIntervalDays() : 7;
        int nextInterval;
        if (currentInterval <= 7) nextInterval = 14;
        else if (currentInterval <= 14) nextInterval = 30;
        else nextInterval = 60;

        topic.setPracticeCount(topic.getPracticeCount() + 1);
        topic.setRevisionIntervalDays(nextInterval);
        topic.setNextRevisionDate(java.time.LocalDate.now().plusDays(nextInterval));
        DsaTopic saved = dsaTopicRepository.save(topic);

        notificationRepository.save(new com.example.demo.model.Notification(
            user,
            "Revision Completed 🧠",
            String.format("Reviewed '%s'. Spaced repetition interval increased to %d days (Next: %s).",
                saved.getTopicName(), nextInterval, saved.getNextRevisionDate())
        ));

        return mapToResponse(saved);
    }

    public void deleteTopic(Long userId, Long topicId) {
        DsaTopic topic = dsaTopicRepository.findByIdAndUserId(topicId, userId)
                .orElseThrow(() -> new RuntimeException("DSA Topic not found or unauthorized"));

        dsaTopicRepository.delete(topic);
    }

    private DsaTopicResponse mapToResponse(DsaTopic topic) {
        DsaTopicResponse response = new DsaTopicResponse();
        response.setId(topic.getId());
        response.setTopicName(topic.getTopicName());
        response.setCategory(topic.getCategory());
        response.setDifficulty(topic.getDifficulty());
        response.setSolved(topic.isSolved());
        response.setSolvedDate(topic.getSolvedDate());
        response.setNextRevisionDate(topic.getNextRevisionDate());
        response.setRevisionIntervalDays(topic.getRevisionIntervalDays());
        
        boolean needsRevision = topic.isSolved() && topic.getNextRevisionDate() != null &&
                !topic.getNextRevisionDate().isAfter(java.time.LocalDate.now());
        response.setNeedsRevision(needsRevision);

        response.setPlatform(topic.getPlatform());
        response.setProblemUrl(topic.getProblemUrl());
        response.setNotes(topic.getNotes());
        response.setPracticeCount(topic.getPracticeCount());
        return response;
    }
}
