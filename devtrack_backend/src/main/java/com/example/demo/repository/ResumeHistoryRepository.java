package com.example.demo.repository;

import com.example.demo.model.ResumeHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ResumeHistoryRepository extends JpaRepository<ResumeHistory, Long> {
    List<ResumeHistory> findByUserIdOrderByCreatedAtDesc(Long userId);
    Optional<ResumeHistory> findByIdAndUserId(Long id, Long userId);
}
