package yoon.hyeon.sang.encrypter.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.encrypter.service.EncrypterSvc;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Controller
public class EncrypterCon {

    @Autowired
    private EncrypterSvc encrypterSvc;

    @RequestMapping(value = "/encrypter", method = RequestMethod.GET)
    public ModelAndView goPage(){
        String returnURL = "encrypter/encrypter";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return  mv;
    }

    @RequestMapping(value = "/doCrypto", method = RequestMethod.POST)
    public @ResponseBody Map<String,Object> doCrypto(@RequestBody Map<String, String> payload){

        Map<String, Object> returnMap = new HashMap<>();
        returnMap.put("isSucess", false);

        String crypto = Objects.toString(payload.get("crypto"), "").toLowerCase();
        String algorithm = payload.get("algorithm").toLowerCase();
        String pk = Objects.toString(payload.get("pk"), "");
        String iv = Objects.toString(payload.get("iv"), "");
        String content = Objects.toString(payload.get("content"), "");

        switch (algorithm.toLowerCase()) {
            case "aes": {
                if (crypto.equals("encryption")){
                    returnMap.put("returnVal", encrypterSvc.aesEncrypt(pk, iv, content));   //pk:32자/256비트  IV:16자/128비트
                } else {
                    returnMap.put("returnVal", encrypterSvc.aesDecrypt(pk, iv, content));
                }
                returnMap.put("isSucess", true);
                break;
            }
            case "tripledes": {
                if (crypto.equals("encryption")){
                    returnMap.put("returnVal", encrypterSvc.tripleDESEncrypt(pk, iv, content));     //pk:24자/192비트  IV:8자/64비트
                } else {
                    returnMap.put("returnVal", encrypterSvc.tripleDESDecrypt(pk, iv, content));
                }
                returnMap.put("isSucess", true);
                break;
            }
            case "engine": {
                if (crypto.equals("encryption")){
                    returnMap.put("returnVal", encrypterSvc.engineEncrypt(content));
                } else {
                    returnMap.put("returnVal", encrypterSvc.engineDecrypt(content));
                }
                returnMap.put("isSucess", true);
                break;
            }
        }

        return returnMap;
    }
}
