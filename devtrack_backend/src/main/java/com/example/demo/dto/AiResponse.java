package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiResponse {
    private String content; // The AI-generated text
    private Long sessionId; // Optional session ID for interviews
    private Long historyId; // Optional history ID for resumes

    public AiResponse(String content) {
        this.content = content;
    }
}
