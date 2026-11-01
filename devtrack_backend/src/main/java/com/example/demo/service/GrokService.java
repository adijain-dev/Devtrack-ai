package com.example.demo.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

/**
 * Service responsible for all Grok (xAI) API communication.
 * 
 * Grok's API is standard OpenAI-compatible.
 * You send a POST request containing:
 * - Authorization: Bearer <api-key>
 * - Body: {
 *     "model": "grok-2-1212",
 *     "messages": [{"role": "user", "content": "your prompt"}],
 *     "temperature": 0.7
 *   }
 */
@Service
public class GrokService {

    @Value("${app.grok.api-key}")
    private String apiKey;

    @Value("${app.grok.api-url}")
    private String apiUrl;

    @Value("${app.grok.model}")
    private String modelName;

    private final RestTemplate restTemplate = new RestTemplate();

    // ── Resume Bullets ────────────────────────────────────────────────

    public String generateResumeBullets(String role, String experience, String additionalContext) {
        String prompt = String.format(
            """
            You are a professional resume writer. Generate exactly 5 strong, concise resume bullet points
            for a student applying for the following role.

            Role: %s
            Experience / Work Done: %s
            Additional Context: %s

            Rules:
            - Start each bullet with a strong action verb (e.g. Developed, Built, Designed, Optimized)
            - Include measurable impact where possible (e.g. "reduced latency by 30%%")
            - Keep each bullet to one line
            - Use industry-standard language
            - Format as a numbered list 1. to 5.
            """,
            role,
            experience,
            additionalContext != null ? additionalContext : "None"
        );

        return callGrok(prompt);
    }

    // ── Mock Interview — Ask Question ─────────────────────────────────

    public String generateInterviewQuestion(String topic, String difficulty) {
        String prompt = String.format(
            """
            You are a technical interviewer at a top tech company.
            Ask ONE clear interview question on the topic below.

            Topic: %s
            Difficulty: %s

            Rules:
            - Ask only ONE question
            - Make it realistic for a student interview
            - Do NOT answer the question yourself
            - Just ask the question directly without any preamble
            """,
            topic,
            difficulty != null ? difficulty : "Medium"
        );

        return callGrok(prompt);
    }

    // ── Mock Interview — Evaluate Answer ──────────────────────────────

    public String evaluateAnswer(String question, String userAnswer, String topic) {
        String prompt = String.format(
            """
            You are a technical interviewer giving feedback to a student.

            Interview Question: %s
            Student's Answer: %s
            Topic: %s

            Provide structured feedback in exactly this format:
            ✅ What was good: (2-3 sentences)
            ❌ What was missing or incorrect: (2-3 sentences)
            💡 Ideal answer summary: (3-4 sentences with the key points)
            ⭐ Score: X/10

            Be constructive, encouraging, and specific.
            """,
            question,
            userAnswer,
            topic
        );

        return callGrok(prompt);
    }

    // ── Core Grok API Call ─────────────────────────────────────────

    private String callGrok(String prompt) {
        // Build the OpenAI-compatible Request payload:
        // {
        //   "model": "grok-2-1212",
        //   "messages": [{"role": "user", "content": "..."}],
        //   "temperature": 0.7
        // }
        Map<String, Object> message = new HashMap<>();
        message.put("role", "user");
        message.put("content", prompt);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", modelName);
        requestBody.put("messages", List.of(message));
        requestBody.put("temperature", 0.7);

        // Set HTTP headers
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + apiKey);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(apiUrl, entity, Map.class);

            // Parse response (OpenAI compatible format):
            // response.choices[0].message.content
            Map<String, Object> body = response.getBody();
            if (body != null) {
                List<Map<String, Object>> choices = (List<Map<String, Object>>) body.get("choices");
                if (choices != null && !choices.isEmpty()) {
                    Map<String, Object> choice = choices.get(0);
                    Map<String, Object> messageMap = (Map<String, Object>) choice.get("message");
                    if (messageMap != null) {
                        return (String) messageMap.get("content");
                    }
                }
            }
            return "AI response could not be parsed. Please try again.";
        } catch (Exception e) {
            return "AI service error: " + e.getMessage();
        }
    }
}
