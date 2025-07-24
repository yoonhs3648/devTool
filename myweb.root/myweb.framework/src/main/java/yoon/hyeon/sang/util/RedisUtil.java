package yoon.hyeon.sang.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Component
public class RedisUtil {

    private final RedisTemplate<String, Object> redisTemplate;

    @Autowired
    public RedisUtil(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    // ---------- 기본 Key-Value ----------
    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public void set(String key, Object value, long timeoutMillis) {
        Duration timeout = Duration.ofMillis(timeoutMillis);
        redisTemplate.opsForValue().set(key, value, timeout);
    }
    public Object get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    public boolean hasKey(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    // 키가 없거나, 값이 null 또는 빈객체 일경우 false
    public boolean hasValue(String key) {
        if (!hasKey(key)) {
            return false;  // 키가 없으면 빈 값으로 간주
        }
        Object value = redisTemplate.opsForValue().get(key);

        if (value == null) return false;

        if (value instanceof String) {
            return !((String) value).isEmpty();
        }
        if (value instanceof Collection<?>) {
            return !((Collection<?>) value).isEmpty();
        }
        if (value instanceof Map<?, ?>) {
            return !((Map<?, ?>) value).isEmpty();
        }
        if (value.getClass().isArray()) {
            return java.lang.reflect.Array.getLength(value) != 0;
        }

        return false; // 기타는 빈 값 아님
    }

    public void delete(String key) {
        redisTemplate.delete(key);
    }

    /// TTL을 설정함. key에 이미 TTL에 설정되어있다면 timeout 값으로 초기화된다
    public void setExpire(String key, long timeoutMillis) {
        Duration timeout = Duration.ofMillis(timeoutMillis);
        redisTemplate.expire(key, timeout);
    }

    // ---------- List ----------
    public void leftPush(String key, Object value) {
        redisTemplate.opsForList().leftPush(key, value);
    }

    public void rightPush(String key, Object value) {
        redisTemplate.opsForList().rightPush(key, value);
    }

    /// Redis의 List 구조에서 start, end 범위의 값들을 가져온다
    /// ex) leftPush로 최근 채팅을 왼쪽부터 넣었다면, start=0. end=29 로 최근채팅 30개를 가져올 수 있다
    public List<Object> rangeList(String key, long start, long end) {
        return redisTemplate.opsForList().range(key, start, end);
    }

    // ---------- Set ----------
    public void addSet(String key, Object value) {
        redisTemplate.opsForSet().add(key, value);
    }

    public Set<Object> getSet(String key) {
        return redisTemplate.opsForSet().members(key);
    }

    // ---------- Hash ----------
    public void putHash(String key, String hashKey, Object value) {
        redisTemplate.opsForHash().put(key, hashKey, value);
    }

    /// key에 해당하는 값(Map)을 반환
    public Map<Object, Object> getHash(String key) {
        return redisTemplate.opsForHash().entries(key);
    }

    /// key 안의 값(Map)중 키가 hashKey인것의 값을 반환
    public Object getFromHash(String key, String hashKey) {
        return redisTemplate.opsForHash().get(key, hashKey);
    }

    // ---------- Counter ----------
    public Long increment(String key) {
        return redisTemplate.opsForValue().increment(key);
    }

    public Long decrement(String key) {
        return redisTemplate.opsForValue().decrement(key);
    }
}
