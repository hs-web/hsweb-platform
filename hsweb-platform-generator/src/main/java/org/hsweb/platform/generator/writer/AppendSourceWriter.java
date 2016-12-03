package org.hsweb.platform.generator.writer;

import org.hsweb.commons.file.FileUtils;
import org.hsweb.platform.generator.SourceCode;

import java.io.*;

/**
 * @author zhouhao
 */
public class AppendSourceWriter implements SourceWriter {
    @Override
    public void write(SourceCode code) throws Exception {
        File file = new File(code.getFileName());
        if (!file.getParentFile().exists())
            file.getParentFile().mkdirs();
        String codeString;
        try (InputStreamReader reader = new InputStreamReader(code.readCode())) {
            codeString = FileUtils.reader2String(reader);
        }

        if (file.exists()) {
            String old = FileUtils.reader2String(code.getFileName());
            //存在重复代码
            if (old.contains(codeString)) return;
        }
        try (FileWriter writer = new FileWriter(file, true)) {
            writer.write(codeString);
        }
    }
}
