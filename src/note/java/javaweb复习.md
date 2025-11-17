# javaweb 复习

---

**假设各位有一定的 Java 和前端基础**

## 基础知识点

- 其他页面 other.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%=request.getParameter("k")%>
```

- 用户类 web.User.java

```java
package web;

public class User {
    private String username;
    private String password;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
```

- 基础语法 web.jsp

```jsp
<!--JSP文件至少要说明, 类型是 html, UTF-8 字符集-->
<%@ page contentType="text/html; charset=UTF-8" %>
<!--导包-->
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!--指定错误页面时 error.jsp, 当前页面出错后会自动跳转到指定的错误页面-->
<%@ page errorPage="other.jsp" %>
<!--指示当前页面是错误页面, 为 true 时才可以使用 exception 内置对象-->
<%@ page isErrorPage="true" %>

<!--导入其他页面, 相当于把其他页面的内容粘贴到这里-->
<%@ include file="other.jsp" %>

<%!
    // 定义 info
    String info = "这是Java代码";

    // 定于 func 方法
    void func() {

    }
%>

<!--页面上将显示 `这是Java代码`-->
<%=info%>

<%
    int a = 1;
    int b = 2;
    // 页面上显示 `3`
    out.print(a + b);
%>

<!--导入其他页面, 可以使用 param 传递参数-->
<!--可以写多条 param-->
<jsp:include page="other.jsp">
    <jsp:param name="k" value="v"/>
</jsp:include>

<!--跳转到其他页面, 可以使用 param 传递参数-->
<!--可以写多条 param-->
<jsp:forward page="other.jsp">
    <jsp:param name="k" value="v"/>
</jsp:forward>

<!--指示使用 JavaBean-->
<jsp:useBean id="user" class="web.User"/>
<!--指示将 request 中的参数 set 到 user 对象中-->
<jsp:setProperty name="user" property="*"/>

<!--获取对象属性展示到页面上-->
<jsp:getProperty name="user" property="username"/>
<jsp:getProperty name="user" property="password"/>

<!--常用内置对象, 主要是前 4 个-->
<%
    // out
    out.print("这是内容<br>"); // 页面上显示 `这是内容` 并换行

    // request
    // 设置编码方式
    request.setCharacterEncoding("UTF-8");
    // 获取 k1 对应的值
    String v1 = request.getParameter("k1");
    // 获取 k2 对应的多个值
    String[] v2 = request.getParameterValues("k2");

    // 获取所有 cookie
    Cookie[] cookies = request.getCookies();
    for (Cookie cookie : cookies) {
        String name = cookie.getName();
        String value = cookie.getValue();
    }

    // response
    // 设置编码方式
    response.setCharacterEncoding("UTF-8");
    // 重定向到主页
    response.sendRedirect("index.jsp");
    // 1 秒后跳转到主页
    response.setHeader("refresh", "1; url=index.jsp");
    // 添加 cookie k3 = v3
    response.addCookie(new Cookie("k3", "v3"));

    // session
    // session 设置 k4 = v4
    session.setAttribute("k4", "k4");
    // session 中得到 v4
    String v4 = (String) session.getAttribute("k4");
    out.print(v4);
    // 使 session 失效
    session.invalidate();

    // application
    // application 设置 k5 = 5
    application.setAttribute("k5", 5);
    // application 得到 5
    int v5 = (int) application.getAttribute("k5");
    out.print(v5);

    // exception
    out.print(exception);
%>

<!--数据库连接7个步骤-->
<%
    // 1. 加载驱动
    Class.forName("com.mysql.jdbc.Driver");
    // 2. 定义连接数据库的url (老师PPT是这么分的)
    String url = "jdbc:mysql://localhost:3306/web";
    // 3. 获取连接对象
    Connection cn = DriverManager.getConnection(url, "root", "root");
    // 4. 获取SQL声明对象
    // 没有参数用 Statement, 有参数用 PreparedStatement
    Statement ps = cn.createStatement();
    // 5. 执行SQL语句
    ResultSet rs = ps.executeQuery("select * from user");
    // 6. 处理返回值
    while (rs.next()) {
        out.print(rs.getInt(1));
        out.print(rs.getString(2));
        out.print(rs.getString(3));
        out.print("<br>");
    }
    // 7. 关闭资源
    rs.close();
    ps.close();
    cn.close();
%>
```

## 用户注册、登录、登出、列表和主页展示代码示例

- 数据库文件 web.sql

```sql
drop database if exists web;
create database web charset utf8mb4;
use web;

create table user
(
    id       int auto_increment primary key,
    username varchar(32) unique not null,
    password varchar(32)        not null
);

select * from user;
```

- 注册页面 register.html

```html
<meta charset="UTF-8" />
<form action="register.jsp" method="post">
  用户名<input type="text" name="username" /><br />
  密码<input type="password" name="password" /><br />
  <button type="submit">注册</button>
</form>
```

- 登录页面 login.html

```html
<meta charset="UTF-8" />
<form action="login.jsp" method="post">
  用户名<input type="text" name="username" /><br />
  密码<input type="password" name="password" /><br />
  <button type="submit">登陆</button>
</form>
```

- 注册处理页面 register.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    // 数据库连接7个步骤
    // 1. 加载驱动
    Class.forName("com.mysql.jdbc.Driver");
    // 2. 定义连接数据库的url (老师PPT是这么分的)
    String url = "jdbc:mysql://localhost:3306/web";
    // 3. 获取连接对象
    Connection cn = DriverManager.getConnection(url, "root", "root");
    // 4. 获取SQL声明对象
    String sql = "insert into user (username, password) values (?, ?)";
    PreparedStatement ps = cn.prepareStatement(sql);
    ps.setString(1, username); // 从 1 开始
    ps.setString(2, password);
    // 5. 执行SQL语句
    int r = ps.executeUpdate();
    // 6. 处理返回值
    out.print(r <= 0 ? "注册失败" : "注册成功");
    // 7. 关闭资源
    ps.close();
    cn.close();
    // 1 秒后跳转到主页, 不写也行, 看题目有没有这个要求
    response.setHeader("refresh", "1; url=index.jsp");
%>
```

- 登录处理页面 login.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    // 数据库连接7个步骤
    // 1. 加载驱动
    Class.forName("com.mysql.jdbc.Driver");
    // 2. 定义连接数据库的url (老师PPT是这么分的)
    String url = "jdbc:mysql://localhost:3306/web";
    // 3. 获取连接对象
    Connection cn = DriverManager.getConnection(url, "root", "root");
    // 4. 获取SQL声明对象
    String sql = "select * from user where username = ? and password = ?";
    PreparedStatement ps = cn.prepareStatement(sql);
    ps.setString(1, username); // 从 1 开始
    ps.setString(2, password);
    // 5. 执行SQL语句
    ResultSet rs = ps.executeQuery();
    // 6. 处理返回值
    if (rs.next()) { // 这里只查询一个, 可以这么写
        // 用户名存入 session
        session.setAttribute("username", rs.getString("username"));
        out.print("登录成功");
    } else {
        out.print("用户名或密码错误");
    }
    // 7. 关闭资源
    rs.close();
    ps.close();
    cn.close();
    // 1 秒后跳转到主页, 不写也行, 看题目有没有这个要求
    response.setHeader("refresh", "1; url=index.jsp");
%>
```

- 登出 logout.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    session.invalidate();
    out.print("登出成功");
    // 1 秒后跳转到主页, 不写也行, 看题目有没有这个要求
    response.setHeader("refresh", "1; url=index.jsp");
%>
```

- 用户列表 list.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<table border="1">
    <tr>
        <td>ID</td>
        <td>用户名</td>
        <td>密码</td>
    </tr>
    <%
        // 数据库连接7个步骤
        // 1. 加载驱动
        Class.forName("com.mysql.jdbc.Driver");
        // 2. 定义连接数据库的url (老师PPT是这么分的)
        String url = "jdbc:mysql://localhost:3306/web";
        // 3. 获取连接对象
        Connection cn = DriverManager.getConnection(url, "root", "root");
        // 4. 获取SQL声明对象
        // 没有参数用 Statement, 有参数用 PreparedStatement
        Statement ps = cn.createStatement();
        // 5. 执行SQL语句
        ResultSet rs = ps.executeQuery("select * from user");
        // 6. 处理返回值
        while (rs.next()) {
            out.print("<tr>");
            out.print("<td>" + rs.getInt(1) + "</td>");
            out.print("<td>" + rs.getString(2) + "</td>");
            out.print("<td>" + rs.getString(3) + "</td>");
            out.print("</tr>");
        }
        // 7. 关闭资源
        rs.close();
        ps.close();
        cn.close();
    %>
</table>
```

- 主页 index.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        out.print("请先登录");
    } else {
        out.print("欢迎" + username);
    }
%>
<a href="register.html">注册</a>
<a href="login.html">登录</a>
<a href="logout.jsp">登出</a>
<a href="list.jsp">用户列表</a>
```
