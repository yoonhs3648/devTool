package yoon.hyeon.sang.cacheMgt.jvmCache.service;

import java.util.Map;

public interface JVMCacheSvc {

    public Map<String, String> getCache(String key);
    public String setCache(String key, String value);
}
