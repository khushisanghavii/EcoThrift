package com.mycompany.ecothrift;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter("/admin/*") // <- only protects /admin/ pages
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // allow if session exists and role is ADMIN
        if (session != null) {
            Object roleObj = session.getAttribute("role");
            if (roleObj != null && "ADMIN".equalsIgnoreCase(roleObj.toString())) {
                chain.doFilter(request, response);
                return;
            }
        }

        // not allowed -> redirect to login
        res.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    @Override public void init(FilterConfig filterConfig) {}
    @Override public void destroy() {}
}
