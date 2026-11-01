package com.example.demo.repository;

import com.example.demo.model.DsaTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DsaTopicRepository extends JpaRepository<DsaTopic, Long> {
    List<DsaTopic> findByUserId(Long userId);
    Optional<DsaTopic> findByIdAndUserId(Long id, Long userId);
    List<DsaTopic> findByUserIdAndSolvedTrueAndNextRevisionDateLessThanEqualOrderByNextRevisionDateAsc(Long userId, java.time.LocalDate date);
    Optional<DsaTopic> findByUserIdAndTopicNameIgnoreCase(Long userId, String topicName);
}
