package yoon.hyeon.sang.covi.license.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class CustomerMessageDetail {
    public CustomerMessageDetail() {    }

    @JsonProperty("list")
    private List list;
    @JsonProperty("status")
    private String status;

    //region CustomerMessageDetail GetterSetter
    public List getList() {
        return list;
    }

    public void setList(List list) {
        this.list = list;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    //endregion

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class List {
        public List() {        }

        @JsonProperty("MessageID")
        private String MessageID;
        @JsonProperty("Subject")
        private String Subject;
        @JsonProperty("Body")
        private String Body;

        //region List GetterSetter
        public String getMessageID() {
            return MessageID;
        }

        public void setMessageID(String messageID) {
            MessageID = messageID;
        }

        public String getSubject() {
            return Subject;
        }

        public void setSubject(String subject) {
            Subject = subject;
        }

        public String getBody() {
            return Body;
        }

        public void setBody(String body) {
            Body = body;
        }
        //endregion
    }
}
