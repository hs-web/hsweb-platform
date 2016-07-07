package org.hsweb.platform.generator.template;

import java.util.Map;

/**
 * @author zhouhao
 * @TODO
 */
public class SimpleCodeTemplate<IN> implements CodeTemplate<IN> {
    private Map<String, Object> vars;
    private TemplateInput<IN> input;
    private TemplateOutput output;

    public SimpleCodeTemplate(Map<String, Object> vars, TemplateInput<IN> input, TemplateOutput output) {
        this.vars = vars;
        this.input = input;
        this.output = output;
    }

    @Override
    public Map<String, Object> getVars() {
        return vars;
    }

    @Override
    public TemplateOutput getOutPut() {
        return output;
    }

    @Override
    public TemplateInput<IN> getInput() {
        return input;
    }
}
