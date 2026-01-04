package yoon.hyeon.sang.sap.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.JCoFunction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.sap.dto.RFCFunctionMetaData;
import yoon.hyeon.sang.sap.service.SAPSvc;
import yoon.hyeon.sang.sap.SapJcoUtil;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class SAPCon {

    @Autowired
    private SAPSvc SAPSvc;

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

        Map<String, Object> result = new HashMap<>();

        try {
            // SAP Destination 생성 (Destination = 원격 시스템 접속 정보 객체)
            JCoDestination destination = SapJcoUtil.createDestination(ashost, sysnr, client, user, passwd, lang);

            RFCFunctionMetaData rfcMeta = SapJcoUtil.analyzeRFCFunction(destination, functionName);
            result.put("functionName", rfcMeta.getFunctionName());
            result.put("importParams", rfcMeta.getImportParams());
            result.put("exportParams", rfcMeta.getExportParams());
            result.put("tableParams", rfcMeta.getTableParams());
            result.put("status", "OK");
        } catch (JCoException je) {
            result.put("status", "ERROR");
            result.put("errKey", je.getKey());
            result.put("message", je.getMessage());
            result.put("detailMessage", je.getCause());
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", e.getMessage());
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

        String paramsJson = (String) params.get("params");
        String tablesJson = (String) params.get("tables");

        Map<String, Object> result = new HashMap<>();

        try {
            ObjectMapper mapper = new ObjectMapper();

            // Import파라미터 Map 변환
            Map<String, Object> importParams = mapper.readValue(paramsJson, Map.class);

            // Table파라미터 Map 변환
            Map<String, List<Map<String, Object>>> tableParams = new HashMap<>();
            if (tablesJson != null && !tablesJson.isEmpty()) {
                tableParams = mapper.readValue(tablesJson, new TypeReference<Map<String, List<Map<String, Object>>>>() {});
            }

            // SAP Destination 생성 (Destination = 원격 시스템 접속 정보 객체)
            JCoDestination destination = SapJcoUtil.createDestination(ashost, sysnr, client, user, passwd, lang);

            // SAP 전처리 (RFC함수 객체 생성)
            JCoFunction function = SapJcoUtil.prepareRfcFunction(destination, functionName, importParams, tableParams);

            // RFC 호출
            result.put("result", SapJcoUtil.executeRFC(destination, function));
            result.put("status", "OK");
        } catch (JCoException je) {
            result.put("status", "ERROR");
            result.put("errKey", je.getKey());
            result.put("message", je.getMessage());
            result.put("detailMessage", je.getCause());
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", e.getMessage());
        }

        return result;
    }
}
