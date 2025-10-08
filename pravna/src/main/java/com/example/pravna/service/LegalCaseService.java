package com.example.pravna.service;

import com.example.pravna.model.LegalDecisionResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.example.pravna.model.LegalCaseFacts;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
@Slf4j
public class LegalCaseService {

    /**
     * Makes a decision based on legal case facts using rule-based reasoning
     *
     * @param facts The legal case facts
     * @return The decision/verdict as a string
     */
    public LegalDecisionResult makeDecision(LegalCaseFacts facts) throws IOException, InterruptedException {
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
            return null;
        }

        log.info("SUCCESS: export.rdf created! Size: {} bytes", exportFile.length());
        LegalDecisionResult result = parseExportRdf(exportFile);
        result.setDefendantName(facts.getDefendant());
        result.setCaseNumber(facts.getName());
        result.setDecision(result.getDecisionString());
        result.setExplanation(result.getExplanationString());

        ProcessBuilder cleanBuilder = new ProcessBuilder("cmd.exe", "/c", "clean.bat");
        cleanBuilder.directory(new File("./dr-device"));
        Process cleanProcess = cleanBuilder.start();
        cleanProcess.waitFor();
        log.info("Cleanup completed");

        return result;
    }

    public static void saveAkomaNtosoToFile(LegalDecisionResult result, String fileName) throws IOException {
        String xml = generateAkomaNtoso(result);

        String path = Paths.get(System.getProperty("user.dir"), "data", "verdicts", fileName).toString();

        Files.writeString(Paths.get(path), xml);
    }

    /**
     * Saves HTML to file
     */
    public static void saveHtmlToFile(LegalDecisionResult result, String fileName) throws IOException {
        String html = generateHtml(result);

        String path = Paths.get(System.getProperty("user.dir"), "data", "verdicts", "html", fileName).toString();

        Files.writeString(Paths.get(path), html);

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
    public LegalDecisionResult parseExportRdf(File file) throws IOException {
        log.info("Parsing DR-Device export file: {}", file.toPath());


        String content = new String(Files.readAllBytes(file.toPath()));

        LegalDecisionResult result = new LegalDecisionResult();

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
                    result.setLawFromViolation(currentClass);
                }
            }
        }

//        log.info("Parsed export file. Found {} proven conclusions", result.getProvenConclusions().size());
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

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DISPLAY_DATE_FORMATTER = DateTimeFormatter.ofPattern("dd. MMMM yyyy");

    /**
     * Generates Akoma Ntoso XML from LegalDecisionResult
     */
    public static String generateAkomaNtoso(LegalDecisionResult result) {
        LocalDate currentDate = LocalDate.now();
        String formattedDate = currentDate.format(DATE_FORMATTER);

        StringBuilder xml = new StringBuilder();
        xml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        xml.append("<akomaNtoso xmlns=\"http://docs.oasis-open.org/legaldocml/ns/akn/3.0/WD17\" ");
        xml.append("xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ");
        xml.append("xsi:schemaLocation=\"http://docs.oasis-open.org/legaldocml/ns/akn/3.0/WD17 ../../schemas/akomantoso30.xsd \">\n");
        xml.append("    <judgement>\n");

        // Meta section
        xml.append("        <meta>\n");
        xml.append("            <identification source=\"#court\">\n");
        xml.append("                <FRBRWork>\n");
        xml.append("                    <FRBRauthor>\n");
        xml.append("                        ").append(escapeXml(result.getCourtName())).append("\n");
        xml.append("                    </FRBRauthor>\n");
        xml.append("                    <FRBRdate date=\"").append(formattedDate).append("\"> \n");
        xml.append("                        ").append(formattedDate).append("\n");
        xml.append("                    </FRBRdate>\n");
        xml.append("                    <FRBRtitle>                      \n");
        xml.append("                        ").append(escapeXml(result.getCaseNumber())).append("\n");
        xml.append("                    </FRBRtitle>\n");
        xml.append("                    <FRBRcountry>\n");
        xml.append("                        ").append(escapeXml(result.getCountryCode())).append("\n");
        xml.append("                    </FRBRcountry>\n");
        xml.append("                </FRBRWork>\n");
        xml.append("            </identification>\n");
        xml.append("            <references>\n");
        xml.append("                <TLCOrganization eId=\"court\" href=\"/ontology/organization/court\" showAs=\"").append(escapeXml(result.getCourtName())).append("\" />\n");
        xml.append("                <TLCPerson eId=\"judge\" href=\"/ontology/person/judge\" showAs=\"").append(escapeXml(result.getJudgeName())).append("\" />\n");
        xml.append("                <TLCPerson eId=\"clerk\" href=\"/ontology/person/clerk\" showAs=\"").append(escapeXml(result.getClerkName())).append("\" />\n");
        xml.append("                <TLCPerson eId=\"defendant\" href=\"/ontology/person/defendant\" showAs=\"").append(escapeXml(result.getDefendantName())).append("\" />\n");
        xml.append("                <TLCRole eId=\"judge\" href=\"/ontology/role/judge\" showAs=\"Judge\" />\n");
        xml.append("                <TLCRole eId=\"clerk\" href=\"/ontology/role/clerk\" showAs=\"Clerk\" />\n");
        xml.append("                <TLCRole eId=\"defendant\" href=\"/ontology/role/defendant\" showAs=\"Defendant\" />\n");
        xml.append("            </references> \n");
        xml.append("        </meta>\n");

        // Judgment Body
        xml.append("        <judgmentBody>\n");

        // Introduction
        xml.append("        <introduction>\n");
        xml.append("            <p class=\"subtitle\">\n");
        xml.append("                        U IME DRŽAVE\n");
        xml.append("            </p>\n");
        xml.append("            <p>\n");
        xml.append("                <organization id=\"court\" refersTo=\"#court\">").append(escapeXml(result.getCourtName())).append("</organization> ");
        xml.append("Sudija <party id=\"judge\" refersTo=\"#judge\" as=\"#judge\">").append(escapeXml(result.getJudgeName())).append(",</party> ");
        xml.append("uz učešće <party id=\"clerk\" refersTo=\"#clerk\" as=\"#clerk\">").append(escapeXml(result.getClerkName())).append("</party> ");
        xml.append("kao zapisničara, u krivičnom predmetu okrivljenog <party id=\"defendant\" refersTo=\"#defendant\" as=\"#defendant\">").append(escapeXml(result.getDefendantName())).append(",</party> ");
        xml.append("zbog krivičnog djela ").append("<ref href=\"/krivicni#art_").append(result.getLaw_article()).append("_para_").append(result.getLaw_paragraph()).append("\">čl.").append(result.getLaw_article()).append(" st.").append(result.getLaw_paragraph()).append(" Krivičnog zakonika</ref>").append(", ");
        xml.append("donio je dana ").append(formattedDate).append(" godine\n");
        xml.append("            </p>\n");
        xml.append("        </introduction>\n");

        // Background
        xml.append("        <background>\n");
        xml.append("            <p class=\"subtitle\">\n");
        xml.append("                            PRESUDU\n");
        xml.append("            </p>\n");
        xml.append("            <p>\n");
        xml.append("                Okrivljeni <party id=\"defendant\" refersTo=\"#defendant\" as=\"#defendant\">").append(escapeXml(result.getDefendantName())).append("</party> ").append(escapeXml(result.getDefendantBackground())).append("\n");
        xml.append("            </p>\n");
        xml.append("        </background>\n");

        // Decision
        xml.append("        <decision>\n");
        if(result.getSentence() > 0){
            xml.append("            <p class=\"subtitle\">\n");
            xml.append("                Kriv je\n");
            xml.append("            </p>\n");
            xml.append("            <p class=\"subtitle\">\n");
            xml.append("                        ").append(escapeXml(result.getDecisionString())).append("\n");
            xml.append("            </p>\n");
            xml.append("            <p class=\"subtitle\">\n");
            xml.append("                OSUĐUJE\n");
            xml.append("            </p>\n");
            xml.append("            <p>\n");
            xml.append("                ").append(escapeXml(result.getSentenceString())).append("\n");
            xml.append("            </p>\n");
        } else{
            xml.append("            <p class=\"subtitle\">\n");
            xml.append("                SE OSLOBAĐA\n");
            xml.append("            </p>\n");
            xml.append("            <p class=\"subtitle\">\n");
            xml.append("                        ").append(escapeXml(result.getDecisionString())).append("\n");
            xml.append("            </p>\n");
        }
        xml.append("        </decision>\n");

        // Decision
        xml.append("        <arguments>\n");
        xml.append("            <p class=\"subtitle\">\n");
        xml.append("                OBRAZLOŽENJE\n");
        xml.append("            </p>\n");
        xml.append("            <p>\n");
        xml.append("                ").append(escapeXml(result.getExplanationString())).append("\n");
        xml.append("            </p>\n");
        xml.append("        </arguments>\n");

        xml.append("        </judgmentBody>\n");

        // Conclusion
        xml.append("        <conclusion>\n");
        xml.append("            <p class=\"subtitle\">\n");
        xml.append("                        ZAPISNIČARKA SUTKINJA\n");
        xml.append("            </p>\n");
        xml.append("            <p>\n");
        xml.append("                <party id=\"clerk\" refersTo=\"#clerk\" as=\"#clerk\">").append(escapeXml(result.getClerkName())).append(", s.r.</party> ");
        xml.append("<party id=\"judge\" refersTo=\"#judge\" as=\"#judge\">").append(escapeXml(result.getJudgeName())).append(", s.r.</party>\n");
        xml.append("            </p>\n");
        xml.append("        </conclusion>\n");

        xml.append("    </judgement>\n");
        xml.append("</akomaNtoso>");

        return xml.toString();
    }

    /**
     * Generates HTML from LegalDecisionResult
     */
    public static String generateHtml(LegalDecisionResult result) {
        LocalDate currentDate = LocalDate.now();
        String displayDate = currentDate.format(DateTimeFormatter.ofPattern("dd. MMMM yyyy"));

        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>\n");
        html.append("<html lang='sr'>\n");
        html.append("<head>\n");
        html.append("    <meta charset='UTF-8'>\n");
        html.append("    <meta name='viewport' content='width=device-width, initial-scale=1.0'>\n");
        html.append("    <title>").append(escapeHtml(result.getCaseNumber())).append("</title>\n");
        html.append("    <style>\n");
        html.append("        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 20px; }\n");
        html.append("        h1, h4 { text-align: center; margin: 0; }\n");
        html.append("        h4 { color: gray; }\n");
        html.append("        h2 { color: navy; text-align: left; margin-top: 20px; }\n");
        html.append("        p { text-align: justify; }\n");
        html.append("        .centered { text-align: center; }\n");
        html.append("    </style>\n");
        html.append("</head>\n");
        html.append("<body>\n");

        // Header
        html.append("    <h4>").append(escapeHtml(result.getCourtName())).append("</h4>\n");
        html.append("    <h1>").append(escapeHtml(result.getCaseNumber())).append("</h1>\n");
        html.append("    <h4>").append(displayDate).append("</h4>\n");
        html.append("    <br><br>\n");

        // Introduction
        html.append("    <p class='centered'>U IME DRŽAVE</p>\n");
        html.append("    <p>").append(escapeHtml(result.getCourtName())).append(", Sudija ").append(escapeHtml(result.getJudgeName())).append(", ");
        html.append("uz učešće ").append(escapeHtml(result.getClerkName())).append(" kao zapisničara, ");
        html.append("u krivičnom predmetu protiv okrivljenog ").append(escapeHtml(result.getDefendantName())).append(", ");
        html.append("zbog krivičnog djela ").append(result.getLawHTML());
        html.append("donio je dana ").append(displayDate).append(" godine</p>\n\n");

        // Presuda
        html.append("    <br><p class='centered'>PRESUDU</p>\n");
        html.append("    <br>");
        html.append("    <p>Okrivljeni ").append(escapeHtml(result.getDefendantName())).append(", ").append(escapeHtml(result.getDefendantBackground())).append("</p>\n ");

        if(result.getSentence()>0){
            html.append("    <p class='centered'>Kriv je</p>\n");
            html.append("    <p >").append(result.getDecisionString()).append("</p>\n");
            html.append("    <p class='centered'>OSUĐUJE</p>\n");
            html.append("    <p>").append(escapeHtml(result.getSentenceString())).append("</p>\n");
            html.append("    <br>\n");
        }else{
            html.append("    <p class='centered'>SE OSLOBAĐA OPTUŽBI</p>\n");
            html.append("    <p>").append(result.getDecisionString()).append("</p>\n");
            html.append("    <br>\n");
        }

        html.append("    <p class='centered'>OBRAZLOŽENJE</p>\n");
        html.append("    <br>\n");
        html.append("    <p>").append(escapeHtml(result.getExplanationString())).append("</p>\n");
        html.append("    <br>\n");

        html.append("    <p>ZAPISNIČAR: ");
        html.append(escapeHtml(result.getClerkName())).append("</p>\n");
        html.append("    <p>SUDIJA: ");
        html.append(escapeHtml(result.getJudgeName())).append("</p>\n");

        html.append("</body>\n");
        html.append("</html>");

        return html.toString();
    }

    /**
     * Escapes XML special characters
     */
    private static String escapeXml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    /**
     * Escapes HTML special characters
     */
    private static String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

}