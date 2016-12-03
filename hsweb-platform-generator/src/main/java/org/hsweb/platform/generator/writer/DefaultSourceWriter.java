package org.hsweb.platform.generator.writer;

import org.hsweb.platform.generator.SourceCode;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

/**
 * @author zhouhao
 */
public class DefaultSourceWriter implements SourceWriter {
    private boolean ignoreIfFileExists = false;

    public DefaultSourceWriter(boolean ignoreIfFileExists) {
        this.ignoreIfFileExists = ignoreIfFileExists;
    }

    @Override
    public void write(SourceCode code) throws Exception {
        File file = new File(code.getFileName());
        if (file.exists() && ignoreIfFileExists) return;
        if (!file.getParentFile().exists())
            file.getParentFile().mkdirs();
        try (FileOutputStream out = new FileOutputStream(file)
             ; InputStream in = code.readCode()) {
            int b;
            while ((b = in.read()) != -1) {
                out.write(b);
            }
            out.flush();
        }
    }
}
