package yoon.hyeon.sang.sap.dto;

import java.util.List;

/// RFC 구조
public class RFCFunctionMetaData {
    private String functionName;

    private List<RFCParamMetaData> importParams;
    private List<RFCParamMetaData> exportParams;
    private List<RFCParamMetaData> tableParams;

    public RFCFunctionMetaData() {
    }

    public String getFunctionName() {
        return functionName;
    }

    public void setFunctionName(String functionName) {
        this.functionName = functionName;
    }

    public List<RFCParamMetaData> getImportParams() {
        return importParams;
    }

    public void setImportParams(List<RFCParamMetaData> importParams) {
        this.importParams = importParams;
    }

    public List<RFCParamMetaData> getExportParams() {
        return exportParams;
    }

    public void setExportParams(List<RFCParamMetaData> exportParams) {
        this.exportParams = exportParams;
    }

    public List<RFCParamMetaData> getTableParams() {
        return tableParams;
    }

    public void setTableParams(List<RFCParamMetaData> tableParams) {
        this.tableParams = tableParams;
    }
}
