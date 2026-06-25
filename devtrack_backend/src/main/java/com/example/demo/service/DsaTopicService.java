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
        topic.setNotes(request.getNotes());
        topic.setPracticeCount(request.getPracticeCount());

        DsaTopic saved = dsaTopicRepository.save(topic);
        return mapToResponse(saved);
    }

    public DsaTopicResponse updateTopic(Long userId, Long topicId, DsaTopicRequest request) {
        DsaTopic topic = dsaTopicRepository.findByIdAndUserId(topicId, userId)
                .orElseThrow(() -> new RuntimeException("DSA Topic not found or unauthorized"));

        topic.setTopicName(request.getTopicName());
        topic.setCategory(request.getCategory());
        topic.setDifficulty(request.getDifficulty());
        topic.setSolved(request.isSolved());
        topic.setSolvedDate(request.getSolvedDate());
        topic.setNotes(request.getNotes());
        topic.setPracticeCount(request.getPracticeCount());

        DsaTopic updated = dsaTopicRepository.save(topic);
        return mapToResponse(updated);
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
        response.setNotes(topic.getNotes());
        response.setPracticeCount(topic.getPracticeCount());
        return response;
    }
}
