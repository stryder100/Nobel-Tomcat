<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Nobel Prize Lookup - Latest Awards</title>
</head>
<body>
    <h1>Latest Nobel Prize Recipients (JDBC Test)</h1>

    <table border="1" style="width:100%; border-collapse: collapse;">
        <tr>
            <th>Year / Category</th>
            <th>Laureate</th>
            <th>Motivation</th>
            <th>Share</th>
        </tr>

    <%
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        // --- NOTE: REPLACE with your MariaDB connection details ---
        String dbUrl = "jdbc:mariadb://localhost:3306/nobel";
        String user = "u0_a316";         
        String pass = "u0_a316_";     
        String driver = "org.mariadb.jdbc.Driver"; 
        
        // --- T-225 Refined SQL Query ---
        String sql = "SELECT " +
                     "    n.nobelPrizeYear, n.nobelPrizeCategory, " +
                     "    l.firstName, l.surName, l.motivation, l.share " +
                     "FROM nobelPrize n " +
                     "INNER JOIN laureate l ON n.nobelPrizeId = l.lNobelPrizeId " +
                     "ORDER BY n.nobelPrizeId DESC, l.surName ASC " +
                     "LIMIT 20";

        try {
            // 1. Load the Driver & Connect
            Class.forName(driver);
            conn = DriverManager.getConnection(dbUrl, user, pass);

            // 2. Execute the Query
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            // 3. Iterate through Results (T-226 Logic)
            while (rs.next()) {
                // Get values from the ResultSet columns
                String year = rs.getString("nobelPrizeYear");
                String category = rs.getString("nobelPrizeCategory");
                String firstName = rs.getString("firstName");
                String surName = rs.getString("surName");
                String motivation = rs.getString("motivation");
                String share = rs.getString("share");
    %>
        <tr>
            <td><%= year %> / <%= category %></td>
            <td><%= firstName %> <%= surName %></td>
            <td><%= motivation %></td>
            <td><%= share %></td>
        </tr>
    <%
            } // End of while loop
        } catch (SQLException e) {
            out.println("<h3 style='color:red;'>Database Error!</h3>");
            out.println("<p>SQL State: " + e.getSQLState() + " Error: " + e.getMessage() + "</p>");
        } catch (ClassNotFoundException e) {
            out.println("<h3 style='color:red;'>Driver Error!</h3>");
            out.println("<p>JDBC Driver Class Not Found!</p>");
        } finally {
            // 4. Safely Close Resources
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    %>
    </table>
</body>
</html>

