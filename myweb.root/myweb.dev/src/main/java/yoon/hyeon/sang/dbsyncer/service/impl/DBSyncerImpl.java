package yoon.hyeon.sang.dbsyncer.service.impl;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import yoon.hyeon.sang.dbsyncer.service.DBSyncerSvc;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Service
public class DBSyncerImpl implements DBSyncerSvc {

    @Autowired
    private SqlSessionTemplate sqlSession;

    @Override
    public List<String> getDBList() {
        List<String> dbList = sqlSession.selectList("dbInfo.selectAllDBs");
        return dbList;
    }

    @Override
    public List<Map<String, Object>> getAllDBObjectList(String dbName) {
        List<Map<String, Object>> objects = sqlSession.selectList("dbInfo.selectAllObjects", dbName);

        return objects;
    }

    @Override
    public String getDBObjectDDL(String dbName, String objectName, String objectType) {

        List<String> ddls = new ArrayList<>();
        String query = buildShowCreateQuery(dbName, objectType, objectName);
        Map<String, Object> result =  sqlSession.selectOne("dbInfo.selectDDL", query);

        String ddl = (String) result.get("Create Table");
        // 혹시 모를 대비 (DB마다 컬럼명 대소문자 이슈 방지)
        if (ddl == null) {
            for (Map.Entry<String, Object> entry : result.entrySet()) {
                if (entry.getValue() instanceof String &&
                        ((String) entry.getValue()).startsWith("CREATE")) {
                    ddl = (String) entry.getValue();
                    break;
                }
            }
        }
        return ddl;
    }

    private String buildShowCreateQuery(String dbName, String type, String name) {

        switch (type) {
            case "TABLE":
                return "SHOW CREATE TABLE `" + dbName + "`.`" + name + "`";
            case "VIEW":
                return "SHOW CREATE VIEW `" + dbName + "`.`" + name + "`";
            case "PROCEDURE":
                return "SHOW CREATE PROCEDURE `" + dbName + "`.`" + name + "`";
            case "FUNCTION":
                return "SHOW CREATE FUNCTION `" + dbName + "`.`" + name + "`";
            case "TRIGGER":
                return "SHOW CREATE TRIGGER `" + dbName + "`.`" + name + "`";
            case "EVENT":
                return "SHOW CREATE EVENT `" + dbName + "`.`" + name + "`";
            default:
                throw new IllegalArgumentException("Unknown type: " + type);
        }
    }

    private String extractDDL(Map<String, Object> result) {
        for (Object value : result.values()) {
            if (value instanceof String && ((String) value).startsWith("CREATE")) {
                return value.toString();
            }
        }
        return null;
    }
}