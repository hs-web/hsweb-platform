package org.hsweb.platform.app.development.step;

import org.hsweb.platform.app.development.step.processer.DevelopmentStepProcessor;
import org.hsweb.platform.core.ApplicationProcess;
import org.hsweb.platform.core.Step;
import org.hsweb.web.core.message.ResponseMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-14.
 */
@Component
public class DispatcherStep implements Step {

    private Map<String, DevelopmentStepProcessor> processorMap = new HashMap<>();

    @Autowired
    private ApplicationContext context;

    @Override
    public Object execute(ApplicationProcess process) {
        String type = process.getParameter("p").toString();
        DevelopmentStepProcessor processor = processorMap.get(type);
        if (processor == null) ResponseMessage.error("无效的参数p");
        return processor.execute(process);
    }

    @PostConstruct
    public void init() {
        Map<String, DevelopmentStepProcessor> map = context.getBeansOfType(DevelopmentStepProcessor.class);
        map.forEach((name, processor) -> processorMap.put(processor.getType(), processor));
    }
}
