package com.example.demo.controller;

import com.example.demo.dto.*;
import com.example.demo.model.MockInterviewSession;
import com.example.demo.model.ResumeHistory;
import com.example.demo.security.UserDetailsImpl;
import com.example.demo.service.AiSessionService;
import com.example.demo.service.GrokService;
import com.example.demo.service.PdfExportService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    @Autowired
    private GrokService grokService;

    @Autowired
    private AiSessionService aiSessionService;

    @Autowired
    private PdfExportService pdfExportService;

    /**
     * Generates resume bullet points and automatically saves to user's history.
     */
    @PostMapping("/resume-bullets")
    public ResponseEntity<AiResponse> generateResumeBullets(
            @Valid @RequestBody AiRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        String result = grokService.generateResumeBullets(
            request.getRole(),
            request.getExperience(),
            request.getAdditionalContext()
        );

        Long historyId = null;
        if (userDetails != null) {
            ResumeHistoryResponse saved = aiSessionService.saveResumeHistory(
                userDetails.getId(),
                request.getRole(),
                request.getExperience(),
                request.getAdditionalContext(),
                result
            );
            historyId = saved.getId();
        }

        return ResponseEntity.ok(AiResponse.builder()
                .content(result)
                .historyId(historyId)
                .build());
    }

    /**
     * Get all saved resume bullet histories for the authenticated user.
     */
    @GetMapping("/resume-history")
    public ResponseEntity<List<ResumeHistoryResponse>> getResumeHistory(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(aiSessionService.getResumeHistories(userDetails.getId()));
    }

    /**
     * Delete a saved resume bullet history.
     */
    @DeleteMapping("/resume-history/{id}")
    public ResponseEntity<?> deleteResumeHistory(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        aiSessionService.deleteResumeHistory(userDetails.getId(), id);
        return ResponseEntity.ok(new MessageResponse("Resume history deleted successfully."));
    }

    /**
     * Exports arbitrary resume bullets to formatted PDF bytes.
     */
    @PostMapping("/resume/export-pdf")
    public ResponseEntity<byte[]> exportResumePdf(
            @RequestBody ExportResumePdfRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        String name = request.getCandidateName();
        String email = request.getCandidateEmail();
        if ((name == null || name.isBlank()) && userDetails != null) {
            name = userDetails.getUsername();
            email = userDetails.getEmail();
        }

        byte[] pdfBytes = pdfExportService.generateResumePdf(
            name,
            email,
            request.getRole(),
            request.getExperience(),
            request.getBullets()
        );

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"resume.pdf\"")
                .body(pdfBytes);
    }

    /**
     * Download PDF for a specific saved resume history.
     */
    @GetMapping("/resume-history/{id}/pdf")
    public ResponseEntity<byte[]> downloadResumeHistoryPdf(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        ResumeHistory history = aiSessionService.getResumeHistoryEntity(userDetails.getId(), id);
        byte[] pdfBytes = pdfExportService.generateResumePdf(
            userDetails.getUsername(),
            userDetails.getEmail(),
            history.getRole(),
            history.getExperience(),
            history.getGeneratedBullets()
        );

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"resume_" + id + ".pdf\"")
                .body(pdfBytes);
    }

    /**
     * Starts a new Mock Interview session, persists it to DB, and returns question + sessionId.
     */
    @PostMapping("/interview/start")
    public ResponseEntity<AiResponse> startInterviewSession(
            @Valid @RequestBody InterviewRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        MockInterviewSession session = aiSessionService.startInterviewSession(
            userDetails.getId(),
            request.getTopic(),
            request.getDifficulty()
        );

        String question = grokService.generateInterviewQuestion(
            request.getTopic(),
            request.getDifficulty()
        );

        return ResponseEntity.ok(AiResponse.builder()
                .content(question)
                .sessionId(session.getId())
                .build());
    }

    /**
     * Fallback or legacy: returns one interview question without session.
     */
    @PostMapping("/interview/question")
    public ResponseEntity<AiResponse> getInterviewQuestion(@Valid @RequestBody InterviewRequest request) {
        String result = grokService.generateInterviewQuestion(
            request.getTopic(),
            request.getDifficulty()
        );
        return ResponseEntity.ok(new AiResponse(result));
    }

    /**
     * Evaluates answer and attaches round to the database session if sessionId is provided.
     */
    @PostMapping("/interview/evaluate")
    public ResponseEntity<AiResponse> evaluateAnswer(
            @RequestBody InterviewRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        String feedback = grokService.evaluateAnswer(
            request.getPreviousQuestion(),
            request.getUserAnswer(),
            request.getTopic()
        );

        if (userDetails != null && request.getSessionId() != null) {
            aiSessionService.saveInterviewRound(
                userDetails.getId(),
                request.getSessionId(),
                request.getPreviousQuestion(),
                request.getUserAnswer(),
                feedback
            );
        }

        return ResponseEntity.ok(AiResponse.builder()
                .content(feedback)
                .sessionId(request.getSessionId())
                .build());
    }

    /**
     * Fetch user's mock interview session history.
     */
    @GetMapping("/interview-history")
    public ResponseEntity<List<InterviewSessionResponse>> getInterviewHistory(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(aiSessionService.getInterviewSessions(userDetails.getId()));
    }

    /**
     * Fetch details of a specific past mock interview session.
     */
    @GetMapping("/interview-history/{id}")
    public ResponseEntity<InterviewSessionResponse> getInterviewSession(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(aiSessionService.getInterviewSession(userDetails.getId(), id));
    }

    /**
     * Delete an interview session from history.
     */
    @DeleteMapping("/interview-history/{id}")
    public ResponseEntity<?> deleteInterviewSession(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        aiSessionService.deleteInterviewSession(userDetails.getId(), id);
        return ResponseEntity.ok(new MessageResponse("Interview session deleted successfully."));
    }
}
