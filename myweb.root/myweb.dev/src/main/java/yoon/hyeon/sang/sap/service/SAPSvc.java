package yoon.hyeon.sang.sap.service;

import org.apache.poi.ss.usermodel.Workbook;

public interface SAPSvc {
    public Workbook makeInterfaceExcel(String jsonStr);
}
