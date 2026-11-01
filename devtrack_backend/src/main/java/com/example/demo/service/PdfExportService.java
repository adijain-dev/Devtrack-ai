package com.example.demo.service;

import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.draw.LineSeparator;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
public class PdfExportService {

    public byte[] generateResumePdf(String candidateName, String candidateEmail, String role, String experience, String bullets) {
        Document document = new Document(PageSize.A4, 40, 40, 50, 40);
        ByteArrayOutputStream out = new ByteArrayOutputStream();

        try {
            PdfWriter.getInstance(document, out);
            document.open();

            // Fonts
            Font nameFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, new Color(26, 54, 93)); // Navy
            Font subHeaderFont = FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 11, new Color(74, 85, 104)); // Slate
            Font sectionTitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, new Color(43, 108, 176)); // Blue
            Font bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10.5f, new Color(45, 55, 72)); // Charcoal
            Font boldBodyFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10.5f, new Color(26, 32, 44));
            Font footerFont = FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 8.5f, new Color(160, 174, 192));

            // Candidate Name & Contact
            String displayName = (candidateName != null && !candidateName.isBlank()) ? candidateName : "Software Developer Candidate";
            Paragraph namePara = new Paragraph(displayName, nameFont);
            namePara.setAlignment(Element.ALIGN_LEFT);
            namePara.setSpacingAfter(4);
            document.add(namePara);

            String contactInfo = (candidateEmail != null && !candidateEmail.isBlank()) 
                    ? candidateEmail + "  |  DevTrack AI Career Portfolio"
                    : "DevTrack AI Career Portfolio  |  Generated " + LocalDate.now().format(DateTimeFormatter.ISO_DATE);
            Paragraph contactPara = new Paragraph(contactInfo, subHeaderFont);
            contactPara.setSpacingAfter(10);
            document.add(contactPara);

            // Divider Line
            LineSeparator separator = new LineSeparator();
            separator.setLineColor(new Color(226, 232, 240));
            separator.setLineWidth(1.2f);
            document.add(separator);

            // Section: Target Role & Overview
            document.add(new Paragraph(" ", FontFactory.getFont(FontFactory.HELVETICA, 6)));
            Paragraph roleTitle = new Paragraph("TARGET POSITION", sectionTitleFont);
            roleTitle.setSpacingAfter(4);
            document.add(roleTitle);

            Paragraph rolePara = new Paragraph(role != null ? role : "Engineering Role", boldBodyFont);
            rolePara.setSpacingAfter(6);
            document.add(rolePara);

            if (experience != null && !experience.isBlank()) {
                Paragraph expSummary = new Paragraph("Scope of Work: " + experience, bodyFont);
                expSummary.setSpacingAfter(12);
                document.add(expSummary);
            }

            // Section: Key Bullet Points & Impact
            Paragraph bulletsTitle = new Paragraph("EXPERIENCE & KEY ACHIEVEMENTS", sectionTitleFont);
            bulletsTitle.setSpacingBefore(8);
            bulletsTitle.setSpacingAfter(8);
            document.add(bulletsTitle);

            if (bullets != null && !bullets.isBlank()) {
                String[] lines = bullets.split("\\r?\\n");
                for (String rawLine : lines) {
                    String line = rawLine.trim();
                    if (line.isEmpty()) continue;

                    // Clean leading bullets/dashes/numbers if present
                    if (line.startsWith("•") || line.startsWith("-") || line.startsWith("*")) {
                        line = line.substring(1).trim();
                    } else if (line.matches("^\\d+\\.\\s*.*")) {
                        line = line.replaceFirst("^\\d+\\.\\s*", "").trim();
                    }

                    Paragraph bulletPara = new Paragraph("•  " + line, bodyFont);
                    bulletPara.setIndentationLeft(12);
                    bulletPara.setSpacingAfter(6);
                    bulletPara.setLeading(14);
                    document.add(bulletPara);
                }
            }

            // Footer / Metadata
            document.add(new Paragraph(" ", FontFactory.getFont(FontFactory.HELVETICA, 16)));
            Paragraph footer = new Paragraph("Document produced via DevTrack AI Resume Intelligence Suite", footerFont);
            footer.setAlignment(Element.ALIGN_CENTER);
            document.add(footer);

            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate Resume PDF: " + e.getMessage(), e);
        }

        return out.toByteArray();
    }
}
