package yoon.hyeon.sang.util;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class GlobalCache {

    private static final Map<String, String> cache = new ConcurrentHashMap<>();

    //설정
    public static void set(String key, String value) {
        cache.put(key, value);
    }

    //조회
    public static String get(String key) {
        return cache.get(key);
    }

    //조회(기본값)
    public static String get(String key, String defaultValue) {
        return cache.getOrDefault(key, defaultValue);
    }

    //모든 키 반환
    public static Set<String> getAllKeys() {
        return cache.keySet();
    }

    //모든 키-값 쌍 반환
    public static Map<String, String> getAllKeyValues() {
        return new ConcurrentHashMap<>(cache);  //원본 cache 수정 방지을 위함
    }

    //제거
    public static void delete(String key) {
        cache.remove(key);
    }

    //전체 초기화
    public static void clearAll() {
        cache.clear();
    }
}
