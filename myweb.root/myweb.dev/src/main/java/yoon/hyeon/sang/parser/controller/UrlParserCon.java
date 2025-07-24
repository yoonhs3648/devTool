package yoon.hyeon.sang.parser.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

@Controller
public class UrlParserCon {

    @RequestMapping(value = "/urlParser", method = RequestMethod.GET)
    public ModelAndView goPage(){
        String returnURL = "parser/urlParser";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return  mv;
    }
}
