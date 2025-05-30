package net.skhu;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("net.skhu.mapper")
public class FairMeettingApplication {

    public static void main(String[] args) {
        SpringApplication.run(FairMeettingApplication.class, args);
    }
}
