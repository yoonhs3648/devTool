package yoon.hyeon.sang.translator.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TranslateFileResponse {

    public TranslateFileResponse() {
    }

    @JsonProperty("document_id")
    private String docId;    //문서아이디

    @JsonProperty("document_key")
    private String docKey;    //문서키

    private int fileSize;

    @JsonProperty("status")
    private String fileStatus;  //문서번역 상태값 (queued, translating, done, error)

    @JsonProperty("seconds_remaining")
    private int remainSec;  //문서번역 완료까지 남은 시간

    @JsonProperty("billed_characters")
    private int charUsage;  //문서번역에 소비된 사용량

    @JsonProperty("error_message")
    private String errMsg;  //에러메세지

    private String message; //API문서에 정의되어있지않은데 response로 내려옴. deserialize 실패 예외 방지를 위해 정의

    public String getDocId() {
        return docId;
    }

    public void setDocId(String docId) {
        this.docId = docId;
    }

    public String getDocKey() {
        return docKey;
    }

    public void setDocKey(String docKey) {
        this.docKey = docKey;
    }


    public int getFileSize() {
        return fileSize;
    }

    public void setFileSize(int fileSize) {
        this.fileSize = fileSize;
    }

    public String getFileStatus() {
        return fileStatus;
    }

    public void setFileStatus(String fileStatus) {
        this.fileStatus = fileStatus;
    }

    public int getRemainSec() {
        return remainSec;
    }

    public void setRemainSec(int remainSec) {
        this.remainSec = remainSec;
    }

    public int getCharUsage() {
        return charUsage;
    }

    public void setCharUsage(int charUsage) {
        this.charUsage = charUsage;
    }

    public String getErrMsg() {
        return errMsg;
    }

    public void setErrMsg(String errMsg) {
        this.errMsg = errMsg;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
