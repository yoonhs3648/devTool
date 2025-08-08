package yoon.hyeon.sang.parser.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import com.fasterxml.jackson.dataformat.xml.deser.FromXmlParser;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.w3c.dom.*;
import yoon.hyeon.sang.parser.service.JsonParserSvc;

import java.util.Iterator;
import java.util.Map;

import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import java.io.StringReader;
import java.io.StringWriter;

@Service
public class JsonParserSvcImpl implements JsonParserSvc {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private int toggleIdSeq = 0;
    private final String tempRootTagName = "tempRootTag";
    private final String tempArrayTagName = "tempArrayTag";
    private final int indentMargin = 8;

    @Override
    public String JsonPrettyPrint(String jsonString) {
        try {
            JsonNode root = objectMapper.readTree(jsonString);
            int depth = 0;
            StringBuilder sb = new StringBuilder();

            if (root.isObject()) {
                sb.append("<div id='").append(++toggleIdSeq).append("'>")
                        .append("<div>")
                        .append(createToggleSpan(null, depth, "object", false))
                        .append("</div>");

                sb.append(makeJsonHtml(root, depth + 1, false));

                sb.append("<div>")
                        .append("<span ")
                        .append("class='json-symbol'>")
                        .append("}</span>")
                        .append("</div>");

                sb.append("</div>");
            } else if (root.isArray()) {
                sb.append("<div id='").append(++toggleIdSeq).append("'>")
                        .append("<div>")
                        .append(createToggleSpan(null, depth, "array", false))
                        .append("</div>");

                sb.append(makeJsonHtml(root, depth + 1, false));

                sb.append("<div>")
                        .append("<span ")
                        .append("class='json-arr-symbol'>")
                        .append("]</span>")
                        .append("</div>");

                sb.append("</div>");
            } else {
                sb.append("<div class='error'>파싱 오류: 잘못된 JSON 포맷입니다</div>");
            }

            return sb.toString();
        } catch (Exception e) {
            return "<div class='error'>파싱 오류: " + e.getMessage() + "</div>";
        }
    }

    @Override
    public String JsonLinearize(String parsedJson) {
        try {
            ObjectMapper mapper = new ObjectMapper();

            // 1. JSON 문자열을 JsonNode 객체로 파싱
            JsonNode jsonNode = mapper.readTree(parsedJson);
            // 2. 한 줄로 출력 (pretty print 안함)
            return mapper.writeValueAsString(jsonNode);
        }
        catch (Exception e) {
            return "<div class='error'>파싱 오류: " + e.getMessage() + "</div>";
        }
    }

    @Override
    public String XmlPrettyPrint(String xmlString) {
        try {
            StringBuilder sb = new StringBuilder();
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true); // 네임스페이스 인식
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(new InputSource(new StringReader(xmlString)));

            Element root = document.getDocumentElement();

            sb.append("<div id='")
                    .append(toggleIdSeq)
                    .append("'>");
            sb.append(makeXmlHtml(root, true));
            sb.append("</div>");

            return sb.toString();
        }
        catch (Exception e) {
            String startRootTag = "<" + tempRootTagName + ">";

            if (!xmlString.startsWith(startRootTag)) {
                String wrappedXmlString = "<" + tempRootTagName + ">" + xmlString + "</" + tempRootTagName + ">";
                return XmlPrettyPrint(wrappedXmlString);
            } else {
                return "<div class='error'>파싱 오류: " + e.getMessage() + "</div>";
            }
        }
    }

    @Override
    public String XmlLinearize(String xmlString) {
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true); // 네임스페이스 보존
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(new InputSource(new StringReader(xmlString)));

            // XML을 한 줄로 변환 (pretty print X, 선언부 제거)
            TransformerFactory tf = TransformerFactory.newInstance();
            Transformer transformer = tf.newTransformer();
            //transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes"); // <?xml ... ?> 제거
            transformer.setOutputProperty(OutputKeys.INDENT, "no"); // 들여쓰기 없음

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(document), new StreamResult(writer));
            return writer.toString().trim();
        }
        catch (Exception e) {
            return "<div class='error'>파싱 오류: " + e.getMessage() + "</div>";
        }
    }

    @Override
    public String XmlToJson(String xmlString) {
        try {
            //네임스페이스를 삭제 (ex. <tag:encoded> 에서 encoded 네임스페이스 삭제)
            xmlString = xmlString.replaceAll("(?<=</?)\\w+?:", "");

            String rootTagName = getRootElement(xmlString);
            //루트태그가 없을경우 생성
            if (!xmlString.endsWith("</" + rootTagName + ">")) {
                rootTagName = tempRootTagName;
                xmlString = "<" + rootTagName + ">" + xmlString + "</" + rootTagName + ">";
            }

            XmlMapper xmlMapper = new XmlMapper();
            //빈태그는 null값을 반환
            xmlMapper.configure(FromXmlParser.Feature.EMPTY_ELEMENT_AS_NULL, true);

            JsonNode jsonNode = xmlMapper.readTree(xmlString);

            ObjectMapper jsonMapper = new ObjectMapper();
            ObjectNode wrappedNode = jsonMapper.createObjectNode();
            wrappedNode.set(rootTagName, jsonNode);

            return jsonMapper.writeValueAsString(wrappedNode);
        }
        catch (Exception e) {
            return "<div class='error'>XML을 JSON으로 변환할 수 없습니다: " + e.getMessage() + "</div>";
        }
    }

    @Override
    public String JsonToXml(String JsonString) {
        try {
            ObjectMapper jsonMapper = new ObjectMapper();
            JsonNode jsonNode = jsonMapper.readTree(JsonString);
            XmlMapper xmlMapper = new XmlMapper();

            //jsonString이 배열일 경우 처리
            if (jsonNode.isArray()) {
                ObjectMapper mapper = new ObjectMapper();
                ObjectNode wrapper = mapper.createObjectNode();
                wrapper.set(tempRootTagName, jsonNode);
                jsonNode = wrapper;
                return xmlMapper.writer().withRootName(tempArrayTagName).writeValueAsString(jsonNode);  //각 배열은 tempRootTageName의 하위태그로 들어가고 배열은 ObjectNode의 하위태그로 들어간다
            } else {
                return xmlMapper.writer().withRootName(tempRootTagName).writeValueAsString(jsonNode);
            }
        }
        catch (Exception e) {
            return "<div class='error'>JSON을 XML으로 변환할 수 없습니다: " + e.getMessage() + "</div>";
        }
    }

    //region Private Method
    private String makeJsonHtml(JsonNode node, int depth){
        return makeJsonHtml(node, depth, true);
    }

    private String makeJsonHtml(JsonNode node, int depth, boolean isLastRecursive) {
        StringBuilder sb = new StringBuilder();

        if (node.isObject()) {
            Iterator<Map.Entry<String, JsonNode>> fields = node.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> entry = fields.next();
                String key = entry.getKey();
                JsonNode value = entry.getValue();

                if (value.isObject() || value.isArray()) {
                    sb.append("<div id='").append(++toggleIdSeq).append("'")
                            .append(setMargin())
                            .append(">")
                            .append("<div>")
                            .append(createToggleSpan(key, depth, value.isArray() ? "array" : "object", true))
                            .append("</div>")
                            .append(makeJsonHtml(value, depth + 1))
                            .append("<div>")
                            .append("<span class='")
                            .append(value.isArray() ? "json-arr-symbol" : "json-symbol")
                            .append("'>")
                            .append(value.isArray() ? "]" : "}");
                    if (fields.hasNext()) sb.append("<span class='json-symbol'>,</span>");
                    sb.append("</span>");
                    sb.append("</div>");
                    sb.append("</div>");
                } else if (value.isTextual()) {
                    sb.append(createValueSpan(key, "json-string", "\"" + escapeHtml(value.asText()) + "\"", fields.hasNext(), depth));
                } else if (value.isNumber()) {
                    sb.append(createValueSpan(key, "json-number", value.numberValue().toString(), fields.hasNext(), depth));
                } else if (value.isBoolean()) {
                    sb.append(createValueSpan(key, "json-boolean", String.valueOf(value.asBoolean()), fields.hasNext(), depth));
                } else if (value.isNull()) {
                    sb.append(createValueSpan(key, "json-null", "null", fields.hasNext(), depth));
                }
            }
        } else if (node.isArray()) {
            for (int i = 0; i < node.size(); i++) {
                JsonNode child = node.get(i);
                boolean isLast = (i == node.size() - 1);

                if (child.isObject() || child.isArray()) {
                    sb.append("<div id='").append(++toggleIdSeq).append("'")
                            .append(setMargin())
                            .append("'>")
                            .append("<div>")
                            .append(createToggleSpan(null, depth, child.isArray() ? "array" : "object", false))
                            .append("</div>")
                            .append(makeJsonHtml(child, depth + 1, isLast))
                            .append("<div>")
                            .append("<span class='")
                            .append(child.isArray() ? "json-arr-symbol" : "json-symbol")
                            .append("'>")
                            .append(child.isArray() ? "]" : "}");
                    if (!isLast) sb.append("<span class='json-symbol'>,</span>");
                    sb.append("</span>");
                    sb.append("</div>");
                    sb.append("</div>");
                } else {
                    sb.append(makeJsonHtml(child, depth, !isLast));
                }
            }
        } else {
            String value = node.isTextual() ? "\"" + escapeHtml(node.asText()) + "\""
                    : node.isNumber() ? node.numberValue().toString()
                    : node.isBoolean() ? String.valueOf(node.asBoolean())
                    : "null";
            String className = node.isTextual() ? "json-string"
                    : node.isNumber() ? "json-number"
                    : node.isBoolean() ? "json-boolean"
                    : "json-null";

            sb.append(createSingleValueSpan(className, value, isLastRecursive, depth));
        }
        return sb.toString();

    }

    private String createToggleSpan(String key, int depth, String type, boolean showKey) {
        String icon = type.equals("array") ? "toggle-array-minus.png" : "toggle-minus.png";
        String symbolClass = type.equals("array") ? "json-arr-symbol" : "json-symbol";
        StringBuilder sb = new StringBuilder();

        if (showKey && key != null) {
            sb.append("<span class='json-key'>")
                    .append("\"").append(escapeHtml(key)).append("\"</span>")
                    .append("<span class='json-symbol'>: </span>");
        }

        sb.append("<span class='toggle' onclick='toggle(this)' data-type='").append(type)
                .append("' id='toggle_").append(toggleIdSeq).append("'>")
                .append("<img src='/dev/resources/img/").append(icon).append("' class='toggle-icon' /></span>")
                .append("<span class='").append(symbolClass).append("' style='display: none;' id='hide_")
                .append(toggleIdSeq).append("' data-indent='").append(depth).append("'></span>")
                .append("<span class='").append(symbolClass).append("' id='bracket_").append(toggleIdSeq).append("'>")
                .append(type.equals("array") ? "[" : "{").append("</span>");

        return sb.toString();
    }

    private String createValueSpan(String key, String className, String value, boolean addComma, int depth) {
        StringBuilder sb = new StringBuilder();
        sb.append("<div ").append(setMargin()).append(">")
                .append("<span class='json-key'>")
                .append("\"").append(escapeHtml(key)).append("\"</span>")
                .append("<span class='json-symbol'>: </span>")
                .append("<span class='").append(className).append("'>")
                .append(value).append("</span>");
        if (addComma) sb.append("<span class='json-symbol'>,</span>");
        sb.append("</div>");
        return sb.toString();
    }

    private String createSingleValueSpan(String className, String value, boolean addComma, int depth) {
        StringBuilder sb = new StringBuilder();
        sb.append("<div ").append(setMargin()).append(">")
                .append("<span class='").append(className).append("'>")
                .append(value).append("</span>");
        if (addComma) sb.append("<span class='json-symbol'>,</span>");
        sb.append("</div>");
        return sb.toString();
    }

    private String makeXmlHtml(Element node, boolean hasChildElement) {
        StringBuilder sb = new StringBuilder();

        //region 시작 엘리먼트
        sb.append("<div>");

        if (hasChildElement) {
            sb.append("<span class='xml-toggle' onclick='xmlToggle(this)' data-type='tag' id='toggle_")
                    .append(++toggleIdSeq)
                    .append("'>");
        }
        else {
            sb.append("<span class='xml-symbol'>");
        }

        sb.append("<span class='xml-symbol'>")
                .append(escapeHtml("<"))
                .append("</span>");

        //네임스페이스 prefix
        String prefix = node.getPrefix();
        if (prefix != null) {
            sb.append("<span class='xml-prefix'>")
                    .append(escapeHtml(prefix))
                    .append(":")
                    .append("</span>");
        }

        sb.append("<span class='xml-localName'>")
                .append(escapeHtml(node.getLocalName()))
                .append("</span>");

        //속성
        NamedNodeMap attributes = node.getAttributes();
        for (int i = 0; i < attributes.getLength(); i++) {
            Node attr = attributes.item(i);
            sb.append("<span class='xml-attrName'>")
                    .append(" ")
                    .append(escapeHtml(attr.getNodeName()))
                    .append("=")
                    .append("</span>")
                    .append("<span class='xml-attrValue'>")
                    .append("\"")
                    .append(escapeHtml(attr.getNodeValue()))
                    .append("\"")
                    .append("</span>");
        }

        String textNode = node.getTextContent();

        if (!hasChildElement) {
            sb.append("<span class='xml-symbol'>")
                    .append(escapeHtml(">"))
                    .append("</span>");

            sb.append("<span class='xml-textContent'>")
                    .append(escapeHtml(textNode))
                    .append("</span>");

            sb.append("<span class='xml-symbol'>")
                    .append(escapeHtml("</"))
                    .append("</span>");

            sb.append("<span class='xml-localName'>")
                    .append(escapeHtml(node.getLocalName()))
                    .append("</span>");

            sb.append("<span class='xml-symbol'>")
                    .append(escapeHtml(">"))
                    .append("</span>");

            sb.append("</span>");
            sb.append("</div>");
            return sb.toString();
        }

        sb.append("<span class='xml-symbol'>")
                .append(escapeHtml(">"))
                .append("</span>");

        sb.append("</span>");
        sb.append("</div>");

        sb.append("<div style='display: none;' id='hide_")
                .append(toggleIdSeq)
                .append("'>");

        sb.append("<span class='xml-symbol' id='collapsed_")
                .append(toggleIdSeq)
                .append("'>")
                .append("</span>");

        sb.append("</div>");
        //endregion

        //region 자식 엘리먼트
        sb.append("<div id='")
                .append(toggleIdSeq)
                .append("' ")
                .append(setMargin())
                .append(">");

        //자식엘리먼트 순회
        for (int i=0; i<node.getChildNodes().getLength(); i++) {
            Node child = node.getChildNodes().item(i);

            if(child.getNodeType() == Node.ELEMENT_NODE) {

                //손자노드 중 엘리먼트 태그가 있는지 확인
                boolean hasElementGrandchild = false;
                for (int j = 0; j < child.getChildNodes().getLength(); j++) {
                    Node grandChild = child.getChildNodes().item(j);
                    if (grandChild.getNodeType() == Node.ELEMENT_NODE) {
                        hasElementGrandchild = true;
                        break;
                    }
                }

                Element childElement = (Element) child;
                sb.append(makeXmlHtml(childElement, hasElementGrandchild));
            } else if (child.getNodeType() == Node.TEXT_NODE || child.getNodeType() == Node.CDATA_SECTION_NODE) {
                String childText = child.getTextContent();
                if (!childText.trim().isEmpty()) {
                    sb.append("<div>");

                    sb.append("<span class='xml-textContent'>")
                            .append(escapeHtml(childText))
                            .append("</span>");

                    sb.append("</div>");
                }
            }
        }

        sb.append("</div>");
        //endregion

        //region 끝 엘리먼트
        sb.append("<div>");

        sb.append("<span class='xml-symbol'>")
                .append(escapeHtml("</"))
                .append("</span>");

        sb.append("<span class='xml-localName'>")
                .append(escapeHtml(node.getLocalName()))
                .append("</span>");

        sb.append("<span class='xml-symbol'>")
                .append(escapeHtml(">"))
                .append("</span>");

        sb.append("</div>");
        //endregion

        return sb.toString();
    }

    private String getIndent(int repeat) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < repeat; i++) {
            sb.append("&nbsp;&nbsp;&nbsp");
        }
        return sb.toString();
    }

    private String setMargin() {
        return " style=\"margin-left: 30px;\" ";
    }

    private String escapeHtml(String input) {
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String getRootElement(String xmlString) {
        int startTag = xmlString.indexOf('<') + 1;
        int endTag = xmlString.indexOf('>', startTag);
        if (endTag == -1 ) return "";

        // 태그 속성이나 빈태그 처리
        // ex) <a id="1">, <a/>
        return xmlString.substring(startTag, endTag).split("\\s")[0].replace("/", "");
    }

    //endregion
}
