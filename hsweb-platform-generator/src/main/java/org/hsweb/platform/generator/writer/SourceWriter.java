package org.hsweb.platform.generator.writer;

import org.hsweb.platform.generator.SourceCode;

/**
 * @author zhouhao
 */
public interface SourceWriter {
    void write(SourceCode code)throws Exception;
}
