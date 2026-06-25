package com.example.demo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Entity
@Table(name = "internships")
@Data
@NoArgsConstructor
public class Internship {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @NotBlank
    private String companyName;

    @NotBlank
    private String role;

    private String location;
    
    private String salary;
    
    private String jobLink;

    @Enumerated(EnumType.STRING)
    @NotNull
    private ApplicationStatus status = ApplicationStatus.APPLIED;

    private LocalDate appliedDate;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
