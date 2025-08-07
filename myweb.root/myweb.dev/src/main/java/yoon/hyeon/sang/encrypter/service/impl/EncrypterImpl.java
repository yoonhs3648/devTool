package yoon.hyeon.sang.encrypter.service.impl;

import org.springframework.stereotype.Service;
import yoon.hyeon.sang.encrypter.service.EncrypterSvc;
import yoon.hyeon.sang.exception.UserException;

import javax.crypto.*;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.security.spec.KeySpec;
import java.util.Arrays;
import java.util.Base64;

@Service
public class EncrypterImpl implements EncrypterSvc {

    private static final String SECRET_KEY = "71F215DD7F984FBC9DF897AC4DF76FB7";    //엔진

    private static final String TRANSFORMATION = "DESede/CBC/PKCS5Padding";
    private static final String ALGO = "DESede";

    private static final byte[] BYTES_KEY = new byte[] {
            (byte) 67,
            (byte) 111,
            (byte) 118,
            (byte) 105,
            (byte) 46,
            (byte) 70,
            (byte) 114,
            (byte) 97,
            (byte) 109,
            (byte) 101,
            (byte) 87,
            (byte) 111,
            (byte) 114,
            (byte) 107,
            (byte) 86,
            (byte) 48
    };
    private static final byte[] INIT_VEC = new byte[] {
            (byte) 67,
            (byte) 111,
            (byte) 118,
            (byte) 105,
            (byte) 115,
            (byte) 105,
            (byte) 111,
            (byte) 110
    };

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
            ByteArrayOutputStream memoryStream = new ByteArrayOutputStream();
            Cipher cipher = getAlgorithm(SECRET_KEY, Cipher.ENCRYPT_MODE); // 복호화 때와 동일한 메서드

            CipherOutputStream cryptoStream = new CipherOutputStream(memoryStream, cipher);

            byte[] bytes = content.getBytes(StandardCharsets.UTF_16LE);
            cryptoStream.write(bytes);
            cryptoStream.flush();
            cryptoStream.close();

            return Base64.getEncoder().encodeToString(memoryStream.toByteArray());
        } catch(Exception e) {
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String engineDecrypt(String content) {
        try {
            byte[] decodedBytes = java.util.Base64.getDecoder().decode(content);

            ByteArrayInputStream memoryStream = new ByteArrayInputStream(decodedBytes);
            Cipher cipher = getAlgorithm(SECRET_KEY, Cipher.DECRYPT_MODE);
            CipherInputStream cryptoStream = new CipherInputStream(memoryStream, cipher);

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = cryptoStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }

            cryptoStream.close();
            memoryStream.close();

            return new String(outputStream.toByteArray(), StandardCharsets.UTF_16LE);
        } catch(Exception e) {
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String encryptToBase64(String plainTextUtf8, byte[] key, byte[] iv) {
        try {
            byte[] cipher = encrypt(plainTextUtf8.getBytes(StandardCharsets.UTF_8), key, iv);
            return Base64.getEncoder().encodeToString(cipher);
        } catch(Exception e) {
            throw new UserException.CryptoException();
        }
    }

    @Override
    public String decryptFromBase64(String base64Cipher, byte[] key, byte[] iv) {
        try{
            byte[] cipher = Base64.getDecoder().decode(base64Cipher);
            byte[] plain = decrypt(cipher, key, iv);
            return new String(plain, StandardCharsets.UTF_8);
        } catch(Exception e){
            throw new UserException.CryptoException();
        }
    }

    //region tripleDES by CVS
    /** 바이트 단위 암호화 (TripleDES/CBC/PKCS7) */
    public static byte[] encrypt(byte[] plain, byte[] key, byte[] iv) throws Exception {
        SecretKey sk = build3DesKey(key);
        IvParameterSpec ivSpec = new IvParameterSpec(requireExact8(iv));
        Cipher cipher = Cipher.getInstance(TRANSFORMATION);
        cipher.init(Cipher.ENCRYPT_MODE, sk, ivSpec);
        return cipher.doFinal(plain);
    }

    /** 바이트 단위 복호화 (TripleDES/CBC/PKCS7) */
    public static byte[] decrypt(byte[] cipherBytes, byte[] key, byte[] iv) throws Exception {
        SecretKey sk = build3DesKey(key);
        IvParameterSpec ivSpec = new IvParameterSpec(requireExact8(iv));
        Cipher cipher = Cipher.getInstance(TRANSFORMATION);
        cipher.init(Cipher.DECRYPT_MODE, sk, ivSpec);
        return cipher.doFinal(cipherBytes);
    }

    /** 16B면 K1‖K2‖K1로 24B 확장, 24B면 그대로. 그 외 길이는 예외 */
    public static SecretKey build3DesKey(byte[] key) {
        if (key == null) throw new IllegalArgumentException("Key is null");
        byte[] k;
        if (key.length == 24) {
            k = key.clone();
        } else if (key.length == 16) {
            // 2-Key 3DES: K1(8) K2(8) K1(8)
            k = new byte[24];
            System.arraycopy(key, 0, k, 0, 16);
            System.arraycopy(key, 0, k, 16, 8);
        } else {
            throw new IllegalArgumentException("3DES key must be 16 or 24 bytes. Got " + key.length);
        }
        return new SecretKeySpec(k, ALGO);
    }

    private static byte[] requireExact8(byte[] iv) {
        if (iv == null || iv.length != 8) {
            throw new IllegalArgumentException("IV must be 8 bytes");
        }
        return iv;
    }
    //endregion

    //region engine
    private static Cipher getAlgorithm(String secretKey, int mode) {
        try {
            // 고정된 salt: "COVIFlow.NET"을 UTF-16LE로 인코딩
            byte[] salt = "COVIFlow.NET".getBytes(StandardCharsets.UTF_16LE);

            // PBKDF2 키 유도 (C# Rfc2898DeriveBytes와 동일)
            int iterations = 1000; // 기본 반복 횟수
            int keyLength = 256;   // 총 256비트 (AES-256)
            int blockSize = 128;   // AES block size = 128비트 (16바이트)

            // 총 필요한 길이 = IV(16바이트) + Key(32바이트) = 48바이트
            KeySpec spec = new PBEKeySpec(secretKey.toCharArray(), salt, iterations, keyLength + blockSize);
            SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
            byte[] keyIvBytes = factory.generateSecret(spec).getEncoded();

            byte[] ivBytes = Arrays.copyOfRange(keyIvBytes, 0, 16);     // IV
            byte[] keyBytes = Arrays.copyOfRange(keyIvBytes, 16, 48);   // Key

            SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(ivBytes);

            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(mode, keySpec, ivSpec);

            return cipher;
        } catch(Exception e) {
            throw new UserException.CryptoException();
        }
    }
    //endregion

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
    //endregion
}
