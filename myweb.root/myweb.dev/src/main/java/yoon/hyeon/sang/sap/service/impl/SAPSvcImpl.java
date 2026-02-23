package yoon.hyeon.sang.sap.service.impl;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import yoon.hyeon.sang.excel.ExcelUtil;
import yoon.hyeon.sang.sap.service.SAPSvc;

import java.util.ArrayList;
import java.util.List;

@Service
public class SAPSvcImpl implements SAPSvc {
    private static final Gson gson = new Gson();

    @Override
    public Workbook makeInterfaceExcel(String jsonStr) {
        try {
            JsonObject jsonObj = gson.fromJson(jsonStr, JsonObject.class);

            String functionName = jsonObj.get("functionName").getAsString();

            JsonArray importParamsArray = jsonObj.getAsJsonArray("importParams");
            List<JsonObject> importParams = new ArrayList<>();
            List<JsonObject> importStParams = new ArrayList<>();
            for (JsonElement el : importParamsArray) {
                JsonObject param = el.getAsJsonObject();

                String dataType = param.get("dataType").getAsString();

                if ("STRUCTURE".equalsIgnoreCase(dataType)) {
                    importStParams.add(param);
                } else {
                    importParams.add(param);
                }
            }

            JsonArray exportParamsArray = jsonObj.getAsJsonArray("exportParams");
            List<JsonObject> exportParams = new ArrayList<>();
            List<JsonObject> exportstParams = new ArrayList<>();
            for (JsonElement el : exportParamsArray) {
                JsonObject param = el.getAsJsonObject();

                String dataType = param.get("dataType").getAsString();

                if ("STRUCTURE".equalsIgnoreCase(dataType)) {
                    exportstParams.add(param);
                } else {
                    exportParams.add(param);
                }
            }

            List<JsonObject> tableParams =
                    gson.fromJson(jsonObj.getAsJsonArray("tableParams"),
                            new TypeToken<List<JsonObject>>(){}.getType());

            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet(functionName + "_인터페이스 명세서");

            // 스타일
            ExcelUtil excelUtil = new ExcelUtil();
            CellStyle headerStyle = excelUtil.makeHeaderStyle(workbook);
            CellStyle bodyStyle = excelUtil.makeBodyStyle(workbook, false);
            CellStyle bodyCenterStyle = excelUtil.makeBodyStyle(workbook, true);
            CellStyle importHeaderStyle = excelUtil.makeSectionStyle(workbook, IndexedColors.LIGHT_YELLOW);
            CellStyle tableHeaderStyle  = excelUtil.makeSectionStyle(workbook, IndexedColors.LIGHT_GREEN);
            CellStyle exportHeaderStyle = excelUtil.makeSectionStyle(workbook, IndexedColors.LIGHT_CORNFLOWER_BLUE);

            // 헤더
            String[] headers = {
                    "Parameter",
                    "순번",
                    "필드",
                    "Type",
                    "길이",
                    "소수점",
                    "Input/Output",
                    "Description"
            };

            int[] maxColWidth = new int[headers.length];

            int rowIdx = 1; // B2 시작
            int colOffset = 1;

            // Header
            Row header = sheet.createRow(rowIdx++);
            for (int i = 0; i < headers.length; i++) {
                createCell(header, colOffset + i, headers[i], headerStyle, maxColWidth, i);
            }

            // Import
            int importStart = rowIdx;
            int seq = 1;
            for (JsonObject p : importParams) {
                Row row = sheet.createRow(rowIdx++);

                String decimals = "";
                String decimalInfo = getStr(p, "decimals");
                if (decimalInfo != null && !"0".equals(decimalInfo)) {
                    decimals = decimalInfo;
                }

                writeRow(row, bodyStyle, bodyCenterStyle, maxColWidth, colOffset,
                        "Import",
                        String.valueOf(seq++),
                        getStr(p, "name"),
                        getStr(p, "sapType"),
                        getStr(p, "length"),
                        decimals,
                        "I",
                        getStr(p, "description")
                );
            }
            excelUtil.mergeAndStyle(sheet, importStart, rowIdx - 1, colOffset, importHeaderStyle);

            // Import structure
            for (JsonObject fields : importStParams) {
                String stName = getStr(fields, "name");
                String stDesc = getStr(fields, "description");

                JsonArray field = fields.getAsJsonArray("fields");
                int importStStart = rowIdx;
                seq = 1;
                for (JsonElement el : field) {
                    JsonObject f = el.getAsJsonObject();
                    Row row = sheet.createRow(rowIdx++);

                    String decimals = "";
                    String decimalInfo = getStr(f, "decimals");
                    if (decimalInfo != null && !"0".equals(decimalInfo)) {
                        decimals = decimalInfo;
                    }

                    writeRow(row, bodyStyle, bodyCenterStyle, maxColWidth, colOffset,
                            "Import (" + stName + ")\n" + "(Description: " + stDesc + ")",
                            String.valueOf(seq++),
                            getStr(f, "name"),
                            getStr(f, "sapType"),
                            getStr(f, "length"),
                            decimals,
                            "I",
                            getStr(f, "description")
                    );
                }
                excelUtil.mergeAndStyle(sheet, importStStart, rowIdx - 1, colOffset, importHeaderStyle);
            }

            // Table
            for (JsonObject table : tableParams) {
                JsonArray fields = table.getAsJsonArray("fields");
                int tableStart = rowIdx;
                seq = 1;

                for (JsonElement el : fields) {
                    JsonObject f = el.getAsJsonObject();
                    Row row = sheet.createRow(rowIdx++);

                    String decimals = "";
                    String decimalInfo = getStr(f, "decimals");
                    if (decimalInfo != null && !"0".equals(decimalInfo)) {
                        decimals = decimalInfo;
                    }

                    writeRow(row, bodyStyle, bodyCenterStyle, maxColWidth, colOffset,
                            "Table",
                            String.valueOf(seq++),
                            getStr(f, "name"),
                            getStr(f, "sapType"),
                            getStr(f, "length"),
                            decimals,
                            "",
                            getStr(f, "description")
                    );
                }
                excelUtil.mergeAndStyle(sheet, tableStart, rowIdx - 1, colOffset, tableHeaderStyle);
            }

            // Export
            int exportStart = rowIdx;
            seq = 1;
            for (JsonObject p : exportParams) {
                Row row = sheet.createRow(rowIdx++);

                String decimals = "";
                String decimalInfo = getStr(p, "decimals");
                if (decimalInfo != null && !"0".equals(decimalInfo)) {
                    decimals = decimalInfo;
                }

                writeRow(row, bodyStyle, bodyCenterStyle, maxColWidth, colOffset,
                        "Export",
                        String.valueOf(seq++),
                        getStr(p, "name"),
                        getStr(p, "sapType"),
                        getStr(p, "length"),
                        decimals,
                        "O",
                        getStr(p, "description")
                );
            }
            excelUtil.mergeAndStyle(sheet, exportStart, rowIdx - 1, colOffset, exportHeaderStyle);

            // Export structure
            for (JsonObject fields : exportstParams) {
                String stName = getStr(fields, "name");
                String stDesc = getStr(fields, "description");
                JsonArray field = fields.getAsJsonArray("fields");
                int exportStStart = rowIdx;
                seq = 1;

                for (JsonElement el : field) {
                    JsonObject f = el.getAsJsonObject();
                    Row row = sheet.createRow(rowIdx++);

                    String decimals = "";
                    String decimalInfo = getStr(f, "decimals");
                    if (decimalInfo != null && !"0".equals(decimalInfo)) {
                        decimals = decimalInfo;
                    }

                    writeRow(row, bodyStyle, bodyCenterStyle, maxColWidth, colOffset,
                            "Export (" + stName + ")\n" + "(Description: " + stDesc + ")",
                            String.valueOf(seq++),
                            getStr(f, "name"),
                            getStr(f, "sapType"),
                            getStr(f, "length"),
                            decimals,
                            "O",
                            getStr(f, "description")
                    );
                }

                excelUtil.mergeAndStyle(sheet, exportStStart, rowIdx - 1, colOffset, exportHeaderStyle);
            }

            // Column Width
            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(colOffset + i, (maxColWidth[i] + 2) * 256);
            }

            sheet.createFreezePane(colOffset, 2);

            return workbook;

        } catch (Exception e) {
            throw new RuntimeException("엑셀 생성 실패", e);
        }
    }

    public void writeRow(
            Row row,
            CellStyle bodyStyle,
            CellStyle bodyCenterStyle,
            int[] maxColWidth,
            int colOffset,
            String param,
            String seq,
            String name,
            String type,
            String length,
            String decimals,
            String io,
            String desc
    ) {
        int col = colOffset;
        createCell(row, col++, param, bodyCenterStyle, maxColWidth, 0); //파라미터타입
        createCell(row, col++, seq, bodyCenterStyle, maxColWidth, 1);   //순번
        createCell(row, col++, name, bodyStyle, maxColWidth, 2);        //필드
        createCell(row, col++, type, bodyCenterStyle, maxColWidth, 3);  //Type
        createCell(row, col++, length, bodyStyle, maxColWidth, 4);      //길이
        createCell(row, col++, decimals, bodyStyle, maxColWidth, 5);    //소수점
        createCell(row, col++, io, bodyCenterStyle, maxColWidth, 6);    //Input/Output
        createCell(row, col++, desc, bodyStyle, maxColWidth, 7);        //Description
    }

    public void createCell(
            Row row,
            int idx,
            String value,
            CellStyle style,
            int[] maxColWidth,
            int colIdx
    ) {
        Cell cell = row.createCell(idx);
        cell.setCellStyle(style);

        if (value != null) {
            cell.setCellValue(value);
            maxColWidth[colIdx] = Math.max(
                    maxColWidth[colIdx],
                    calcDisplayWidth(value)
            );
        }
    }

    private int calcDisplayWidth(String s) {
        int width = 0;
        for (char c : s.toCharArray()) {
            width += (c >= 0xAC00 && c <= 0xD7A3) ? 2 : 1;
        }
        return width;
    }

    private String getStr(JsonObject obj, String key) {
        return obj.has(key) && !obj.get(key).isJsonNull() ? obj.get(key).getAsString() : "";
    }
}
