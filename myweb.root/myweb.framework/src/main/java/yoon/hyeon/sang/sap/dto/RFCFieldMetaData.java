package yoon.hyeon.sang.sap.dto;

public class RFCFieldMetaData {

    private String name;
    private String description;
    private String sapType;
    private int length;
    private int decimals;
    private SAPEnums.MandatoryType mandatory;

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
}
