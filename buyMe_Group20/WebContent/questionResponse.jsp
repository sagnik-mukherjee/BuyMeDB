<%@ page language="java" contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
    <title>Frequently Asked Questions</title>
    <link rel="stylesheet" href="style.css"/>
</head>
<body>
	<%@ include file="navbar.jsp"%>
	<div class="content">

		<% 
		
		String connectionUrl = "jdbc:mysql://localhost:3306/buyMe" +
            "?verifyServerCertificate=false&useSSL=true";
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		
		try {   		
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			conn = DriverManager.getConnection(connectionUrl, "root", "UN5AW!]x9K{[bP");
			String username = (session.getAttribute("user")).toString();
			String questionsQuery = "SELECT question, answer FROM Questions WHERE userAcc=?";
			
			ps = conn.prepareStatement(questionsQuery);
			ps.setString(1, username);
			rs = ps.executeQuery();
			
			if(rs.next()){ %>
		<h1>Question Results:</h1>
		<p style="font-size: 8pt;">Please await Customer Rep response.</p>
		<table>
			<tr>
				<th>Question</th>
				<th>Answer</th>
			</tr>
			<% do { %>
			<tr>
				<td><%= rs.getString("question") %></td>
				<td><%= rs.getString("answer") %></td>
			</tr>
			<% 		} while(rs.next()); %>
		</table>
		<% 	} else { %>
		<br>
		<h3>There are currently no answers.</h3>
		<%	}  %>

		<%
		
		} catch (SQLException e){
			out.print("<p>Error occurred during mySQL server connection.</p>");
		    e.printStackTrace();    			
		} finally {
			try { rs.close(); } catch (Exception ignored) {}
			try { conn.close(); } catch (Exception ignored) {}
		}   		
	%>
		<p>
			<a href="questions.jsp">Click here to return to ask another
				questions</a>
		</p>
	</div>
</body>
</html>
