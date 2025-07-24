package yoon.hyeon.sang.parser.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

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
