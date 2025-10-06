export interface VerdictFile{
    decision: string | null;
    law_article: string | null;
    law_paragraph: string | null;
    sentence: number | null;
    explanation: string | null;
    caseNumber: string | null;
    courtName: string | null;
    countryCode: string | null;
    judgeName: string | null;
    clerkName: string | null;
    defendantName: string | null;
    minSentenceMonths: number | null;
    maxSentenceMonths: number | null;
};