package yoon.hyeon.sang.userObj;

import org.springframework.http.HttpHeaders;

public class ApiResponse {
    private final int statusCode;
    private final HttpHeaders responseHeaders;
    private final String responseBody;
    private final long durationMs;

    public ApiResponse(int statusCode, HttpHeaders responseHeaders, String responseBody, long durationMs) {
        this.statusCode = statusCode;
        this.responseHeaders = responseHeaders;
        this.responseBody = responseBody;
        this.durationMs = durationMs;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public HttpHeaders getResponseHeaders() {
        return responseHeaders;
    }

    public String getResponseBody() {
        return responseBody;
    }

    public long getDurationMs() {
        return durationMs;
    }

    public boolean isSuccess() {
        return statusCode >= 200 && statusCode < 300;
    }

    public boolean isRedirect() {
        return statusCode >= 300 && statusCode < 400;
    }

    public boolean isClientError() {
        return statusCode >= 400 && statusCode < 500;
    }

    public boolean isServerError() {
        return statusCode >= 500 && statusCode < 600;
    }

    @Override
    public String toString() {
        return "[HTTP " + statusCode + "] " + responseBody + " (in " + durationMs + "ms)";
    }
}
