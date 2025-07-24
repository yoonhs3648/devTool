package yoon.hyeon.sang.parser.service;

public interface JsonParserSvc {

    public String JsonPrettyPrint(String jsonString);
    public String JsonLinearize(String parsedJson);
    public String XmlPrettyPrint(String xmlString);
    public String XmlLinearize(String xmlString);
    public String XmlToJson(String xmlString);
    public String JsonToXml(String JsonString);
}
