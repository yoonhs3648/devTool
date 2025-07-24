package yoon.hyeon.sang.encoder.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.encoder.service.EncoderSvc;

@Controller
public class EncoderCon {

    @Autowired
    private EncoderSvc encoderSvc;

    @RequestMapping(value = "/encoder", method = RequestMethod.GET)
    public ModelAndView goPage(){
        String returnURL = "encoder/encoder";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return  mv;
    }
}
