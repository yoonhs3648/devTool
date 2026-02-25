package yoon.hyeon.sang.dbsyncer.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.dbsyncer.service.DBSyncerSvc;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class DBSyncerCon {

    @Autowired
    private DBSyncerSvc dbSyncerSvc;

    @RequestMapping(value = "/dbSyncer", method = RequestMethod.GET)
    public ModelAndView goPage() {
        String returnURL = "dbSyncer/dbSyncer";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return mv;
    }

    @RequestMapping(value = "/dbDiff", method = RequestMethod.POST)
    public @ResponseBody Map<String, Object> diff(@RequestParam("file") MultipartFile ddlFile) {
        Map<String, Object> result = new HashMap<>();

        return result;
    }


    @RequestMapping(value = "/dbSyncerTest", method = RequestMethod.GET)
    public @ResponseBody Map<String, Object> dbSyncerTest(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();

        List<String> dbList = dbSyncerSvc.getDBList();
        for (String dbName : dbList) {
            List<Map<String, Object>> dbObjectList = dbSyncerSvc.getAllDBObjectList(dbName);

            for (Map<String, Object> dbObject : dbObjectList) {
                String objectName = dbObject.get("OBJ_NAME").toString();
                String objectType = dbObject.get("OBJ_TYPE").toString();

                String ddlList = dbSyncerSvc.getDBObjectDDL(dbName, objectName, objectType);
            }
        }
        return result;
    }

    @RequestMapping(value = "/dbSyncerTest1", method = RequestMethod.GET)
    public @ResponseBody Map<String, Object> dbSyncerTest1(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();

        List<String> dbList = dbSyncerSvc.getDBList();

        result.put("data", dbList);
        return result;
    }
    @RequestMapping(value = "/dbSyncerTest2", method = RequestMethod.GET)
    public @ResponseBody Map<String, Object> dbSyncerTest2(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();

        String dbName = "messenger";
        List<Map<String, Object>> dbObjectList = dbSyncerSvc.getAllDBObjectList(dbName);

        result.put("data", dbObjectList);
        return result;
    }

    @RequestMapping(value = "/dbSyncerTest3", method = RequestMethod.GET)
    public @ResponseBody Map<String, Object> dbSyncerTest3(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();

        String dbName = "messenger";
        String objectName = "MESSAGE";
        String objectType = "TABLE";

        String ddlList = dbSyncerSvc.getDBObjectDDL(dbName, objectName, objectType);

        result.put("data", ddlList);
        return result;
    }
}
