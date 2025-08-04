package yoon.hyeon.sang.cacheMgt.jvmCache.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.cacheMgt.jvmCache.service.JVMCacheSvc;

import javax.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;

@Controller
public class JVMCacheCon {

    @Autowired
    private JVMCacheSvc jvmCacheSvc;

    @RequestMapping(value = "/cache/jvm", method = RequestMethod.GET)
    public ModelAndView goPage(){
        String returnURL = "mgt/jvmCacheMgt";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return  mv;
    }

    @RequestMapping(value = "/cache/jvm/get", method = RequestMethod.GET)
    public @ResponseBody Map<String,String> getCache(HttpServletRequest request, @RequestParam String cacheKey) throws UnsupportedEncodingException {
        return jvmCacheSvc.getCache(cacheKey);
    }

    @RequestMapping(value = "/cache/jvm/set", method = RequestMethod.POST)
    public @ResponseBody String setCache(@RequestBody Map<String, String> params, HttpServletRequest request) {
        String key = params.get("cacheKey");
        String value = params.get("cacheVal");

        return jvmCacheSvc.setCache(key, value);
    }
}
