package yoon.hyeon.sang.exception;

// 사용자 정의 예외 클래스
public class UserException extends RuntimeException {

    public UserException(String message, Throwable cause) {}
    public UserException(String message) { super(message); }

    /// 미구현 예외처리
    public static class NotImplementException extends UserException {
        public NotImplementException() { super("Not Implement"); }
        public NotImplementException(String message) {
            super(message);
        }
        public NotImplementException(Throwable cause) {
            super("Not Implement", cause);
        }
        public NotImplementException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    /// URL Encoding 예외처리
    public static class URLEncodingException extends UserException {
        public URLEncodingException() { super("Failed to encode URL"); }
        public URLEncodingException(String message) { super(message); }
        public URLEncodingException(Throwable cause) { super("Failed to encode URL", cause); }
        public URLEncodingException(String message, Throwable cause) { super(message, cause); }
    }
}
