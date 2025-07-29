package yoon.hyeon.sang.encrypter.service;

public interface EncrypterSvc {
    public String aesEncrypt(String pk, String iv, String content);
    public String aesDecrypt(String pk, String iv, String content);
    public String tripleDESEncrypt(String pk, String iv, String content);
    public String tripleDESDecrypt(String pk, String iv, String content);
    public String engineEncrypt(String content);
    public String engineDecrypt(String content);
}
