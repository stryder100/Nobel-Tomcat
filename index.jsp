<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>MariaDB JDBC Test</title>
</head>
<body>
    <h1>MariaDB Connection Status for Nobel App</h1>
    <%
        Connection conn = null;
        String dbUrl = "jdbc:mariadb://localhost:3306/nobel";
        String user = "u0_a316";         // <<< REPLACE with your MariaDB Username
        String pass = "u0_a316_";     // <<< REPLACE with your MariaDB Password
        String driver = "org.mariadb.jdbc.Driver"; // JDBC Driver Class

        try {
            // 1. Load the JDBC Driver (optional but good practice)
            Class.forName(driver);

            // 2. Establish the connection
            conn = DriverManager.getConnection(dbUrl, user, pass);

            // 3. Print success message
            out.println("<h2>Connection Successful!</h2>");
            out.println("<p>Connected to database: <b>" + dbUrl + "</b></p>");

        } catch (SQLException e) {
            // 4. Handle SQL connection failures
            out.println("<h2 style='color:red;'>Connection FAILED!</h2>");
            out.println("<p>Error Message: " + e.getMessage() + "</p>");
            out.println("<p>SQL State: " + e.getSQLState() + "</p>");
        } catch (ClassNotFoundException e) {
            // 5. Handle missing driver
            out.println("<h2 style='color:red;'>Driver Error!</h2>");
            out.println("<p>JDBC Driver Class Not Found: " + driver + "</p>");
        } finally {
            // 6. Close the connection safely
            if (conn != null) {
                try {
                    conn.close();
                    out.println("<p>Connection Closed.</p>");
                } catch (SQLException e) {
                    out.println("<p style='color:orange;'>Error closing connection: " + e.getMessage() + "</p>");
                }
            }
        }
    %>
</body>
</html>