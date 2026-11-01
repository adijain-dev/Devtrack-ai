package com.example.demo.service;

import com.example.demo.dto.*;
import com.example.demo.model.*;
import com.example.demo.repository.MockInterviewRoundRepository;
import com.example.demo.repository.MockInterviewSessionRepository;
import com.example.demo.repository.ResumeHistoryRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AiSessionService {

    @Autowired
    private ResumeHistoryRepository resumeHistoryRepository;

    @Autowired
    private MockInterviewSessionRepository interviewSessionRepository;

    @Autowired
    private MockInterviewRoundRepository interviewRoundRepository;

    @Autowired
    private UserRepository userRepository;

    // ── Resume History ─────────────────────────────────────────────────────────

    @Transactional
    public ResumeHistoryResponse saveResumeHistory(Long userId, String role, String experience, String context, String bullets) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));

        ResumeHistory history = ResumeHistory.builder()
                .user(user)
                .role(role)
                .experience(experience)
                .additionalContext(context)
                .generatedBullets(bullets)
                .createdAt(LocalDateTime.now())
                .build();

        ResumeHistory saved = resumeHistoryRepository.save(history);
        return mapToResumeResponse(saved);
    }

    public List<ResumeHistoryResponse> getResumeHistories(Long userId) {
        return resumeHistoryRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::mapToResumeResponse)
                .collect(Collectors.toList());
    }

    public ResumeHistory getResumeHistoryEntity(Long userId, Long id) {
        return resumeHistoryRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new RuntimeException("Resume history not found: " + id));
    }

    @Transactional
    public void deleteResumeHistory(Long userId, Long id) {
        ResumeHistory item = getResumeHistoryEntity(userId, id);
        resumeHistoryRepository.delete(item);
    }

    private ResumeHistoryResponse mapToResumeResponse(ResumeHistory entity) {
        return ResumeHistoryResponse.builder()
                .id(entity.getId())
                .role(entity.getRole())
                .experience(entity.getExperience())
                .additionalContext(entity.getAdditionalContext())
                .generatedBullets(entity.getGeneratedBullets())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    // ── Mock Interview History ─────────────────────────────────────────────────

    @Transactional
    public MockInterviewSession startInterviewSession(Long userId, String topic, String difficulty) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));

        MockInterviewSession session = MockInterviewSession.builder()
                .user(user)
                .topic(topic)
                .difficulty(difficulty != null ? difficulty : "Medium")
                .createdAt(LocalDateTime.now())
                .build();

        return interviewSessionRepository.save(session);
    }

    @Transactional
    public MockInterviewRound saveInterviewRound(Long userId, Long sessionId, String question, String userAnswer, String feedback) {
        MockInterviewSession session = interviewSessionRepository.findByIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new RuntimeException("Interview session not found: " + sessionId));

        int nextRound = session.getRounds().size() + 1;
        MockInterviewRound round = MockInterviewRound.builder()
                .session(session)
                .roundNumber(nextRound)
                .question(question)
                .userAnswer(userAnswer)
                .feedback(feedback)
                .answeredAt(LocalDateTime.now())
                .build();

        return interviewRoundRepository.save(round);
    }

    public List<InterviewSessionResponse> getInterviewSessions(Long userId) {
        return interviewSessionRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::mapToSessionResponse)
                .collect(Collectors.toList());
    }

    public InterviewSessionResponse getInterviewSession(Long userId, Long sessionId) {
        MockInterviewSession session = interviewSessionRepository.findByIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new RuntimeException("Interview session not found: " + sessionId));
        return mapToSessionResponse(session);
    }

    @Transactional
    public void deleteInterviewSession(Long userId, Long sessionId) {
        MockInterviewSession session = interviewSessionRepository.findByIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new RuntimeException("Interview session not found: " + sessionId));
        interviewSessionRepository.delete(session);
    }

    private InterviewSessionResponse mapToSessionResponse(MockInterviewSession session) {
        List<InterviewRoundDto> roundDtos = session.getRounds().stream()
                .map(r -> InterviewRoundDto.builder()
                        .id(r.getId())
                        .roundNumber(r.getRoundNumber())
                        .question(r.getQuestion())
                        .userAnswer(r.getUserAnswer())
                        .feedback(r.getFeedback())
                        .answeredAt(r.getAnsweredAt())
                        .build())
                .collect(Collectors.toList());

        return InterviewSessionResponse.builder()
                .id(session.getId())
                .topic(session.getTopic())
                .difficulty(session.getDifficulty())
                .createdAt(session.getCreatedAt())
                .rounds(roundDtos)
                .build();
    }
}
