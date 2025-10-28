<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, java.util.ArrayList, java.util.List" %>

<!DOCTYPE html>
<html>
<head>
    <title>Nobel Prize Lookup</title>
    <link rel="stylesheet" href="style.css"> <%-- Link to your CSS file --%>
</head>
<body>

    <%-- Search Form Section --%>
    <div class="search-form">
        <h2>Search Nobel Prizes</h2>
        <form action="index.jsp" method="post">
            <input type="number" id="year" name="search_year" placeholder="e.g., 2023" value="<%= request.getParameter("search_year") != null ? request.getParameter("search_year") : "" %>">

            <label for="category">Category:</label>
            <%
                String category_param = request.getParameter("search_category");
                category_param = (category_param != null ? category_param : "");
            %>
            <select id="category" name="search_category" value="<%= category_param != null ? category_param : "" %>">
                <option value="">Please Choose a Category</option>
                <option value="chemistry"<% if ("chemistry".equals(category_param)) { out.print(" selected"); } %>>chemistry</option>
                <option value="economics"<% if ("economics".equals(category_param)) { out.print(" selected"); } %>>economics</option>
                <option value="literature"<% if ("literature".equals(category_param)) { out.print(" selected"); } %>>literature</option>
                <option value="medicine"<% if ("medicine".equals(category_param)) { out.print(" selected"); } %>>medicine</option>
                <option value="peace"<% if ("peace".equals(category_param)) { out.print(" selected"); } %>>peace</option>
                <option value="physics"<% if ("physics".equals(category_param)) { out.print(" selected"); } %>>physics</option>
            </select>

            <label for="name">Laureate Name:</label>
            <input type="text" id="name" name="search_name" placeholder="e.g., Curie" value="<%= request.getParameter("search_name") != null ? request.getParameter("search_name") : "" %>">

            <button type="submit">Search</button>
            <a href="index.jsp">Clear Search</a> <%-- Link to reset search --%>
        </form>
    </div>

    <hr> <%-- Visual separator --%>

    <h1>Nobel Prize Recipients</h1>

    <%-- Results Table Section --%>
    <table border="1" style="width:100%; border-collapse: collapse;">
        <thead>
            <tr>
                <th>Year / Category</th>
                <th>Laureate</th>
                <th>Motivation</th>
                <th>Share</th>
            </tr>
        </thead>
        <tbody>
    <%
        // --- Database Connection Variables ---
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // --- REPLACE with your actual MariaDB credentials ---
        String dbUrl = "jdbc:mariadb://localhost:3306/nobel";
        String user = "u0_a316";
        String pass = "u0_a316_";
        String driver = "org.mariadb.jdbc.Driver";

        // --- Get Search Parameters ---
        String searchYearParam = request.getParameter("search_year");
        String searchCategoryParam = request.getParameter("search_category");
        String searchNameParam = request.getParameter("search_name");

        // --- Base SQL Query ---
        String baseSql = "SELECT " +
                         "    n.nobelPrizeYear, n.nobelPrizeCategory, " +
                         "    l.firstName, l.surName, l.motivation, l.share " +
                         "FROM nobelPrize n " +
                         "INNER JOIN laureate l ON n.nobelPrizeId = l.lNobelPrizeId ";

        // --- Dynamically Build WHERE Clause ---
        StringBuilder whereSql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        boolean firstCondition = true;

        // Add condition for Year
        if (searchYearParam != null && !searchYearParam.trim().isEmpty()) {
             try {
                 whereSql.append(" WHERE n.nobelPrizeYear = ?");
                 params.add(Integer.parseInt(searchYearParam.trim())); // Add year as integer
                 firstCondition = false;
            } catch (NumberFormatException e) {
                 System.out.println("WARN: Invalid year format: " + searchYearParam);
                 // Ignore invalid year input for this simple example
            }
        }

        // Add condition for Category (case-insensitive LIKE search)
        if (searchCategoryParam != null && !searchCategoryParam.trim().isEmpty()) {
            if (firstCondition) { whereSql.append(" WHERE "); firstCondition = false; }
            else { whereSql.append(" AND "); }
            whereSql.append("LOWER(n.nobelPrizeCategory) LIKE LOWER(?)"); // Case-insensitive
            params.add("%" + searchCategoryParam.trim() + "%");
        }

        // Add condition for Laureate Name (searches first OR last name, case-insensitive LIKE)
        if (searchNameParam != null && !searchNameParam.trim().isEmpty()) {
            if (firstCondition) { whereSql.append(" WHERE "); firstCondition = false; }
            else { whereSql.append(" AND "); }
            whereSql.append("(LOWER(l.firstName) LIKE LOWER(?) OR LOWER(l.surName) LIKE LOWER(?))"); // Case-insensitive
            String namePattern = "%" + searchNameParam.trim() + "%";
            params.add(namePattern);
            params.add(namePattern);
        }

        String whereClause = whereSql.toString();

        // --- Final SQL ---
        // Order by year descending first, then category, then surname
        String sql = baseSql + whereClause + " ORDER BY n.nobelPrizeYear DESC, n.nobelPrizeCategory ASC, l.surName ASC";
        // String sql = baseSql + whereClause + " ORDER BY n.nobelPrizeYear DESC, n.nobelPrizeCategory ASC, l.surName ASC LIMIT 50"; // Increased limit slightly

        boolean resultsFound = false; // Flag to check if any rows were returned

        try {
            // --- Connect and Prepare Statement ---
            Class.forName(driver);
            conn = DriverManager.getConnection(dbUrl, user, pass);
            pstmt = conn.prepareStatement(sql);

            // --- Bind Parameters ---
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                // Parameter index is 1-based in JDBC
                if (param instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) param);
                } else if (param instanceof String) {
                    pstmt.setString(i + 1, (String) param);
                }
            }

            // --- Execute Query ---
            rs = pstmt.executeQuery();

            // --- Iterate through Results and Display ---
            while (rs.next()) {
                resultsFound = true; // Mark that we found at least one result
                String year = rs.getString("nobelPrizeYear");
                String category = rs.getString("nobelPrizeCategory");
                String firstName = rs.getString("firstName");
                String surName = rs.getString("surName");
                String motivation = rs.getString("motivation");
                String share = rs.getString("share");

                // Construct full name, handling potential nulls
                String fullName = (firstName != null ? firstName : "") + " " + (surName != null ? surName : "");
    %>
            <tr>
                <td><%= year != null ? year : "" %> / <%= category != null ? category : "" %></td>
                <td><%= fullName.trim() %></td>
                <td><%= motivation != null ? motivation : "" %></td>
                <td><%= share != null ? share : "" %></td>
            </tr>
    <%
            } // End of while loop

            // --- Display "No results" message if needed ---
            if (!resultsFound) {
                 out.println("<tr><td colspan='4' style='text-align: center;'>No results found matching your search criteria.</td></tr>");
            }

        } catch (SQLException e) {
            // --- Error Handling ---
            out.println("<tr><td colspan='4' style='color:red; text-align: center;'>Database Error!</td></tr>");
            out.println("<tr><td colspan='4'>SQL State: " + e.getSQLState() + " Error: " + e.getMessage() + "</td></tr>");
            System.err.println("SQL Error: " + e.getMessage()); // Log error to catalina.out
            e.printStackTrace(); // Full stack trace to catalina.out for debugging
        } catch (ClassNotFoundException e) {
            out.println("<tr><td colspan='4' style='color:red; text-align: center;'>Driver Error! JDBC Driver Class Not Found!</td></tr>");
            System.err.println("JDBC Driver Error: " + e.getMessage());
        } finally {
            // --- Safely Close Resources ---
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    %>
        </tbody>
    </table>

</body>
</html>

