package yoon.hyeon.sang.encrypter.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.encrypter.service.EncrypterSvc;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Controller
public class EncrypterCon {

    @Autowired
    private EncrypterSvc encrypterSvc;

    private static final byte[] INIT_VEC = new byte[] {
            67, 111, 118, 105, 115, 105, 111, 110  //Covision
    };
    private static final Charset CRYPTO_ENCODING = StandardCharsets.UTF_8;

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
            case "tripledesstr": {
                if (crypto.equals("encryption")){
                    returnMap.put("returnVal", encrypterSvc.tripleDESEncrypt(pk, iv, content));     //pk:24자/192비트  IV:8자/64비트
                } else {
                    returnMap.put("returnVal", encrypterSvc.tripleDESDecrypt(pk, iv, content));
                }
                returnMap.put("isSucess", true);
                break;
            }
            case "tripledescsv": {
                byte[] bytepk = parseSecureKeyCommaHex(pk); // 16 bytes
                byte[] byteiv = validatedTripleDESIV(iv);
                if (crypto.equals("encryption")){
                    returnMap.put("returnVal", encrypterSvc.encryptToBase64(content, bytepk, byteiv));
                } else {
                    returnMap.put("returnVal", encrypterSvc.decryptFromBase64(content, bytepk, byteiv));
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


    /** 쉼표 구분 HEX 문자열을 바이트로 (예: "79,6E,63,...") */
    public static byte[] parseSecureKeyCommaHex(String commaHex) {
        String[] parts = commaHex.split(",");
        byte[] out = new byte[parts.length];
        for (int i = 0; i < parts.length; i++) {
            String s = parts[i].trim();
            // C#: byte.Parse(s, NumberStyles.HexNumber)
            out[i] = (byte) Integer.parseInt(s, 16);
        }
        return out;
    }

    /** C# ValidatedTripleDESIV와 동일 규칙으로 8바이트 IV 생성 */
    public static byte[] validatedTripleDESIV(String siteName) {
        if (siteName == null || siteName.isEmpty()) {
            throw new IllegalArgumentException("Null key value");
        }
        byte[] siteBytes = CRYPTO_ENCODING.encode(siteName).array();
        // C#: if (keyString.Length != numArray.Length) throw ...
        // 주의: .NET의 string.Length는 '문자 수', GetBytes().Length는 '바이트 수'
        // 주어진 소스 그대로라면, UTF-8에서 ASCII만 포함할 때만 길이가 같음.
        // 실제 코드대로 예외를 내야 하므로 동일 체크 수행:
        int charCount = siteName.length();
        int byteCount = CRYPTO_ENCODING.encode(siteName).remaining(); // 정확한 바이트 길이
        if (charCount != byteCount) {
            throw new IllegalArgumentException("Argument must to number or english");
        }

        String keyStr = siteName;
        if (keyStr.length() > 8) {
            keyStr = keyStr.substring(0, 8);
        }
        if (keyStr.length() < 8) {
            String initStr = new String(INIT_VEC, CRYPTO_ENCODING); // "Covision"
            keyStr = keyStr + initStr.substring(0, 8 - keyStr.length());
        }
        byte[] iv = keyStr.getBytes(CRYPTO_ENCODING);
        if (iv.length != 8) {
            throw new IllegalArgumentException("Argument must to length 8");
        }
        return iv;
    }
}
