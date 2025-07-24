package yoon.hyeon.sang.exception;

// API 예외 클래스
public class ApiException extends RuntimeException {

    public ApiException(String message) { super(message); }
    public ApiException(String message, Throwable cause) { super(message, cause); }

    /// Content-Type 설정이 잘못됨
    public static class InvalidContentType extends ApiException {
        public InvalidContentType(String message) {
            super(message);
        }
        public InvalidContentType(Throwable cause) { super("Invalid Content-Type", cause); }
        public InvalidContentType(String message, Throwable cause) { super(message, cause); }
    }

    /// HTTP 응답이 없음 (DNS오류:UnknownHostException, 연결실패:ResourcesAcessException 등)
    public static class NoHttpResponseException extends ApiException {
        public NoHttpResponseException(String message) { super(message); }
        public NoHttpResponseException(Throwable cause) { super("Bad HTTP Response", cause); }
        public NoHttpResponseException(String message, Throwable cause) { super(message, cause); }
    }

    public static class ApiResponseException extends ApiException {
        public ApiResponseException(String message) { super(message); }
        public ApiResponseException(Throwable cause) { super("Api Response Error", cause); }
        public ApiResponseException(String message, Throwable cause) { super(message, cause); }
    }
}
