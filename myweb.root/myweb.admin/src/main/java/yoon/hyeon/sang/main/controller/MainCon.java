package yoon.hyeon.sang.main.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class MainCon {
    @RequestMapping(value = "/portal", method = RequestMethod.GET)
    public ModelAndView goMainPage(){
        String returnURL = "admin/portal";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return  mv;
    }
}
