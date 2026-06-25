package com.example.demo.repository;

import com.example.demo.model.Internship;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InternshipRepository extends JpaRepository<Internship, Long> {
    List<Internship> findByUserId(Long userId);
    Optional<Internship> findByIdAndUserId(Long id, Long userId);
}
