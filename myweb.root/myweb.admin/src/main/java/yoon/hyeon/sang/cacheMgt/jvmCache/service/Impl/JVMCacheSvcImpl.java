package yoon.hyeon.sang.cacheMgt.jvmCache.service.Impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import yoon.hyeon.sang.cacheMgt.jvmCache.service.JVMCacheSvc;
import yoon.hyeon.sang.util.GlobalCache;
import yoon.hyeon.sang.util.RedisUtil;

import java.util.HashMap;
import java.util.Map;

@Service
public class JVMCacheSvcImpl implements JVMCacheSvc {

    @Autowired
    private RedisUtil redisUtil;


    @Override
    public Map<String, String> getCache(String key) {
        Map<String, String> returnMap = new HashMap<>();
        try {
            if (redisUtil.hasKey(key)) {
                String returnVal = (String) redisUtil.get(key);
                returnMap.put(key, returnVal);
            } else {
                returnMap.put(key, "캐쉬값이 없습니다");
            }
        } catch(Exception e) {
            throw e;
        }
        return returnMap;
    }

    @Override
    public String setCache(String key, String value) {
        try {
            long timeoutMilis = 1000 * 60 * 60 * 6;     // 6시간

            redisUtil.set(key, value, timeoutMilis);
        } catch (Exception e) {
            throw e;
        }

        return "Success";
    }
}
