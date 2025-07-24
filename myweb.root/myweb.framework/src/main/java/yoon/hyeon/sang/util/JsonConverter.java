package yoon.hyeon.sang.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

public class JsonConverter {
    private static final ObjectMapper mapper = new ObjectMapper();

    /// 직렬화
    public static String serializeObject(Object object) {
        try {
            return mapper.writeValueAsString(object);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("JSON 직렬화 실패: " + e.getMessage(), e);
        }
    }

    /// 단일 객체 역직렬화
    public static <T> T deserializeObject(String jsonString, Class<T> hsyoonClass) {
        try {
            return mapper.readValue(jsonString, hsyoonClass);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("JSON 역직렬화 실패", e);
        }
    }

    /// 제네릭 컬렉션(Typereference) 역직렬화
    public static <T> T deserializeObject(String jsonString, TypeReference<T> typeRef) {
        try {
            return mapper.readValue(jsonString, typeRef);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("JSON 제네릭 역직렬화 실패", e);
        }
    }

}
