package yoon.hyeon.sang.sap.dto;

import java.util.List;

/// RFC 파라미터
public class RFCParamMetaData {
    private String name;                    // 파라미터명
    private String description;             // SAP 설명
    private SAPEnums.RFCParamKind kind;     // IMPORT / EXPORT / TABLE
    private SAPEnums.RFCDataType dataType;  // STRING / STRUCTURE / TABLE

    // CHAR(고정 길이 문자열), NUMC(숫자처럼 보이는 문자열), DATS(날짜), TIMS(시간), CURR(통화 금액), DEC(고정 소수점 숫자) 등
    private String sapType;
    private int length;
    private int decimals;
    private SAPEnums.MandatoryType mandatory;

    private List<RFCFieldMetaData> fields;  // STRUCTURE / TABLE일 때만 사용

    public RFCParamMetaData() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public SAPEnums.RFCParamKind getKind() {
        return kind;
    }

    public void setKind(SAPEnums.RFCParamKind kind) {
        this.kind = kind;
    }

    public SAPEnums.RFCDataType getDataType() {
        return dataType;
    }

    public void setDataType(SAPEnums.RFCDataType dataType) {
        this.dataType = dataType;
    }

    public String getSapType() {
        return sapType;
    }

    public void setSapType(String sapType) {
        this.sapType = sapType;
    }

    public int getLength() {
        return length;
    }

    public void setLength(int length) {
        this.length = length;
    }

    public int getDecimals() {
        return decimals;
    }

    public void setDecimals(int decimals) {
        this.decimals = decimals;
    }

    public SAPEnums.MandatoryType getMandatory() {
        return mandatory;
    }

    public void setMandatory(SAPEnums.MandatoryType mandatory) {
        this.mandatory = mandatory;
    }

    public List<RFCFieldMetaData> getFields() {
        return fields;
    }

    public void setFields(List<RFCFieldMetaData> fields) {
        this.fields = fields;
    }
}
