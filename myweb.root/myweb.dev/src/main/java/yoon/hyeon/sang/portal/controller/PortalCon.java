package yoon.hyeon.sang.portal.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class PortalCon {
    @RequestMapping(value = "/portal", method = RequestMethod.GET)
    public ModelAndView goMainPage() {
        String returnURL = "portal";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return mv;
    }
}
