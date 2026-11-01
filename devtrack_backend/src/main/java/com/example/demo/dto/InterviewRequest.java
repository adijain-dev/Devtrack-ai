package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class InterviewRequest {

    @NotBlank
    private String topic; // e.g. "Arrays", "System Design", "Java OOP"

    private String difficulty; // "Easy", "Medium", "Hard"

    private String previousQuestion; // the question that was just asked (for context)

    private String userAnswer; // the user's answer to evaluate (null when asking next question)

    private Long sessionId; // optional session ID to attach rounds to
}
