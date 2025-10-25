<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Nobel Prize Lookup</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <%-- T-236: Add Search Form --%>
    <div class="search-form">
        <h2>Search Nobel Prizes</h2>
        <form action="index.jsp" method="get">
            <label for="year">Year:</label>
            <input type="number" id="year" name="search_year" placeholder="e.g., 2023">

            <label for="category">Category:</label>
            <input type="text" id="category" name="search_category" placeholder="e.g., Physics">

            <label for="name">Laureate Name:</label>
            <input type="text" id="name" name="search_name" placeholder="e.g., Curie">

            <button type="submit">Search</button>
            <a href="index.jsp">Clear Search</a> <%-- Link to reset the search --%>
        </form>
    </div>
    <%-- End Search Form --%>

    <hr> <%-- Visual separator --%>

    <h1>Latest Nobel Prize Recipients</h1>

    <table border="1" style="width:100%; border-collapse: collapse;">
        <%-- Table headers remain the same --%>
        <tr>
            <th>Year / Category</th>
            <th>Laureate</th>
            <th>Motivation</th>
            <th>Share</th>
        </tr>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null; // Use PreparedStatement for security
        ResultSet rs = null;

        // --- Connection Details (Replace with yours) ---
        String dbUrl = "jdbc:mariadb://localhost:3306/nobel";
        String user = "u0_a316";
        String pass = "u0_a316_";
        String driver = "org.mariadb.jdbc.Driver";

        // --- Base SQL Query ---
        String baseSql = "SELECT " +
                         "    n.nobelPrizeYear, n.nobelPrizeCategory, " +
                         "    l.firstName, l.surName, l.motivation, l.share " +
                         "FROM nobelPrize n " +
                         "INNER JOIN laureate l ON n.nobelPrizeId = l.lNobelPrizeId ";

        // --- Build WHERE clause based on search parameters (Will be added in next step) ---
        String whereClause = ""; // Placeholder for search logic
        // Example: if (request.getParameter("search_year") != null) { ... }

        // --- Final SQL ---
        String sql = baseSql + whereClause + " ORDER BY n.nobelPrizeId DESC LIMIT 20";

        try {
            Class.forName(driver);
            conn = DriverManager.getConnection(dbUrl, user, pass);

            // --- Use PreparedStatement (even without parameters yet) ---
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            // --- Iterate through Results (Loop remains the same) ---
            while (rs.next()) {
                String year = rs.getString("nobelPrizeYear");
                String category = rs.getString("nobelPrizeCategory");
                String firstName = rs.getString("firstName");
                String surName = rs.getString("surName");
                String motivation = rs.getString("motivation");
                String share = rs.getString("share");
    %>
        <tr>
            <td><%= year %> / <%= category %></td>
            <td><%= (firstName != null ? firstName : "") + " " + (surName != null ? surName : "") %></td> <%-- Handle null names --%>
            <td><%= motivation != null ? motivation : "" %></td> <%-- Handle null motivation --%>
            <td><%= share != null ? share : "" %></td> <%-- Handle null share --%>
        </tr>
    <%
            } // End of while loop
            if (!rs.isBeforeFirst() ) { // Check if ResultSet was empty
                 out.println("<tr><td colspan='4'>No results found.</td></tr>");
            }
        } catch (SQLException e) {
            out.println("<h3 style='color:red;'>Database Error!</h3>");
            out.println("<p>SQL State: " + e.getSQLState() + " Error: " + e.getMessage() + "</p>");
        } catch (ClassNotFoundException e) {
            out.println("<h3 style='color:red;'>Driver Error!</h3>");
            out.println("<p>JDBC Driver Class Not Found!</p>");
        } finally {
            // Close resources
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    %>
    </table>
</body>
</html>
