package org.hsweb.platform.app.step;

import org.hsweb.platform.core.ApplicationProcess;
import org.hsweb.platform.core.Step;
import org.webbuilder.utils.script.engine.DynamicScriptEngine;
import org.webbuilder.utils.script.engine.DynamicScriptEngineFactory;
import org.webbuilder.utils.script.engine.ExecuteResult;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-14.
 */
public class ScriptRunnerStep implements Step {

    private DynamicScriptEngine engine;

    private String script;

    private String id;

    public ScriptRunnerStep(String script, String language) throws Exception {
        this(String.valueOf(script.hashCode()), script, language);
    }

    public ScriptRunnerStep(String id, String script, String language) throws Exception {
        this.id = id;
        engine = DynamicScriptEngineFactory.getEngine(language);
        if (engine == null) {
            throw new ClassNotFoundException(language);
        }
        init();
    }

    public void init() throws Exception {
        engine.compile(id, script);
    }

    @Override
    public Object execute(ApplicationProcess process) {
        Map<String, Object> var = new HashMap<>();
        var.put("process", process);
        ExecuteResult result = engine.execute(id, var);
        if (result.isSuccess()) return result.getResult();
        if (result.getException() != null) process.error(result.getMessage(), result.getException());
        return null;
    }

    protected String getScript() {
        return script;
    }

    public void setScript(String script) {
        this.script = script;
    }
}
