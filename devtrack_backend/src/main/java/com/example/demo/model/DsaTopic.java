package com.example.demo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Entity
@Table(name = "dsa_topics")
@Data
@NoArgsConstructor
public class DsaTopic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @NotBlank
    private String topicName;

    @Enumerated(EnumType.STRING)
    @NotNull
    private DsaCategory category;

    @Enumerated(EnumType.STRING)
    @NotNull
    private DsaDifficulty difficulty;

    private boolean solved = false;

    private LocalDate solvedDate;

    @Column(columnDefinition = "TEXT")
    private String notes;

    private int practiceCount = 0;
}
