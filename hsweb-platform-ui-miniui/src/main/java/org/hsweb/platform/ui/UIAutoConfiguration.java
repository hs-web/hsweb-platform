package org.hsweb.platform.ui;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.ui.freemarker.SpringTemplateLoader;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer;

import java.io.IOException;

/**
 * Created by zhouhao on 16-5-6.
 */
@Configuration
@ComponentScan("org.hsweb.platform.ui")
public class UIAutoConfiguration {
    @Bean
    public FreeMarkerConfigurer freeMarkerConfigurer() {
        FreeMarkerConfigurer configurer = new FreeMarkerConfigurer();
        configurer.setDefaultEncoding("utf-8");
        configurer.setPreTemplateLoaders(new SpringTemplateLoader(new PathMatchingResourcePatternResolver() {
            @Override
            public Resource getResource(String location) {
                try {
                    Resource[] resources = getResources(location);
                    if (resources.length > 0) return resources[0];
                } catch (IOException e) {
                }
                return super.getResource(location);
            }
        }, "classpath*:templates/"));
        return configurer;
    }

//    @Bean
//    public WebMvcConfigurerAdapter webMvcConfigurerAdapter() {
//        return new WebMvcConfigurerAdapter() {
//            @Override
//            public void addResourceHandlers(ResourceHandlerRegistry registry) {
//                registry.addResourceHandler("classpath*:/static");
//                super.addResourceHandlers(registry);
//            }
//        };
//    }
}
