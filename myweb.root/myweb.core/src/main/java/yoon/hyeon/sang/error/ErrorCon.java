package yoon.hyeon.sang.error;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import java.util.Map;

@Controller
public class ErrorCon {

    @RequestMapping(value = "/errorPopup", method = RequestMethod.POST)
    public ModelAndView errorPopup(@RequestBody Map<String, String> body) {

        String returnURL = "error/commonErrorPop";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        mv.addObject("errorMessage", body.get("msg"));
        mv.addObject("url", body.get("url"));
        mv.addObject("stackTrace", body.get("trace"));
        return mv;
    }
}
