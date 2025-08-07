package yoon.hyeon.sang.encrypter.service;

public interface EncrypterSvc {
    public String aesEncrypt(String pk, String iv, String content);
    public String aesDecrypt(String pk, String iv, String content);
    public String tripleDESEncrypt(String pk, String iv, String content);
    public String tripleDESDecrypt(String pk, String iv, String content);
    public String encryptToBase64(String plainTextUtf8, byte[] key, byte[] iv);
    public String decryptFromBase64(String base64Cipher, byte[] key, byte[] iv);
    public String engineEncrypt(String content);
    public String engineDecrypt(String content);
}
