package yoon.hyeon.sang.htmlViewer.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class HtmlViewerCon {

    @RequestMapping(value = "/htmlViewer", method = RequestMethod.GET)
    public ModelAndView goPage(){
        String returnURL = "htmlViewer/htmlViewer";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return  mv;
    }
}
