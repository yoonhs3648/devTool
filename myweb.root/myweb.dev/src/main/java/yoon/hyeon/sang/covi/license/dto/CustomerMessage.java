package yoon.hyeon.sang.covi.license.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class CustomerMessage {
    public CustomerMessage() { }

    @JsonProperty("page")
    private Page page;
    @JsonProperty("list")
    private List<ListItem> list;
    @JsonProperty("status")
    private String status;

    //region CustomerMessage GetterSetter
    public Page getPage() {
        return page;
    }

    public void setPage(Page page) {
        this.page = page;
    }

    public List<ListItem> getList() {
        return list;
    }

    public void setList(List<ListItem> list) {
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
    public static class Page {
        public Page() { }

        @JsonProperty("searchType")
        private String searchType;
        @JsonProperty("searchText")
        private String searchText;

        //region Page GetterSetter
        public String getSearchType() {
            return searchType;
        }

        public void setSearchType(String searchType) {
            this.searchType = searchType;
        }

        public String getSearchText() {
            return searchText;
        }

        public void setSearchText(String searchText) {
            this.searchText = searchText;
        }
        //endregion
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ListItem {
        public ListItem() { }

        @JsonProperty("MessageID")
        private String MessageID;
        @JsonProperty("Subject")
        private String Subject;
        @JsonProperty("CategoryName")
        private String CategoryName;

        //region Page ListItem
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

        public String getCategoryName() {
            return CategoryName;
        }

        public void setCategoryName(String categoryName) {
            CategoryName = categoryName;
        }
        //endregion
    }
}
