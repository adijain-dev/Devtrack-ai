package com.example.demo.repository;

import com.example.demo.model.MockInterviewSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MockInterviewSessionRepository extends JpaRepository<MockInterviewSession, Long> {
    List<MockInterviewSession> findByUserIdOrderByCreatedAtDesc(Long userId);
    Optional<MockInterviewSession> findByIdAndUserId(Long id, Long userId);
}
