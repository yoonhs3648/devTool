package yoon.hyeon.sang.config;

import yoon.hyeon.sang.util.PropertiesUtil;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class PropertyLoaderListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {
        PropertiesUtil.init();
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {}
}
