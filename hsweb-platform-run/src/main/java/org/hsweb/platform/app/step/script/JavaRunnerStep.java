package org.hsweb.platform.app.step.script;

import org.hsweb.platform.app.step.ScriptRunnerStep;

/**
 * Created by zhouhao on 16-4-14.
 */
public class JavaRunnerStep extends ScriptRunnerStep {
    public JavaRunnerStep(String className, String script) throws Exception {
        super(className, script, "java");
    }
}
