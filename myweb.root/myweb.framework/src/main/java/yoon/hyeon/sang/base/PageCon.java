package yoon.hyeon.sang.base;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class PageCon {
    @RequestMapping(value = {""}, method = RequestMethod.GET)
    public String goMainPage() {
        return "redirect:/portal";
    }
}
