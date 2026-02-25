package yoon.hyeon.sang.config;

import javax.sql.DataSource;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import yoon.hyeon.sang.util.PropertiesUtil;

@Configuration
public class DBConfig {

    public static final String driverClassName = PropertiesUtil.getProperties("jdbc.driverClassName");
    public static final String jdbcUrl = PropertiesUtil.getProperties("jdbc.jdbcUrl");
    public static final String userName = PropertiesUtil.getProperties("jdbc.userName");
    public static final String userPwd = PropertiesUtil.getProperties("jdbc.userPwd");

    @Bean
    public DataSource dataSource() {

        HikariConfig config = new HikariConfig();

        config.setDriverClassName(driverClassName);
        config.setJdbcUrl(jdbcUrl);
        config.setUsername(userName);
        config.setPassword(userPwd);

        config.setMaximumPoolSize(160);
        config.setMinimumIdle(0);
        config.setConnectionTimeout(6000);
        config.setConnectionTestQuery("SELECT 1");

        return new HikariDataSource(config);
    }
}
