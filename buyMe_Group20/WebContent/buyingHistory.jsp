<%@ page pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.text.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
    <title>Your Buying History</title>
    <link rel="stylesheet" href="style.css"/>
</head>
<body>
	<% if (session.getAttribute("user") == null) {
    		response.sendRedirect("login.jsp");
       } else { %>
	<%@ include file="navbar.jsp"%>
	<div class="content">
		<% 
   			String connectionUrl = "jdbc:mysql://localhost:3306/buyMe" +
                    "?verifyServerCertificate=false&useSSL=true";
			Connection conn = null;
			PreparedStatement ps = null;
			ResultSet rs1 = null;
			ResultSet rs2 = null;
			ResultSet rs3 = null;
			
   			try {
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                } catch (ClassNotFoundException e) {
                    e.printStackTrace();
                }
                conn = DriverManager.getConnection(connectionUrl, "root", "UN5AW!]x9K{[bP");
   				
   				String user = (session.getAttribute("user")).toString(); 				
   				// Create formatter for US currency
   				Locale locale = new Locale("en", "US");
   				NumberFormat currency = NumberFormat.getCurrencyInstance(locale);
   				
   				String buyQuery = "SELECT * FROM BuyingHistory WHERE buyerAccount=? ORDER BY purchaseDate DESC";
   				ps = conn.prepareStatement(buyQuery);
   				ps.setString(1, user);
   				rs1 = ps.executeQuery();
   				
   				if (rs1.next()) { %>
		<h2>Your Purchase History</h2>
		<table>
			<tr>
				<th>Item Name</th>
				<th>Price</th>
				<th>Seller</th>
				<th>Date</th>
			</tr>
			<%	do { 
   						int productId = rs1.getInt("productId");
   						String itemName = null;
   						String productQuery = "SELECT brand, damageCondition FROM Product WHERE productId=?";
   						ps = conn.prepareStatement(productQuery);
   						ps.setInt(1, productId);
   						rs2 = ps.executeQuery();
   						if (rs2.next()) {
   							itemName = rs2.getString("brand") + rs2.getString("damageCondition");
   						} else {
   							itemName = "productId not found";
   						}
   						ps.close();
   						
   						String sellQuery = "SELECT sellerAccount FROM SellingHistory WHERE productId=?";
   						ps = conn.prepareStatement(sellQuery);
   						ps.setInt(1, productId);
   						rs3 = ps.executeQuery();
   						rs3.next();
   				%>
			<tr>
				<td><%= itemName %></td>
				<td><%= currency.format(rs1.getDouble("price")) %></td>
				<td><%= rs3.getString("sellerAccount") %></td>
				<td><%= rs1.getString("date") %></td>
			</tr>
			<%	} while (rs1.next()); %>
		</table>
		<%	} else { %>
		<h2>You have not purchased any items.</h2>
		<%	} 		
   			} catch (SQLException e) {
   				response.sendRedirect("error.jsp");
   				out.print("<h1>Error occurred during mySQL server connection.</h1>");
		        e.printStackTrace();
   			} finally {
   				try {
                    assert rs1 != null;
                    rs1.close(); } catch (Exception ignored) {}
   				try {
                    assert rs2 != null;
                    rs2.close(); } catch (Exception ignored) {}
   				try {
                    assert rs3 != null;
                    rs3.close(); } catch (Exception ignored) {}
   				try { ps.close(); } catch (Exception ignored) {}
   				try { conn.close(); } catch (Exception ignored) {}
   			} %>
	</div>
	<% } %>
</body>
</html>
