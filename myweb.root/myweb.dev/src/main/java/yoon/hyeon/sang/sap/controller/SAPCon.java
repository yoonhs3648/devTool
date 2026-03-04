package yoon.hyeon.sang.sap.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.JCoFunction;
import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.Marker;
import org.apache.logging.log4j.MarkerManager;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.sap.SapJcoUtil;
import yoon.hyeon.sang.sap.dto.RFCFunctionMetaData;
import yoon.hyeon.sang.sap.service.SAPSvc;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class SAPCon {

    @Autowired
    private SAPSvc SAPSvc;

    private final Logger logger;
    private static final Marker SAP_MAKER = MarkerManager.getMarker("SAP");

    private static final Gson gson = new Gson();

    public SAPCon() {
        this.logger = LogManager.getLogger(this.getClass());
    }

    @RequestMapping(value = "/sap", method = RequestMethod.GET)
    public ModelAndView goPage() {
        String returnURL = "sap/rfccall";
        ModelAndView mv = new ModelAndView();
        mv.setViewName(returnURL);
        return mv;
    }

    @RequestMapping(value = "/getSAPMeta", method = RequestMethod.POST)
    public @ResponseBody Map<String, Object> getSAPMeta(@RequestBody Map<String, String> params, HttpServletRequest request) {
        String ashost = (String) params.get("ashost");
        String sysnr = (String) params.get("sysnr");
        String client = (String) params.get("client");
        String user = (String) params.get("user");
        String passwd = (String) params.get("passwd");
        String lang = params.get("lang") == null || ((String) params.get("lang")).trim().isEmpty() ? "KO" : (String) params.get("lang");
        String functionName = (String) params.get("functionName");

        //SAP RequestInfo Logging
        logger.debug(SAP_MAKER, "== [SAP MetaData Request] ==");
        logger.debug(SAP_MAKER, "ashost : {}", ashost);
        logger.debug(SAP_MAKER, "sysnr : {}", sysnr);
        logger.debug(SAP_MAKER, "client : {}", client);
        logger.debug(SAP_MAKER, "user : {}", user);
        logger.debug(SAP_MAKER, "passwd : {}", "????");
        logger.debug(SAP_MAKER, "lang : {}", lang);
        logger.debug(SAP_MAKER, "functionName : {}", functionName);
        logger.debug(SAP_MAKER, "================");

        Map<String, Object> result = new HashMap<>();

        try {
            // SAP Destination 생성 (Destination = 원격 시스템 접속 정보 객체)
            JCoDestination destination = SapJcoUtil.createDestination(ashost, sysnr, client, user, passwd, lang);

            RFCFunctionMetaData rfcMeta = SapJcoUtil.analyzeRFCFunction(destination, functionName);

            //SapJcoUtil.setImportStructureParamForTest(rfcMeta); //Import파라미터에 임의의 구조체파라미터 추가하는 test코드
            //SapJcoUtil.setExportStructureParamForTest(rfcMeta); //Export파라미터에 임의의 구조체파라미터 추가하는 test코드
            //SapJcoUtil.setTableParamForTest(rfcMeta); //table파라미터 추가하는 test코드

            result.put("functionName", rfcMeta.getFunctionName());
            result.put("functionDescription", rfcMeta.getFunctionDescription());
            result.put("importParams", rfcMeta.getImportParams());
            result.put("exportParams", rfcMeta.getExportParams());
            result.put("tableParams", rfcMeta.getTableParams());
            result.put("status", "OK");

            //SAP Response Logging
            logger.debug(SAP_MAKER, "== [SAP MetaData Response Success] ==");
            logger.debug(SAP_MAKER, "functionName : {}", rfcMeta.getFunctionName());
            logger.debug(SAP_MAKER, "functionDescription : {}", rfcMeta.getFunctionDescription());
            logger.debug(SAP_MAKER, "importParams : {}", gson.toJson(rfcMeta.getImportParams()));
            logger.debug(SAP_MAKER, "exportParams : {}", gson.toJson(rfcMeta.getExportParams()));
            logger.debug(SAP_MAKER, "tableParams : {}", gson.toJson(rfcMeta.getTableParams()));
            logger.debug(SAP_MAKER, "================");
        } catch (JCoException je) {
            result.put("status", "ERROR");
            result.put("errKey", je.getKey());
            result.put("message", je.getMessage());
            result.put("detailMessage", je.getCause() != null ? je.getCause().getMessage() : "");

            //SAP ERROR Response Logging
            logger.error(SAP_MAKER, "== [SAP MetaData Response ERROR] ==");
            logger.error(SAP_MAKER, "status : {}", "ERROR");
            logger.error(SAP_MAKER, "errKey : {}", je.getKey());
            logger.error(SAP_MAKER, "message : {}", je.getMessage());
            logger.error(SAP_MAKER, "SAP Exception Stacktrace: ", je);
            logger.error(SAP_MAKER, "================");
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", e.getMessage());

            //SAP ERROR Response Logging
            logger.error(SAP_MAKER, "== [SAP MetaData Response ERROR] ==");
            logger.error(SAP_MAKER, "status : {}", "ERROR");
            logger.error(SAP_MAKER, "message : {}", e.getMessage());
            logger.error(SAP_MAKER, "SAP Exception Stacktrace: ", e);
            logger.error(SAP_MAKER, "================");
        }

        return result;
    }

    @RequestMapping(value = "/callRFC", method = RequestMethod.POST)
    public @ResponseBody Map<String, Object> callRFC(@RequestBody Map<String, String> params, HttpServletRequest request) {
        String ashost = (String) params.get("ashost");
        String sysnr = (String) params.get("sysnr");
        String client = (String) params.get("client");
        String user = (String) params.get("user");
        String passwd = (String) params.get("passwd");
        String lang = params.get("lang") == null || ((String) params.get("lang")).trim().isEmpty() ? "KO" : (String) params.get("lang");
        String functionName = (String) params.get("functionName");

        String importJson = (String) params.get("importParams");
        String tablesJson = (String) params.get("tableParams");

        //SAP RequestInfo Logging
        logger.debug(SAP_MAKER, "== [SAP Request] ==");
        logger.debug(SAP_MAKER, "ashost : {}", ashost);
        logger.debug(SAP_MAKER, "sysnr : {}", sysnr);
        logger.debug(SAP_MAKER, "client : {}", client);
        logger.debug(SAP_MAKER, "user : {}", user);
        logger.debug(SAP_MAKER, "passwd : {}", "????");
        logger.debug(SAP_MAKER, "lang : {}", lang);
        logger.debug(SAP_MAKER, "functionName : {}", functionName);
        logger.debug(SAP_MAKER, "importJson : {}", importJson);
        logger.debug(SAP_MAKER, "tablesJson : {}", tablesJson);
        logger.debug(SAP_MAKER, "================");

        Map<String, Object> result = new HashMap<>();

        try {
            ObjectMapper mapper = new ObjectMapper();

            // Import파라미터
            List<Map<String, Object>> importParams = mapper.readValue(importJson, new TypeReference<List<Map<String, Object>>>() {});

            // Table파라미터
            List<Map<String, Object>> tableParams = new ArrayList<>();
            if (tablesJson != null && !tablesJson.isEmpty()) {
                tableParams = mapper.readValue(tablesJson, new TypeReference<List<Map<String, Object>>>() {});
            }

            // SAP Destination 생성 (Destination = 원격 시스템 접속 정보 객체)
            JCoDestination destination = SapJcoUtil.createDestination(ashost, sysnr, client, user, passwd, lang);

            // SAP 전처리 (RFC함수 객체 생성)
            JCoFunction function = SapJcoUtil.prepareRfcFunction(destination, functionName, importParams, tableParams);

            // RFC 호출
            Map<String, Object> rfcResult = SapJcoUtil.executeRFC(destination, function);
            result.put("result", rfcResult);
            result.put("status", "OK");

            //SAP Response Logging
            logger.debug(SAP_MAKER, "== [SAP Response Success] ==");
            logger.debug(SAP_MAKER, "functionName : {}", functionName);
            logger.debug(SAP_MAKER, "exportParams : {}", gson.toJson(rfcResult.get("EXPORT")));
            logger.debug(SAP_MAKER, "tableParams : {}", gson.toJson(rfcResult.get("TABLE")));
            logger.debug(SAP_MAKER, "================");
        } catch (JCoException je) {
            result.put("status", "ERROR");
            result.put("errKey", je.getKey());
            result.put("message", je.getMessage());
            result.put("detailMessage", je.getCause() != null ? je.getCause().getMessage() : "");

            //SAP ERROR Response Logging
            logger.error(SAP_MAKER, "== [SAP Response ERROR] ==");
            logger.error(SAP_MAKER, "status : {}", "ERROR");
            logger.error(SAP_MAKER, "errKey : {}", je.getKey());
            logger.error(SAP_MAKER, "message : {}", je.getMessage());
            logger.error(SAP_MAKER, "SAP Exception Stacktrace: ", je);
            logger.error(SAP_MAKER, "================");
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", e.getMessage());

            //SAP ERROR Response Logging
            logger.error(SAP_MAKER, "== [SAP Response ERROR] ==");
            logger.error(SAP_MAKER, "status : {}", "ERROR");
            logger.error(SAP_MAKER, "message : {}", e.getMessage());
            logger.error(SAP_MAKER, "SAP Exception Stacktrace: ", e);
            logger.error(SAP_MAKER, "================");
        }

        return result;
    }

    @RequestMapping(value = "/makeInterfaceExcel", method = RequestMethod.POST)
    public void makeInterfaceExcel(@RequestBody Map<String, Object> params, HttpServletRequest request, HttpServletResponse response) throws Exception {
        Map<String, Object> result = new HashMap<>();

        String jsonStr = (String) params.get("data");

        try {
            Workbook workbook = SAPSvc.makeInterfaceExcel(jsonStr);

            JsonObject jsonObj = gson.fromJson(jsonStr, JsonObject.class);
            String functionName = jsonObj.get("functionName").getAsString();
            functionName = functionName.concat("_인터페이스_명세서");
            String encodedFileName = URLEncoder.encode(functionName, "UTF-8").replaceAll("\\+", "%20");

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            workbook.write(bos);
            workbook.close();

            response.setHeader("Content-Disposition","attachment; filename=\"" + encodedFileName + "\"");
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

            try (ServletOutputStream out = response.getOutputStream()) {
                out.write(bos.toByteArray());
                out.flush();
            }
        } catch(Exception e) {
            response.reset();
            response.setContentType("application/json;charset=UTF-8");

            result.put("status", "ERROR");
            result.put("message", e.getMessage());
            result.put("detailMessage", e.getCause() != null ? e.getCause().getMessage() : "");
            String json = gson.toJson(result);
            response.getWriter().write(json);
        }
    }
}
