package yoon.hyeon.sang.parser.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.parser.service.JsonParserSvc;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

@Controller
public class JsonParserCon {

    @Autowired
    private JsonParserSvc jsonParserSvc;

    @RequestMapping(value = "/jsonParser", method = RequestMethod.GET)
    public ModelAndView goPage(){
        String returnURL = "parser/jsonParser";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return  mv;
    }

    @RequestMapping(value = "/convert", method = RequestMethod.POST)
    public @ResponseBody String parseJson(@RequestBody Map<String, String> params, HttpServletRequest request) {

        String inputString = params.get("inputString").trim();
        String kind = params.get("kind");

        //문자열 맨앞뒤의 "가 있을 경우 제거
        if (inputString.startsWith("\"") && inputString.endsWith("\"")) {
            inputString = inputString.substring(1, inputString.length() - 1);
        }

        boolean isXml = inputString.startsWith("<");
        //<?xml ... ?> 선언 제거
        inputString = isXml ? inputString.replaceAll("<\\?xml.*?\\?>", "").trim() : inputString;

        try {
            switch (kind) {
                case "JPP": {
                    return isXml ? jsonParserSvc.JsonPrettyPrint(jsonParserSvc.XmlToJson(inputString)) : jsonParserSvc.JsonPrettyPrint(inputString);
                }
                case "JL": {
                    return isXml ? jsonParserSvc.JsonLinearize(jsonParserSvc.XmlToJson(inputString)) : jsonParserSvc.JsonLinearize(inputString);
                }
                case "XPP": {
                    return isXml ? jsonParserSvc.XmlPrettyPrint(inputString) : jsonParserSvc.XmlPrettyPrint(jsonParserSvc.JsonToXml(inputString));
                }
                case "XL": {
                    return isXml ? jsonParserSvc.XmlLinearize(inputString) : jsonParserSvc.XmlLinearize(jsonParserSvc.JsonToXml(inputString));
                }
            }
        } catch (Exception e) {
            return "<div class='error'>알수없는 에러가 발생했습니다</div>";
        }

        return "<div class='error'>옵션값이 잘못되었습니다</div>";
    }
}
