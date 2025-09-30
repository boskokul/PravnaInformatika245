package com.example.pravna.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.example.pravna.model.LegalCaseFacts;
import com.example.pravna.model.DecisionResult;

import java.io.*;
import java.nio.file.Files;

@Service
@Slf4j
public class LegalCaseService {

    /**
     * Makes a decision based on legal case facts using rule-based reasoning
     *
     * @param facts The legal case facts
     * @return The decision/verdict as a string
     */
    public String makeDecision(LegalCaseFacts facts) throws IOException, InterruptedException {
        log.info("Processing decision for case: {} (defendant: {})",
                facts.getName(), facts.getDefendant());

        String factsPath = "./dr-device/facts.rdf";
        saveFactsToRdf(facts, factsPath);
        Thread.sleep(200);

        ProcessBuilder processBuilder = new ProcessBuilder("cmd.exe", "/c", "start.bat");
        processBuilder.directory(new File("./dr-device"));
        processBuilder.redirectErrorStream(true);

        Process process = processBuilder.start();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            reader.lines().forEach(line -> log.info("[DR-Device] {}", line));
        }

        int exitCode = process.waitFor();
        log.info("DR-Device finished with exit code: {}", exitCode);

        Thread.sleep(200);

        File exportFile = new File("./dr-device/export.rdf");
        if (!exportFile.exists()) {
            log.error("FAILED: export.rdf was not created!");
            return "Decision error: export.rdf not found for case " + facts.getName();
        }

        log.info("SUCCESS: export.rdf created! Size: {} bytes", exportFile.length());
        DecisionResult result = parseExportRdf(exportFile);

        ProcessBuilder cleanBuilder = new ProcessBuilder("cmd.exe", "/c", "clean.bat");
        cleanBuilder.directory(new File("./dr-device"));
        Process cleanProcess = cleanBuilder.start();
        cleanProcess.waitFor();
        log.info("Cleanup completed");

        return result.getSummary();
    }
    /**
     * Saves LegalCaseFacts to RDF XML file
     *
     * @param facts The legal case facts to save
     * @param filePath The full path to the output RDF file
     * @throws IOException if file writing fails
     */
    public void saveFactsToRdf(LegalCaseFacts facts, String filePath) throws IOException {
        log.info("Saving legal case facts to RDF file: {}", filePath);

        String rdfContent = convertToRdf(facts);

        File file = new File(filePath);
        file.getParentFile().mkdirs();

        try (FileWriter writer = new FileWriter(file)) {
            writer.write(rdfContent);
        }

        log.info("Successfully saved RDF file: {}", filePath);
    }

    /**
     * Converts LegalCaseFacts to RDF XML string
     */
    private String convertToRdf(LegalCaseFacts facts) {
        String caseId = facts.getCaseUri() != null ?
                facts.getCaseUri() :
                "http://informatika.ftn.uns.ac.rs/legal-case.rdf#" + sanitizeName(facts.getName());

        StringBuilder rdf = new StringBuilder();
        rdf.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n");
        rdf.append("<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n");
        rdf.append("        xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n");
        rdf.append("        xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"\n");
        rdf.append("        xmlns:lc=\"http://informatika.ftn.uns.ac.rs/legal-case.rdf#\">\n");
        rdf.append("    <lc:case rdf:about=\"").append(caseId).append("\">\n");
        rdf.append("    <lc:name>").append(escapeXml(facts.getName())).append("</lc:name>\n");
        rdf.append("    \n");
        rdf.append("    <!-- o optuzenom -->\n");
        rdf.append("    <lc:defendant>").append(escapeXml(facts.getDefendant())).append("</lc:defendant>\n");
        rdf.append("    <lc:optuzeni_davalac_mita>").append(toYesNo(facts.getOptuzenoDavalacMita())).append("</lc:optuzeni_davalac_mita>\n");
        rdf.append("\t\n");
        rdf.append("\t<lc:optuzeni_primalac_mita>").append(toYesNo(facts.getOptuzenoPrimalacMita())).append("</lc:optuzeni_primalac_mita>\n");
        rdf.append("    <lc:optuzeni_sluzbeno_lice>").append(toYesNo(facts.getOptuzeniSluzbenoLice())).append("</lc:optuzeni_sluzbeno_lice>\n");
        rdf.append("    <!-- o samoj radnji i predmetu mita (da li je radio nesto zabranjeno ili nije izvrsio obaveznu radnju) -->\n");
        rdf.append("    <lc:radnja_nezakonita_ili_neizvrsena>").append(toYesNo(facts.getRadnjaNezakonitaIliNeizvrsena())).append("</lc:radnja_nezakonita_ili_neizvrsena>\t\n");
        rdf.append("    <lc:mito_vezan_za_kazneni_postupak>").append(toYesNo(facts.getMitoVezanZaKazneniPostupak())).append("</lc:mito_vezan_za_kazneni_postupak>\n");
        rdf.append("    <!-- da li je trazio mito nakon sto je vec uradjena nelegalna ili neizvrsena obavezna radnja -->\n");
        rdf.append("    <lc:trazio_mito_nakon>").append(toYesNo(facts.getTrazioMitoNakon())).append("</lc:trazio_mito_nakon>\n");
        rdf.append("    <!-- da li ga je sam prijavio pre otkrivanja -->\n");
        rdf.append("    <lc:prijavio_mito>").append(toYesNo(facts.getPrijavioMito())).append("</lc:prijavio_mito>\n");
        rdf.append("    \n");
        rdf.append("    </lc:case>\n");
        rdf.append("</rdf:RDF>");

        return rdf.toString();
    }

    /**
     * Converts Boolean to yes/no string
     */
    private String toYesNo(Boolean value) {
        return value != null && value ? "yes" : "no";
    }

    /**
     * Escapes XML special characters
     */
    private String escapeXml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    /**
     * Sanitizes name for use in URI
     */
    private String sanitizeName(String name) {
        return name.replaceAll("[^a-zA-Z0-9]", "");
    }

    /**
     * Parses DR-Device export.rdf output and extracts proven conclusions
     *
     * @param file Path to the export.rdf file
     * @return DecisionResult containing proven facts and sentence values
     * @throws IOException if file reading fails
     */
    public DecisionResult parseExportRdf(File file) throws IOException {
        log.info("Parsing DR-Device export file: {}", file.toPath());


        String content = new String(Files.readAllBytes(file.toPath()));

        DecisionResult result = new DecisionResult();

        // Extract all defeasibly-proven-positive conclusions
        String[] lines = content.split("\n");
        String currentClass = null;
        String currentDefendant = null;
        String currentValue = null;
        boolean isProvenPositive = false;

        for (String line : lines) {
            line = line.trim();

            // Check for class declarations (e.g., <export:taken_bribe_lv1 rdf:about=...)
            if (line.matches("<export:[^>]+rdf:about=.*")) {
                // Extract class name
                int colonIndex = line.indexOf(":");
                int spaceIndex = line.indexOf(" ", colonIndex);
                if (colonIndex > 0 && spaceIndex > colonIndex) {
                    currentClass = line.substring(colonIndex + 1, spaceIndex);
                }
                // Reset for new object
                currentDefendant = null;
                currentValue = null;
                isProvenPositive = false;
            }

            // Extract defendant
            if (line.contains("<export:defendant>")) {
                currentDefendant = extractTagValue(line, "defendant");
            }

            // Extract value (for sentences)
            if (line.contains("<export:value>")) {
                currentValue = extractTagValue(line, "value");
            }

            // Check if proven positive
            if (line.contains("<defeasible:truthStatus>defeasibly-proven-positive</defeasible:truthStatus>")) {
                isProvenPositive = true;
            }

            // When closing tag is found, add to results if proven positive
            if (line.startsWith("</export:") && isProvenPositive && currentClass != null) {
                if (currentClass.equals("zatvor_max") && currentValue != null) {
                    result.setMaxSentenceMonths(Integer.parseInt(currentValue));
                } else if (currentClass.equals("zatvor_min") && currentValue != null) {
                    result.setMinSentenceMonths(Integer.parseInt(currentValue));
                } else if (currentDefendant != null) {
                    result.addProvenConclusion(currentClass, currentDefendant);
                }
            }
        }

        log.info("Parsed export file. Found {} proven conclusions", result.getProvenConclusions().size());
        return result;
    }

    /**
     * Helper method to extract value from XML tag
     */
    private String extractTagValue(String line, String tagName) {
        String openTag = "<export:" + tagName + ">";
        String closeTag = "</export:" + tagName + ">";

        int startIndex = line.indexOf(openTag);
        int endIndex = line.indexOf(closeTag);

        if (startIndex >= 0 && endIndex > startIndex) {
            return line.substring(startIndex + openTag.length(), endIndex);
        }
        return null;
    }
}