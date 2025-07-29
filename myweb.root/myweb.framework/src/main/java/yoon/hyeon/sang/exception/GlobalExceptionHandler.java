package yoon.hyeon.sang.exception;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

@ControllerAdvice
public class GlobalExceptionHandler {

    /*
    Spring은 예외 발생 시, @ExceptionHandler를 다음 순서로 찾습니다:
    1. 가장 구체적인 예외 타입 (@ExceptionHandler(ArithmeticException.class))
    2. 조금 더 상위 예외 타입 (@ExceptionHandler(RuntimeException.class))
    3. 가장 상위 타입 (@ExceptionHandler(Exception.class))

    @ExceptionHandler({ IOException.class, SQLException.class }) 처럼 여러 예외를 한번에 처리할 수 도 있다
    */

    private static final Logger logger = LogManager.getLogger(GlobalExceptionHandler.class);

    // 사용자 커스텀 예외 처리
    @ExceptionHandler(UserException.class)
    public void handleCustomException(UserException ex, HttpServletRequest request, HttpServletResponse response) throws IOException {
        String message = ex.getMessage() != null ? ex.getMessage() : "알 수 없는 오류가 발생했습니다. yoonhs3648@gmail.com에 문의하세요";
        logger.error(message, ex);
        handleErrorWithPopup(response, request, message, ex);
    }

    // 암복호화 커스텀 예외처리
    @ExceptionHandler(UserException.CryptoException.class)
    public void handleCryptoException(UserException ex, HttpServletRequest request, HttpServletResponse response) throws IOException {
        String message = ex.getMessage() != null ? ex.getMessage() : "알 수 없는 오류가 발생했습니다. yoonhs3648@gmail.com에 문의하세요";
        logger.error(message, ex);
        sendAlertScript(response, message);
    }

    // API관련 커스텀 예외 처리
    @ExceptionHandler(ApiException.class)
    public void handleApiException(ApiException ex, HttpServletRequest request, HttpServletResponse response) throws IOException {
        String message = ex.getMessage() != null ? ex.getMessage() : "알 수 없는 오류가 발생했습니다. yoonhs3648@gmail.com에 문의하세요";
        logger.error(message, ex);
        handleErrorWithPopup(response, request, message, ex);
    }

    // 공통 예외 처리
    @ExceptionHandler(Exception.class)
    public void handleAllExceptions(Exception ex, HttpServletRequest request, HttpServletResponse response) throws IOException {
        String message = ex.getMessage() != null ? ex.getMessage() : "알 수 없는 오류가 발생했습니다. yoonhs3648@gmail.com에 문의하세요";
        logger.error(message, ex);
        handleErrorWithPopup(response, request, message, ex);
    }

    // 런타임 예외 처리
    @ExceptionHandler(RuntimeException.class)
    public void handleRuntimeException(RuntimeException ex, HttpServletRequest request, HttpServletResponse response) throws IOException {
        String message = ex.getMessage() != null ? ex.getMessage() : "알 수 없는 오류가 발생했습니다. yoonhs3648@gmail.com에 문의하세요";
        logger.error(message, ex);
        handleErrorWithPopup(response, request, message, ex);
    }

    // 공통 alert 스크립트 출력
    private void sendAlertScript(HttpServletResponse response, String rawMessage) throws IOException {
        response.setContentType("text/html; charset=UTF-8");

        String message = rawMessage != null ? rawMessage : "오류가 발생했습니다.";
        message = message.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");

        String script = "<script>alert(\"" + message + "\");</script>";

        response.getWriter().write(script);
        response.getWriter().flush();
    }

    // 오류 팝업용 공통 처리
    private void handleErrorWithPopup(HttpServletResponse response, HttpServletRequest request, String message, Exception ex) throws IOException {
        response.setContentType("text/html; charset=UTF-8");

        String url = request.getRequestURL().toString();

        StringWriter sw = new StringWriter();
        ex.printStackTrace(new PrintWriter(sw));
        String fullTrace = sw.toString();

        StringBuilder script = new StringBuilder();

        script.append("<script type=\"text/javascript\" src=\"/core/resources/js/modalUtil.js\"></script>")
                .append("<script>")
                .append("const data = {")
                .append("  msg: `" + escapeForJS(message) + "`,")
                .append("  url: `" + escapeForJS(url) + "`,")
                .append("  trace: `" + escapeForJS(fullTrace) + "`")
                .append("};")

                .append("fetch('/core/errorPopup', {")
                .append("  method: 'POST',")
                .append("  headers: {")
                .append("    'Content-Type': 'application/json; charset=UTF-8'")
                .append("  },")
                .append("  body: JSON.stringify(data)")
                .append("})")
                .append(".then(response => response.text())")
                .append(".then(html => { showModal(html); })")

                .append("</script>");

        response.getWriter().write(script.toString());
    }

    private String escapeForJS(String input) {
        if (input == null) return "";
        return input
                .replace("\\", "\\\\")
                .replace("`", "\\`")
                .replace("\"", "\\\"")
                .replace("'", "\\'")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }

}
