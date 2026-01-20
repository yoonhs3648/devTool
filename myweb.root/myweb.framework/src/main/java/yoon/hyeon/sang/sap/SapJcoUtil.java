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

    /// RFC function 전처리
    public static JCoFunction prepareRfcFunction(JCoDestination destination, String functionName, List<Map<String, Object>> importParams, List<Map<String, Object>> tableParams) throws JCoException {
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

            for (Map<String, Object> param : importParams) {
                String dataType = (String) param.get("dataType");

                //스칼라 파라미터
                if ("STRING".equals(dataType)) {
                    String key = (String) param.get("key");

                    if (!meta.hasField(key)) {
                        throw new UserException.SAPException("정의되지 않은 Import 파라미터: " + key);
                    }

                    importList.setValue(key, param.get("value"));
                }

                //STRUCTURE 파라미터
                else if ("STRUCTURE".equals(dataType)) {
                    String structName = (String) param.get("name");

                    if (!meta.hasField(structName)) {
                        throw new UserException.SAPException("정의되지 않은 Import 구조체: " + structName);
                    }

                    JCoStructure structure = importList.getStructure(structName);
                    if (structure == null) {
                        throw new UserException.SAPException("구조체 파라미터 아님: " + structName);
                    }

                    List<Map<String, Object>> fields = (List<Map<String, Object>>) param.get("fields");
                    for (Map<String, Object> field : fields) {
                        String fieldName = (String) field.get("key");
                        if (!structure.getMetaData().hasField(fieldName)) {
                            throw new UserException.SAPException("정의되지 않은 STRUCTURE 필드: " + structName + "." + fieldName);
                        }

                        structure.setValue(fieldName, field.get("value"));
                    }
                }
            }
        }

        // Table 파라미터 검증 및 세팅
        JCoParameterList tableList = function.getTableParameterList();
        if (tableList != null && tableParams != null) {

            JCoMetaData tableMeta = tableList.getMetaData();

            //필수 파라미터 누락 체크는 execute 전에 체크하는 기능을 제공하지않음. 이 케이스는 RFC Call하고 예외 반환
            for (Map<String, Object> tableParam : tableParams) {
                String tableName = (String) tableParam.get("name");

                if (!tableMeta.hasField(tableName)) {
                    throw new UserException.SAPException("정의되지 않은 Table 파라미터: " + tableName);
                }

                JCoTable jcoTable = tableList.getTable(tableName);
                JCoMetaData rowMeta = jcoTable.getMetaData();

                List<Map<String, Object>> rows = (List<Map<String, Object>>) tableParam.get("rows");

                for (Map<String, Object> row : rows) {
                    jcoTable.appendRow();
                    List<Map<String, Object>> fields = (List<Map<String, Object>>) row.get("fields");

                    for (Map<String, Object> field : fields) {
                        String colName = (String) field.get("key");
                        if (!rowMeta.hasField(colName)) {
                            throw new UserException.SAPException("Table [" + tableName + "] 에 정의되지 않은 필드: " + colName);
                        }

                        jcoTable.setValue(colName, field.get("value"));
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

    // test용 import structure param생성
    public static void setImportStructureParamForTest(RFCFunctionMetaData rfcMeta) {
        List<RFCParamMetaData> importParams = rfcMeta.getImportParams();
        if (importParams == null) {
            importParams = new ArrayList<>();
            rfcMeta.setImportParams(importParams);
        }

        //STRUCTURE #1
        RFCParamMetaData struct1 = new RFCParamMetaData();
        struct1.setName("TEST_STRUCT_1");
        struct1.setDescription("테스트용 구조체 1 주석입니다");
        struct1.setKind(SAPEnums.RFCParamKind.IMPORT);
        struct1.setDataType(SAPEnums.RFCDataType.STRUCTURE);
        struct1.setMandatory(SAPEnums.MandatoryType.REQUIRED);

        List<RFCFieldMetaData> struct1Fields = new ArrayList<>();

        RFCFieldMetaData s1f1 = new RFCFieldMetaData();
        s1f1.setName("TEST_FIELD_A");
        s1f1.setDescription("아무 의미 없는 값 A");
        s1f1.setSapType("CHAR");
        s1f1.setLength(10);
        s1f1.setDecimals(0);
        s1f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s1f2 = new RFCFieldMetaData();
        s1f2.setName("TEST_FIELD_B");
        s1f2.setDescription("아무 의미 없는 값 B");
        s1f2.setSapType("NUMC");
        s1f2.setLength(6);
        s1f2.setDecimals(0);
        s1f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        struct1Fields.add(s1f1);
        struct1Fields.add(s1f2);
        struct1.setFields(struct1Fields);

        //STRUCTURE #2
        RFCParamMetaData struct2 = new RFCParamMetaData();
        struct2.setName("TEST_STRUCT_2");
        struct2.setDescription("테스트용 구조체 2 description");
        struct2.setKind(SAPEnums.RFCParamKind.IMPORT);
        struct2.setDataType(SAPEnums.RFCDataType.STRUCTURE);
        struct2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        List<RFCFieldMetaData> struct2Fields = new ArrayList<>();

        RFCFieldMetaData s2f1 = new RFCFieldMetaData();
        s2f1.setName("FAKE_NUMBER");
        s2f1.setDescription("숫자인척하는 값");
        s2f1.setSapType("CURR");
        s2f1.setLength(15);
        s2f1.setDecimals(3);
        s2f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s2f2 = new RFCFieldMetaData();
        s2f2.setName("FAKE_TEXT");
        s2f2.setDescription("문자인척하는 값");
        s2f2.setSapType("CHAR");
        s2f2.setLength(20);
        s2f2.setDecimals(0);
        s2f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        struct2Fields.add(s2f1);
        struct2Fields.add(s2f2);
        struct2.setFields(struct2Fields);


        //STRUCTURE #3
        RFCParamMetaData struct3 = new RFCParamMetaData();
        struct3.setName("TEST_STRUCT_3 desc");
        struct3.setDescription("테스트용 구조체 3");
        struct3.setKind(SAPEnums.RFCParamKind.IMPORT);
        struct3.setDataType(SAPEnums.RFCDataType.STRUCTURE);
        struct3.setMandatory(SAPEnums.MandatoryType.REQUIRED);

        List<RFCFieldMetaData> struct3Fields = new ArrayList<>();

        RFCFieldMetaData s3f1 = new RFCFieldMetaData();
        s3f1.setName("DUMMY_ID");
        s3f1.setDescription("아이디인척 하는 값");
        s3f1.setSapType("CHAR");
        s3f1.setLength(30);
        s3f1.setDecimals(0);
        s3f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s3f2 = new RFCFieldMetaData();
        s3f2.setName("DUMMY_NAME");
        s3f2.setDescription("이름인척 하는 값");
        s3f2.setSapType("CHAR");
        s3f2.setLength(50);
        s3f2.setDecimals(0);
        s3f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s3f3 = new RFCFieldMetaData();
        s3f3.setName("DUMMY_DATE");
        s3f3.setDescription("날짜인척 하는 값");
        s3f3.setSapType("DATS");
        s3f3.setLength(8);
        s3f3.setDecimals(0);
        s3f3.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        struct3Fields.add(s3f1);
        struct3Fields.add(s3f2);
        struct3Fields.add(s3f3);
        struct3.setFields(struct3Fields);

        // importParams에 추가
        importParams.add(struct1);
        importParams.add(struct2);
        importParams.add(struct3);
    }

    // test용 export structure param생성
    public static void setExportStructureParamForTest(RFCFunctionMetaData rfcMeta) {
        List<RFCParamMetaData> exportParams = rfcMeta.getExportParams();
        if (exportParams == null) {
            exportParams = new ArrayList<>();
            rfcMeta.setExportParams(exportParams);
        }

        //STRUCTURE #1
        RFCParamMetaData struct1 = new RFCParamMetaData();
        struct1.setName("TEST_STRUCT_export_1");
        struct1.setDescription("export테스트용 구조체 1 desc");
        struct1.setKind(SAPEnums.RFCParamKind.EXPORT);
        struct1.setDataType(SAPEnums.RFCDataType.STRUCTURE);
        struct1.setMandatory(SAPEnums.MandatoryType.REQUIRED);

        List<RFCFieldMetaData> struct1Fields = new ArrayList<>();

        RFCFieldMetaData s1f1 = new RFCFieldMetaData();
        s1f1.setName("TEST_FIELD_export_A");
        s1f1.setDescription("export아무 의미 없는 값 A");
        s1f1.setSapType("CHAR");
        s1f1.setLength(10);
        s1f1.setDecimals(0);
        s1f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s1f2 = new RFCFieldMetaData();
        s1f2.setName("TEST_FIELD_export_B");
        s1f2.setDescription("export아무 의미 없는 값 B");
        s1f2.setSapType("NUMC");
        s1f2.setLength(6);
        s1f2.setDecimals(0);
        s1f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        struct1Fields.add(s1f1);
        struct1Fields.add(s1f2);
        struct1.setFields(struct1Fields);

        //STRUCTURE #2
        RFCParamMetaData struct2 = new RFCParamMetaData();
        struct2.setName("TEST_STRUCT_export_2");
        struct2.setDescription("테스트용 구조체 export2 asdf");
        struct2.setKind(SAPEnums.RFCParamKind.EXPORT);
        struct2.setDataType(SAPEnums.RFCDataType.STRUCTURE);
        struct2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        List<RFCFieldMetaData> struct2Fields = new ArrayList<>();

        RFCFieldMetaData s2f1 = new RFCFieldMetaData();
        s2f1.setName("FAKE_NUMBER_export");
        s2f1.setDescription("export숫자인척하는 값");
        s2f1.setSapType("CURR");
        s2f1.setLength(15);
        s2f1.setDecimals(3);
        s2f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s2f2 = new RFCFieldMetaData();
        s2f2.setName("FAKE_TEXT_export123");
        s2f2.setDescription("문자인척하는 값export");
        s2f2.setSapType("CHAR");
        s2f2.setLength(20);
        s2f2.setDecimals(0);
        s2f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        struct2Fields.add(s2f1);
        struct2Fields.add(s2f2);
        struct2.setFields(struct2Fields);


        //STRUCTURE #3
        RFCParamMetaData struct3 = new RFCParamMetaData();
        struct3.setName("TEST_exportSTRUCT_3");
        struct3.setDescription("테스트용 export구조체 3 123");
        struct3.setKind(SAPEnums.RFCParamKind.EXPORT);
        struct3.setDataType(SAPEnums.RFCDataType.STRUCTURE);
        struct3.setMandatory(SAPEnums.MandatoryType.REQUIRED);

        List<RFCFieldMetaData> struct3Fields = new ArrayList<>();

        RFCFieldMetaData s3f1 = new RFCFieldMetaData();
        s3f1.setName("exportDUMMY_ID");
        s3f1.setDescription("export 아이디인척 하는 값");
        s3f1.setSapType("CHAR");
        s3f1.setLength(30);
        s3f1.setDecimals(0);
        s3f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s3f2 = new RFCFieldMetaData();
        s3f2.setName("DUMMY_NAME");
        s3f2.setDescription("이름인척 하는 값export");
        s3f2.setSapType("CHAR");
        s3f2.setLength(50);
        s3f2.setDecimals(0);
        s3f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData s3f3 = new RFCFieldMetaData();
        s3f3.setName("export123DUMMY_DATE");
        s3f3.setDescription("날짜인척 하는 값export");
        s3f3.setSapType("DATS");
        s3f3.setLength(8);
        s3f3.setDecimals(0);
        s3f3.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        struct3Fields.add(s3f1);
        struct3Fields.add(s3f2);
        struct3Fields.add(s3f3);
        struct3.setFields(struct3Fields);

        // exportParams에 추가
        exportParams.add(struct1);
        exportParams.add(struct2);
        exportParams.add(struct3);
    }

    // test용 table param생성
    public static void setTableParamForTest(RFCFunctionMetaData rfcMeta) {
        List<RFCParamMetaData> tableParams = rfcMeta.getTableParams();
        if (tableParams == null) {
            tableParams = new ArrayList<>();
            rfcMeta.setTableParams(tableParams);
        }

        //TABLE #1
        RFCParamMetaData table1 = new RFCParamMetaData();
        table1.setName("TEST_TABLE_1");
        table1.setDescription("테스트용 테이블 파라미터 1");
        table1.setKind(SAPEnums.RFCParamKind.TABLE);
        table1.setDataType(SAPEnums.RFCDataType.TABLE);
        table1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        List<RFCFieldMetaData> table1Fields = new ArrayList<>();

        RFCFieldMetaData t1f1 = new RFCFieldMetaData();
        t1f1.setName("ROW_IDtest");
        t1f1.setDescription("행 IDtest");
        t1f1.setSapType("NUMC");
        t1f1.setLength(5);
        t1f1.setDecimals(0);
        t1f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData t1f2 = new RFCFieldMetaData();
        t1f2.setName("ROW_TEXTtest");
        t1f2.setDescription("행 설명 텍스트");
        t1f2.setSapType("CHAR");
        t1f2.setLength(50);
        t1f2.setDecimals(0);
        t1f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        table1Fields.add(t1f1);
        table1Fields.add(t1f2);
        table1.setFields(table1Fields);

        //TABLE #2
        RFCParamMetaData table2 = new RFCParamMetaData();
        table2.setName("TEST_TABLE_2");
        table2.setDescription("hsyoon 테스트 테이블2");
        table2.setKind(SAPEnums.RFCParamKind.TABLE);
        table2.setDataType(SAPEnums.RFCDataType.TABLE);
        table2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        List<RFCFieldMetaData> table2Fields = new ArrayList<>();

        RFCFieldMetaData t2f1 = new RFCFieldMetaData();
        t2f1.setName("AMOUNTTest");
        t2f1.setDescription("금액test");
        t2f1.setSapType("CURR");
        t2f1.setLength(15);
        t2f1.setDecimals(2);
        t2f1.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData t2f2 = new RFCFieldMetaData();
        t2f2.setName("CURRENCYTest");
        t2f2.setDescription("통화 코드test");
        t2f2.setSapType("CHAR");
        t2f2.setLength(3);
        t2f2.setDecimals(0);
        t2f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData t2f3 = new RFCFieldMetaData();
        t2f3.setName("DATETest");
        t2f3.setDescription("전기일자test");
        t2f3.setSapType("DATS");
        t2f3.setLength(8);
        t2f3.setDecimals(0);
        t2f3.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        table2Fields.add(t2f1);
        table2Fields.add(t2f2);
        table2Fields.add(t2f3);
        table2.setFields(table2Fields);

        //TABLE #3
        RFCParamMetaData table3 = new RFCParamMetaData();
        table3.setName("TEST_TABLE_3");
        table3.setDescription("사용자 목록 테스트 테이블test");
        table3.setKind(SAPEnums.RFCParamKind.TABLE);
        table3.setDataType(SAPEnums.RFCDataType.TABLE);
        table3.setMandatory(SAPEnums.MandatoryType.REQUIRED);

        List<RFCFieldMetaData> table3Fields = new ArrayList<>();

        RFCFieldMetaData t3f1 = new RFCFieldMetaData();
        t3f1.setName("USER_ID");
        t3f1.setDescription("사용자 ID");
        t3f1.setSapType("CHAR");
        t3f1.setLength(30);
        t3f1.setDecimals(0);
        t3f1.setMandatory(SAPEnums.MandatoryType.REQUIRED);

        RFCFieldMetaData t3f2 = new RFCFieldMetaData();
        t3f2.setName("USER_NAME");
        t3f2.setDescription("사용자 이름");
        t3f2.setSapType("CHAR");
        t3f2.setLength(50);
        t3f2.setDecimals(0);
        t3f2.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        RFCFieldMetaData t3f3 = new RFCFieldMetaData();
        t3f3.setName("LOGIN_TIME");
        t3f3.setDescription("로그인 시간");
        t3f3.setSapType("TIMS");
        t3f3.setLength(6);
        t3f3.setDecimals(0);
        t3f3.setMandatory(SAPEnums.MandatoryType.OPTIONAL);

        table3Fields.add(t3f1);
        table3Fields.add(t3f2);
        table3Fields.add(t3f3);
        table3.setFields(table3Fields);

        // tableParams에 추가
        tableParams.add(table1);
        tableParams.add(table2);
        tableParams.add(table3);
    }
}
