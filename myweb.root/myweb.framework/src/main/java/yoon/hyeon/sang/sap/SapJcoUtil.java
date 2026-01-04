package yoon.hyeon.sang.sap;

import com.sap.conn.jco.*;
import com.sap.conn.jco.ext.DestinationDataProvider;
import com.sap.conn.jco.ext.Environment;
import yoon.hyeon.sang.exception.UserException;
import com.sap.conn.jco.JCoMetaData;
import yoon.hyeon.sang.sap.dto.RFCFieldMetaData;
import yoon.hyeon.sang.sap.dto.RFCFunctionMetaData;
import yoon.hyeon.sang.sap.dto.RFCParamMetaData;
import yoon.hyeon.sang.sap.dto.SAPEnums;

import java.util.*;
import java.util.concurrent.atomic.AtomicBoolean;

import static yoon.hyeon.sang.util.HashingUtil.sha256;

public class SapJcoUtil {

    // Provider 등록 상태 플래그
    private static final AtomicBoolean providerRegistered = new AtomicBoolean(false);
    private static final MyDestinationDataProvider provider = MyDestinationDataProvider.getInstance();

    /// SAP Destination 생성
    public static JCoDestination createDestination(String ashost, String sysnr, String client, String user, String passwd, String lang) throws JCoException {

        /*
        1. provider등록 (최초1회. jvm은 하나의 provider만 허용한다)
        2. destination 이름 및 접속정보 준비 (요청마다)
        3. provider에 destination 정보 등록 (요청마다)
        4. provider를 통해 jco가 JCOdestination 객체 생성 (요청마다)
         */

        //Provider(Destination 정보를 제공하는 주체)를 JVM에 한 번만 등록
        if (providerRegistered.compareAndSet(false, true)) {
            try {
                Environment.registerDestinationDataProvider(provider);  //기존에 등록안되어 있으면 provider 등록
            } catch (IllegalStateException ex) {
                throw new UserException.SAPException("provider를 등록할 수 없습니다. " + ex);
            }
        }

        //Destination 이름 생성
        //JCoDestinationManager는 destName 기준으로 Destination을 캐싱한다 -> provider에 동일한 destName이 있으면 새로운 destination접속정보로 등록하는게 의미없다
        String destName = ashost + "_" + sysnr + "_" + client + "_" + user + "_" + sha256(passwd) + "_" + lang;

        //destination 접속정보 설정
        Properties connectProperties = new Properties();
        connectProperties.setProperty(DestinationDataProvider.JCO_ASHOST, ashost);
        connectProperties.setProperty(DestinationDataProvider.JCO_SYSNR, sysnr);
        connectProperties.setProperty(DestinationDataProvider.JCO_CLIENT, client);
        connectProperties.setProperty(DestinationDataProvider.JCO_USER, user);
        connectProperties.setProperty(DestinationDataProvider.JCO_PASSWD, passwd);
        connectProperties.setProperty(DestinationDataProvider.JCO_LANG, lang);

        connectProperties.setProperty(DestinationDataProvider.JCO_POOL_CAPACITY, "3");
        connectProperties.setProperty(DestinationDataProvider.JCO_PEAK_LIMIT, "5");

        //provider에 destination 정보 등록
        synchronized (SapJcoUtil.class) {
            provider.addDestination(destName, connectProperties);
        }

        //JCOdestination 객체생성
        return JCoDestinationManager.getDestination(destName);
    }

    public static RFCFunctionMetaData analyzeRFCFunction(JCoDestination destination, String functionName) throws JCoException {
        JCoRepository repo = destination.getRepository();
        repo.clear();
        JCoFunction function = repo.getFunction(functionName);
        if (function == null) {
            throw new RuntimeException("RFC 함수 없음: " + functionName);
        }

        RFCFunctionMetaData meta = new RFCFunctionMetaData();
        meta.setFunctionName(functionName);

        meta.setImportParams(extractParams(function.getImportParameterList(), SAPEnums.RFCParamKind.IMPORT));
        meta.setExportParams(extractParams(function.getExportParameterList(), SAPEnums.RFCParamKind.EXPORT));
        meta.setTableParams(extractParams(function.getTableParameterList(), SAPEnums.RFCParamKind.TABLE));

        return meta;
    }

    private static List<RFCParamMetaData> extractParams(JCoParameterList paramList, SAPEnums.RFCParamKind kind) {
        List<RFCParamMetaData> result = new ArrayList<>();
        if (paramList == null) return result;

        JCoMetaData meta = paramList.getMetaData();

        for (int i = 0; i < meta.getFieldCount(); i++) {
            String paramName = meta.getName(i);
            int type = meta.getType(i);

            RFCParamMetaData param = new RFCParamMetaData();
            param.setName(paramName);
            param.setDescription(meta.getDescription(i));
            param.setKind(kind);
            param.setMandatory(SAPEnums.MandatoryType.UNKNOWN);     //필수여부는 JCoMetaData에서 제공하지않음

            if (type == JCoMetaData.TYPE_STRUCTURE) {   // STRUCTURE
                param.setDataType(SAPEnums.RFCDataType.STRUCTURE);

                JCoStructure structure = paramList.getStructure(paramName);
                param.setFields(extractFields(structure.getMetaData()));
            }
            else if (type == JCoMetaData.TYPE_TABLE) {  // TABLE
                param.setDataType(SAPEnums.RFCDataType.TABLE);

                JCoTable table = paramList.getTable(paramName);
                param.setFields(extractFields(table.getMetaData()));
            }
            else {  // String
                param.setDataType(SAPEnums.RFCDataType.STRING);
                param.setSapType(meta.getTypeAsString(i));  // 파라미터 데이터 타입 (CHAR, NUMC, DATS, TIMS, CURR, DEC 타입등 변환 전 원본 SAP타입. 자바의 데이터타입은 아니다)
                param.setLength(meta.getLength(i));         // 파라미터 길이(Length)
                param.setDecimals(meta.getDecimals(i));     // 파라미터 소수점 자리수 (DEC, CURR, QUAN 타입에서 의미있음. CHAR, NUMC 타입은 보통 0)
            }

            result.add(param);
        }

        return result;
    }

    private static List<RFCFieldMetaData> extractFields(JCoMetaData meta) {
        List<RFCFieldMetaData> fields = new ArrayList<>();

        for (int i = 0; i < meta.getFieldCount(); i++) {
            RFCFieldMetaData field = new RFCFieldMetaData();

            field.setName(meta.getName(i));                 // 필드명
            field.setDescription(meta.getDescription(i));   // 필드 설명(주석)
            field.setSapType(meta.getTypeAsString(i));      // 필드 데이터 타입 (CHAR, NUMC, DATS, TIMS, CURR, DEC 타입등 변환 전 원본 SAP타입. 자바의 데이터타입은 아니다)
            field.setLength(meta.getLength(i));             // 필드 길이(Length)
            field.setDecimals(meta.getDecimals(i));         // 필드 소수점 자리수 (DEC, CURR, QUAN 타입에서 의미있음. CHAR, NUMC 타입은 보통 0)
            field.setMandatory(SAPEnums.MandatoryType.UNKNOWN);     //필수여부는 JCoMetaData에서 제공하지않음

            fields.add(field);
        }

        return fields;
    }






    /// 전처리 . be Deprecated
    public static JCoFunction prepareRfcFunction(JCoDestination destination, String functionName, Map<String, Object> importParams, Map<String, List<Map<String, Object>>> tableParams) throws JCoException {
        JCoRepository repo = destination.getRepository();
        repo.clear();
        JCoFunction function = repo.getFunction(functionName);

        if (function == null)
            throw new UserException.SAPException("RFC 함수 없음: " + functionName);

        // IMPORT 파라미터 검증 및 세팅
        JCoParameterList importList = function.getImportParameterList();
        if (importList != null && importParams != null) {

            JCoMetaData meta = importList.getMetaData();

            //필수 파라미터 누락 체크는 execute 전에 체크하는 기능을 제공하지않음. 이 케이스는 RFC Call하고 예외 반환

            //불필요한 파라미터 존재 체크
            for (String key : importParams.keySet()) {
                if (!meta.hasField(key)) {
                    throw new UserException.SAPException("정의되지 않은 Import 파라미터: " + key);
                }
            }

            //Import 파라미터 값 할당
            for (String key : importParams.keySet()) {
                importList.setValue(key, importParams.get(key));
            }
        }

        // Table 파라미터 검증 및 세팅
        JCoParameterList tableList = function.getTableParameterList();
        if (tableList != null && tableParams != null) {

            JCoMetaData tableMeta = tableList.getMetaData();

            //필수 파라미터 누락 체크는 execute 전에 체크하는 기능을 제공하지않음. 이 케이스는 RFC Call하고 예외 반환

            //불필요한 파라미터 존재 체크
            for (String tableName : tableParams.keySet()) {
                if (!tableMeta.hasField(tableName)) {
                    throw new UserException.SAPException("정의되지 않은 Table 파라미터: " + tableName);
                }
            }

            //TABLE파라미터 값 할당 및 TABLE파라미터 내 컬럼 검증
            for (Map.Entry<String, List<Map<String, Object>>> tableEntry : tableParams.entrySet()) {

                String tableName = tableEntry.getKey();
                List<Map<String, Object>> rows = tableEntry.getValue();

                JCoTable jcoTable = tableList.getTable(tableName);
                JCoMetaData rowMeta = jcoTable.getMetaData();

                for (Map<String, Object> row : rows) {

                    //TABLE 파라미터 내 컬럼 검증
                    for (String colName : row.keySet()) {
                        if (!rowMeta.hasField(colName)) {
                            throw new UserException.SAPException("Table [" + tableName + "] 에 정의되지 않은 컬럼: " + colName);
                        }
                    }

                    //TABLE 파라미터 값 할당
                    jcoTable.appendRow();
                    for (Map.Entry<String, Object> col : row.entrySet()) {
                        jcoTable.setValue(col.getKey(), col.getValue());
                    }
                }
            }
        }

        return function;
    }

    /// RFC 호출
    public static Map<String, Object> executeRFC(JCoDestination destination, JCoFunction function) throws JCoException {
        Map<String, Object> output = new HashMap<>();

        // 실행
        function.execute(destination);

        // EXPORT
        Map<String, Object> exportMap = new HashMap<>();
        JCoParameterList exportList = function.getExportParameterList();
        if (exportList != null) {
            for (JCoField f : exportList) {
                exportMap.put(f.getName(), f.getValue());
            }
        }

        // TABLE
        Map<String, Object> returnTableMap = new HashMap<>();
        JCoParameterList returnTableList = function.getTableParameterList();
        if (returnTableList != null) {
            for (JCoField tableField : returnTableList) {

                JCoTable table = tableField.getTable();
                List<Map<String, Object>> rows = new ArrayList<>();

                for (int i = 0; i < table.getNumRows(); i++) {
                    table.setRow(i);

                    Map<String, Object> row = new HashMap<>();
                    for (JCoField col : table) {
                        row.put(col.getName(), col.getValue());
                    }
                    rows.add(row);
                }

                returnTableMap.put(tableField.getName(), rows);
            }
        }

        output.put("EXPORT", exportMap);
        output.put("TABLE", returnTableMap);

        return output;
    }
}
