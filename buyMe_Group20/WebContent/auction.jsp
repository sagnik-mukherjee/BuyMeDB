<%@ page language="java" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.text.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
    <title>BuyMe</title>
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
				PreparedStatement ps1 = null;
				PreparedStatement ps2 = null;
				PreparedStatement ps3 = null;
				PreparedStatement autoPs = null;

				ResultSet rs = null;
				ResultSet bids1 = null;
				ResultSet bids2 = null;
				ResultSet autoRs = null;
				
				boolean isStartingBid = false;
				
				try {
					Class.forName("com.mysql.jdbc.Driver").newInstance();
					conn = DriverManager.getConnection(connectionUrl, "root", "UN5AW!]x9K{[bP");
				
					String user = session.getAttribute("user").toString();
					int productId = Integer.parseInt(request.getParameter("productId"));
					String accessLevel = (String) session.getAttribute("accessLevel");
					String productQuery = "SELECT * FROM Product WHERE productId=?";
					ps1 = conn.prepareStatement(productQuery);
					ps1.setInt(1, productId);
					
					rs = ps1.executeQuery();
					if (!rs.next()) {
						response.sendRedirect("error.jsp"); // Occurs if there is no row in Product table with the given productId
						return;
					} 
			%>

		<!-- Let user know bid has been placed if redirected from bidHandler.jsp -->
		<% 
					Enumeration<String> params = request.getParameterNames();
					params.nextElement();
					if (params.hasMoreElements()) {
						params.nextElement();
						if ((request.getParameter("bid")).equals("success")) { 
				%>
		<h2>Your bid has been placed successfully.</h2>
		<br>
		<% 
						}
					} 
					%>

		<h2>
			Auction Category:
			<%= rs.getString("category") %></h2>
		<br> Brand:
		<%= rs.getString("brand") %>
		<br> Damage Condition:
		<%= rs.getString("damageCondition") %>
		<br> Color:
		<%= rs.getString("color") %>
		<br> Seller:
		<%= rs.getString("sellerAccount") %>
		<br> End Date/Time:
		<%= rs.getString("endDate") %>
		<br>

		<% 
					Locale locale = new Locale("en", "US");
					NumberFormat currency = NumberFormat.getCurrencyInstance(locale);
					if (rs.getBoolean("sold")) {
						// Query to get the winner of the auction
						String winner = "SELECT * FROM BuyingHistory WHERE productId=?";
						PreparedStatement winnerPs = conn.prepareStatement(winner);
						winnerPs.setInt(1, productId);
						ResultSet winnerRs = winnerPs.executeQuery();
						winnerRs.next();
					%>

		<b>SOLD TO:</b>
		<%= winnerRs.getString("buyerAccount") %>
		for
		<%= currency.format(winnerRs.getDouble("price")) %>
		<%	try { winnerRs.close(); } catch (Exception ignored) {}
						try { winnerPs.close(); } catch (Exception ignored) {}
					} else {
						double price = rs.getDouble("price");
						double minPrice = price + 0.01;
						// Query to get history of bids for the current product
						String bidQuery = "SELECT * FROM BidHistory WHERE productId=? ORDER BY bid DESC";
						ps2 = conn.prepareStatement(bidQuery);
						ps2.setInt(1, productId);
						
						bids1 = ps2.executeQuery();
						if (!bids1.next()) { 
							isStartingBid = true;
					%>
		Starting Bid:
		<%= currency.format(price) %>
		<br>
		<%	} else {
						    //set false again
							isStartingBid = false; 
					%>
		Current bid:
		<%= currency.format(price) %>
		<br>
		<% } %>
		<!-- Place bid if not seller -->
		<% if (!session.getAttribute("user").equals(rs.getString("sellerAccount")) && accessLevel.equals("END_USER")) {
								// Check if user has autobid setup for this product, if no display the following
								String queryAutoBid = "SELECT * FROM AutoBidder WHERE userAcc=? AND productId=?";
								autoPs = conn.prepareStatement(queryAutoBid);
								autoPs.setString(1, user);
								autoPs.setInt(2, productId);
								autoRs = autoPs.executeQuery();
								if (!autoRs.next()) { %>
		<form
			action="bidHandler.jsp?bidder=<%= user %>&productId=<%= productId %>&isStartingBid=<%= isStartingBid %>"
			method="POST" class="place-bid-form">
			<% if (isStartingBid) { %>
			<label for="bidAmount">Bid <%= currency.format(price) %> or
				higher
			</label><br> <input type="number" step="0.01" name="bid"
				placeholder="Enter bid" min="<%= price %>" max="100000000.01"
				id="bidAmount" required>
			<% } else { %>
			<label for="bidAmount">Bid higher than <%= currency.format(price) %></label><br>
			<input type="number" step="0.01" name="bid" placeholder="Enter bid"
				min="<%= minPrice %>" max="100000000.01" id="bidAmount" required>
			<% } %>
			<input type="submit" value="Place bid">
		</form>
		or
		<h4 class="auto-bid-title">Setup Automatic Bidding</h4>
		<form
			action="bidHandler.jsp?bidder=<%= user %>&productId=<%= productId %>&isStartingBid=<%= isStartingBid %>&auto=true"
			method="POST" class="auto-bid-form">
			<% %>if (isStartingBid) {
            <label for="bidAmount">Start auto-bidding at <%= currency.format(price) %>
				or higher
			</label><br> <input type="number" step="0.01" name="bid"
				placeholder="Enter bid" min="<%= price %>" max="100000000.01"
				id="bidAmount" required><br> <label for="bidIncrement">Auto-bid
				increment</label><br> <input type="number" step="0.01"
				name="bidIncrement" placeholder="Enter the increment amount"
				min="0.01" max="100000000.01" id="bidIncrement" required><br>

			<label for="maxBid">Upper Limit</label><br> <input type="number"
				step="0.01" name="maxBid" placeholder="Enter upper limit" min="0.01"
				max="100000000.01" id="maxBid" required>
            } else {
            <label for="bidAmount">Start auto-bidding higher than <%= currency.format(price) %></label><br>
			<input type="number" step="0.01" name="bid" placeholder="Enter bid"
				min="<%= minPrice %>" max="100000000.01" id="bidAmount" required><br>

			<label for="bidIncrement">Auto-bid increment</label><br> <input
				type="number" step="0.01" name="bidIncrement"
				placeholder="Enter the increment amount" min="0.01"
				max="100000000.01" id="bidIncrement" required><br> <label
				for="maxBid">Upper Limit</label><br> <input type="number"
				step="0.01" name="maxBid" placeholder="Enter upper limit" min="0.01"
				max="100000000.01" id="maxBid" required>
            }<% %>
			<br>
			<input type="submit" value="Start auto-bid">
		</form>
		<%	} else { %>
		<h2>You have setup automatic bidding for this auction.</h2>
		<%	}
					   } else if (accessLevel.equals("CUSTOMER_REP") || accessLevel.equals("ADMIN")) { %>
		<form
			action="cancelAuctionHandler.jsp?productId=<%= productId %>&sellerAccount=<%= rs.getString("sellerAccount") %>"
			method="POST">
			<br>
			<input type="submit" value="Delete auction">
		</form>
		<% } %>

		<!-- Display bid history if any bids have been placed -->
		<%
						ps3 = conn.prepareStatement(bidQuery);
						ps3.setInt(1, productId);
						
						bids2 = ps3.executeQuery();
						if (bids2.next()) { 
					%>
		<h2>Bid History</h2>
		<table>
			<tr>
				<th>Bidder</th>
				<th>Bid Amount</th>
			</tr>
			<%	do { %>
			<tr>
				<td><%= bids2.getString("buyerAccount") %></td>
				<td><%= currency.format(bids2.getDouble("bid")) %></td>
			</tr>
			<%	} while (bids2.next()); %>
		</table>
		<%	} else { %>
		<h2>There are currently no bids for this auction.</h2>
		<br>
		<%	} 
					
					}
				
					ResultSet similarItems = null;
					String damageConditionFixed = (rs.getString("damageCondition")).replace("'", "\\'");
					String similarQuery = "SELECT * FROM Product WHERE productId!=" + productId
							+ " AND (brand LIKE '" + rs.getString("brand") +
							" AND damageCondition LIKE '" + damageConditionFixed + "\'))";
					Statement s = conn.createStatement();
					similarItems = s.executeQuery(similarQuery);
					if (similarItems.next()) { 
				%>
		<h2>Similar items on auction:</h2>
		<table>
			<tr>
				<th>Item</th>
				<th>Seller</th>
				<th>Current Bid</th>
				<th>End Date/Time</th>
			</tr>
			<%	do { %>
			<tr>
				<td><a
					href="auction.jsp?productId=<%= similarItems.getInt("productId") %>">
						<%= similarItems.getString("brand") + " " 
					+ similarItems.getString("damageCondition") %>
				</a></td>
				<td><%= similarItems.getString("sellerAccount") %></td>
				<td><%= currency.format(similarItems.getDouble("price")) %></td>
				<td><%= similarItems.getString("endDate") %></td>
			</tr>
			<%		} while (similarItems.next()); %>
		</table>
		<%	} else { %>
		<br>
		<h3>There are no similar items in the auction.</h3>
		<%	} 							
				} catch(SQLException e) {
					out.print("<p>Error occurred during mySQL server connection.</p>");
			        e.printStackTrace();
				} finally {
					try { rs.close(); } catch (Exception ignored) {}
					try { bids1.close(); } catch (Exception ignored) {}
					try { bids2.close(); } catch (Exception ignored) {}
					try { ps1.close(); } catch (Exception ignored) {}
					try { ps2.close(); } catch (Exception ignored) {}
					try { ps3.close(); } catch (Exception ignored) {}
					try { autoPs.close(); } catch (Exception ignored) {}
			        try { conn.close(); } catch (Exception ignored) {}
				}
			%>
	</div>
	<% } %>
</body>
</html>
