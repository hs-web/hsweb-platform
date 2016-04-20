package org.hsweb.platform.core.web;

import javax.servlet.http.HttpServletRequest;

/**
 * Created by zhouhao on 16-4-14.
 */
public interface WebAppHandler {
    WebApplication handler(HttpServletRequest request);
}
