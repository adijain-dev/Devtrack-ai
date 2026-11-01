package com.example.demo.repository;

import com.example.demo.model.MockInterviewRound;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MockInterviewRoundRepository extends JpaRepository<MockInterviewRound, Long> {
    List<MockInterviewRound> findBySessionIdOrderByRoundNumberAsc(Long sessionId);
}
