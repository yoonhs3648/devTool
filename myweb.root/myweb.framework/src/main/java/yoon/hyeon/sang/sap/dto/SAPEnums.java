package yoon.hyeon.sang.sap.dto;

public class SAPEnums {
    public enum RFCParamKind {
        IMPORT,
        EXPORT,
        TABLE
    }

    public enum RFCDataType {
        STRING,
        STRUCTURE,
        TABLE
    }

    public enum MandatoryType {
        REQUIRED,
        OPTIONAL,
        UNKNOWN
    }
}
