package org.hsweb.platform.core.exception;

/**
 * Created by zhouhao on 16-4-14.
 */
public class ApplicationException extends RuntimeException {
    public ApplicationException(String message, Throwable cause) {
        super(message, cause);
    }

    public ApplicationException(String message) {
        super(message);
    }

    public ApplicationException(Throwable cause) {
        super(cause);
    }
}
