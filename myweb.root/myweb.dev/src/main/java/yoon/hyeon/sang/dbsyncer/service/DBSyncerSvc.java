package yoon.hyeon.sang.dbsyncer.service;

import java.util.List;
import java.util.Map;

public interface DBSyncerSvc {
    public List<String> getDBList();
    public List<Map<String, Object>> getAllDBObjectList(String dbName);
    public String getDBObjectDDL(String dbName, String objectName, String objectType);

}
