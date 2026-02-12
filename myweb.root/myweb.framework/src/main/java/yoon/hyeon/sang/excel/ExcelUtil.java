package yoon.hyeon.sang.excel;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;

public class ExcelUtil {

    public CellStyle makeHeaderStyle(Workbook workbook) {
        CellStyle style = headerCenterStyle(workbook, true);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setWrapText(true);    //줄바꿈허용
        setMediumBorder(style);
        return style;
    }
    public CellStyle makeSectionStyle(Workbook workbook, IndexedColors color) {
        CellStyle style = headerCenterStyle(workbook, true);
        style.setFillForegroundColor(color.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setWrapText(true);    //줄바꿈허용
        setMediumBorder(style);
        return style;
    }

    public CellStyle makeBodyStyle(Workbook workbook, boolean center) {
        CellStyle style;
        if (center) {
            style = baseCenterStyle(workbook);
        } else {
            style = baseBodyStyle(workbook);
        }
        setThinBorder(style);
        return style;
    }

    /// 병합셀 전체 셀 스타일 적용
    public void mergeAndStyle(Sheet sheet, int startRow, int endRow, int col, CellStyle style) {
        if (startRow >= endRow) return;

        CellRangeAddress region = new CellRangeAddress(startRow, endRow, col, col);
        sheet.addMergedRegion(region);

        for (int r = startRow; r <= endRow; r++) {
            Row row = sheet.getRow(r);
            Cell cell = row.getCell(col);
            cell.setCellStyle(style);
        }
    }

    private CellStyle headerCenterStyle(Workbook workbook, boolean bold) {
        CellStyle style = workbook.createCellStyle();

        Font font = workbook.createFont();
        font.setBold(bold);
        style.setFont(font);

        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);

        return style;
    }

    private CellStyle baseCenterStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();

        Font font = workbook.createFont();
        font.setBold(false);
        style.setFont(font);

        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);

        return style;
    }

    private CellStyle baseBodyStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();

        Font font = workbook.createFont();
        font.setBold(false);
        style.setFont(font);

        return style;
    }

    private void setThinBorder(CellStyle style) {
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
    }

    private void setMediumBorder(CellStyle style) {
        style.setBorderTop(BorderStyle.MEDIUM);
        style.setBorderBottom(BorderStyle.MEDIUM);
        style.setBorderLeft(BorderStyle.MEDIUM);
        style.setBorderRight(BorderStyle.MEDIUM);
    }
}
