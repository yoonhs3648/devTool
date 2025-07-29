package yoon.hyeon.sang.encrypter.service.impl;

import org.springframework.stereotype.Service;
import yoon.hyeon.sang.encrypter.service.EncrypterSvc;
import yoon.hyeon.sang.exception.UserException;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.spec.KeySpec;
import java.util.Base64;

@Service
public class EncrypterImpl implements EncrypterSvc {

    private static final String SECRET_KEY = "71F215DD7F984FBC9DF897AC4DF76FB7";
    private static final String SALT = "COVIFlow.NET";

    @Override
    public String aesEncrypt(String pk, String iv, String content) {
        try {
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec keySpec = new SecretKeySpec(pk.getBytes(StandardCharsets.UTF_8), "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(iv.getBytes(StandardCharsets.UTF_8));

            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);
            byte[] encrypted = cipher.doFinal(content.getBytes(StandardCharsets.UTF_8));

            return Base64.getEncoder().encodeToString(encrypted);
        } catch (Exception e) {
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String aesDecrypt(String pk, String iv, String content) {
        try {
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec keySpec = new SecretKeySpec(pk.getBytes(StandardCharsets.UTF_8), "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(iv.getBytes(StandardCharsets.UTF_8));

            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);
            byte[] decodedBytes = Base64.getDecoder().decode(content);
            byte[] decrypted = cipher.doFinal(decodedBytes);

            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String tripleDESEncrypt(String pk, String iv, String content) {
        try {
            SecretKey secretKey = get3DESKey(pk);
            IvParameterSpec ivSpec = getIv(iv);

            Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec);

            byte[] encrypted = cipher.doFinal(content.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encrypted);
        } catch (Exception e){
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String tripleDESDecrypt(String pk, String iv, String content) {
        try {
            SecretKey secretKey = get3DESKey(pk);
            IvParameterSpec ivSpec = getIv(iv);

            Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec);

            byte[] decoded = Base64.getDecoder().decode(content);
            byte[] decrypted = cipher.doFinal(decoded);
            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String engineEncrypt(String content) {
        try{
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec key = getKey();
            IvParameterSpec iv = getIv();
            cipher.init(Cipher.ENCRYPT_MODE, key, iv);
            byte[] encrypted = cipher.doFinal(content.getBytes(StandardCharsets.UTF_16LE));
            return Base64.getEncoder().encodeToString(encrypted);
        } catch (Exception e) {
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String engineDecrypt(String content) {
        try {
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec key = getKey();
            IvParameterSpec iv = getIv();
            cipher.init(Cipher.DECRYPT_MODE, key, iv);
            byte[] decoded = Base64.getDecoder().decode(content);
            byte[] decrypted = cipher.doFinal(decoded);
            return new String(decrypted, StandardCharsets.UTF_16LE);
        } catch (Exception e) {
            throw new UserException.CryptoException();
        }
    }

    //region private method
    private static SecretKey get3DESKey(String key) {
        byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);
        byte[] fullKey = new byte[24]; // 24바이트로 보정
        for (int i = 0; i < fullKey.length; i++) {
            fullKey[i] = keyBytes[i % keyBytes.length];
        }
        return new SecretKeySpec(fullKey, "DESede");
    }

    private static IvParameterSpec getIv(String iv) {
        String expandedIV = iv + iv; // 8 + 8 = 16바이트
        byte[] ivBytes = expandedIV.getBytes(StandardCharsets.UTF_8);
        return new IvParameterSpec(ivBytes, 0, 8);
    }

    private SecretKeySpec getKey() throws Exception {
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        KeySpec spec = new PBEKeySpec(SECRET_KEY.toCharArray(), SALT.getBytes(StandardCharsets.UTF_16LE), 1000, 256);
        byte[] keyBytes = factory.generateSecret(spec).getEncoded();
        return new SecretKeySpec(keyBytes, "AES");
    }

    private IvParameterSpec getIv() throws Exception {
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        KeySpec spec = new PBEKeySpec(SECRET_KEY.toCharArray(), SALT.getBytes(StandardCharsets.UTF_16LE), 1000, 128);
        byte[] ivBytes = factory.generateSecret(spec).getEncoded();
        return new IvParameterSpec(ivBytes);
    }
    //endregion
}
