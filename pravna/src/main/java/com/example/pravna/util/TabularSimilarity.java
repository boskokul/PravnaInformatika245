package com.example.pravna.util;

import es.ucm.fdi.gaia.jcolibri.exception.NoApplicableSimilarityFunctionException;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.NNretrieval.similarity.LocalSimilarityFunction;

import java.util.List;

public class TabularSimilarity implements LocalSimilarityFunction {
    private final double matrix[][];
    private final List<String> categories;

    public TabularSimilarity(List<String> categories) {
        this.categories = categories;
        int n = categories.size();
        matrix = new double[n][n];
        for (int i = 0; i < n; i++)
            matrix[i][i] = 1;
    }

    public void setSimilarity(String value1, String value2, double sim) {
        setSimilarity(value1, value2, sim, sim);
    }

    public void setSimilarity(String value1, String value2, double sim1, double sim2) {
        int index1 = categories.indexOf(value1);
        int index2 = categories.indexOf(value2);
        if (index1 != -1 && index2 != -1) {
            matrix[index1][index2] = sim1;
            matrix[index2][index1] = sim2;
        }
    }

    @Override
    public double compute(Object value1, Object value2) throws NoApplicableSimilarityFunctionException {
        if (value1 instanceof String && value2 instanceof String) {
            String s1 = (String) value1;
            String s2 = (String) value2;
            return compute(s1, s2);
        }
        return 0;
    }

    public double compute(String str1, String str2) {
        int index1 = categories.indexOf(str1);
        int index2 = categories.indexOf(str2);
        if (index1 != -1 && index2 != -1)
            return matrix[index1][index2];
        if (str1 != null && str1.equals(str2))
            return 1;
        return 0;
    }

    @Override
    public boolean isApplicable(Object value1, Object value2) {
        return value1 instanceof String && value2 instanceof String;
    }
}
