import java.sql.*;

// Remember that part of your mark is for doing as much in SQL (not Java) 
// as you can. At most you can justify using an array, or the more flexible
// ArrayList. Don't go crazy with it, though. You need it rarely if at all.
import java.util.ArrayList;

public class Assignment2 {

    // A connection to the database
    Connection connection;

    Assignment2() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects to the database and sets the search path.
     * 
     * Establishes a connection to be used for this session, assigning it to the
     * instance variable 'connection'. In addition, sets the search path to
     * markus.
     * 
     * @param url
     *            the url for the database
     * @param username
     *            the username to be used to connect to the database
     * @param password
     *            the password to be used to connect to the database
     * @return true if connecting is successful, false otherwise
     */
    public boolean connectDB(String URL, String username, String password) {
    	String path = "SET search_path TO markus;";
    	try {
    		connection = DriverManager.getConnection(URL, username, password);
    	    Statement s = connection.createStatement();
    	    s.executeUpdate(path);
    	    return true;
    	} catch (SQLException e) {
    	  e.printStackTrace();
    	  return false;
    	}
    }
   

    /**
     * Closes the database connection.
     * 
     * @return true if the closing was successful, false otherwise
     */
    public boolean disconnectDB() {
    	try{
			connection.close();
			return true;
		}
		catch(SQLException e){
			e.printStackTrace();
			return false;
		}
    }

    /**
     * Assigns a grader for a group for an assignment.
     * 
     * Returns false if the groupID does not exist in the AssignmentGroup table,
     * if some grader has already been assigned to the group, or if grader is
     * not either a TA or instructor.
     * 
     * @param groupID
     *            id of the group
     * @param grader
     *            username of the grader
     * @return true if the operation was successful, false otherwise
     */
    public boolean assignGrader(int groupID, String grader) {
    	try{
			ResultSet rs;
			
			// check if grader is a not a TA or instructor
			String query1 = "SELECT type FROM MarkusUser " + 
				    "WHERE Grader.username = " + grader + ";";
			PreparedStatement ps1 = connection.prepareStatement(query1);
	        rs = ps1.executeQuery();
	        rs.next();
	        String type = rs.getString("type");
	        if (!(type.equals("TA") || type.equals("instructor"))){
	        	System.out.println("grader is not either a TA or instructor");
	        	return false;
	        }
	        rs.close();

	        // check if groupID exists, if not return false
	        String query2 = "SELECT * FROM AssignmentGroup WHERE group_id = " + groupID + ";";
	        PreparedStatement ps2 = connection.prepareStatement(query2);
	        rs = ps2.executeQuery();
	        if (!rs.next()){
	        	System.out.println("some grader has already been assigned to the group");
	        	return false;
	        }
	        rs.close();
	        
	        //check if some grader has already been assigned to the group
	        String query3 = "SELECT * FROM Grader WHERE group_id = " + groupID +";"; 
	        PreparedStatement ps3 = connection.prepareStatement(query3);
	        rs = ps3.executeQuery();
	        if (rs.next()){
	        	System.out.println("the groupID does not exist in the AssignmentGroup table");
	        	return false;
	        }
	        rs.close();

	        String query = "INSERT INTO Grader (group_id, username) VALUES (?, ?);";
	        PreparedStatement ps = connection.prepareStatement(query);
			ps.setInt(1, groupID);
			ps.setString(2, grader);
			return ps.executeUpdate() == 1;
		}
    	catch(SQLException e){
			e.printStackTrace();
			return false;
		}
    }

    /**
     * Adds a member to a group for an assignment.
     * 
     * Records the fact that a new member is part of a group for an assignment.
     * Does nothing (but returns true) if the member is already declared to be
     * in the group.
     * 
     * Does nothing and returns false if any of these conditions hold: - the
     * group is already at capacity, - newMember is not a valid username or is
     * not a student, - there is no assignment with this assignment ID, or - the
     * group ID has not been declared for the assignment.
     * 
     * @param assignmentID
     *            id of the assignment
     * @param groupID
     *            id of the group to receive a new member
     * @param newMember
     *            username of the new member to be added to the group
     * @return true if the operation was successful, false otherwise
     */
    public boolean recordMember(int assignmentID, int groupID, String newMember) {
    	try{
    		PreparedStatement ps;
			ResultSet rs;
			String query;

			// check if newMember is valid
			query = "SELECT * FROM MarkusUser WHERE username = " + newMember + ";";
			ps = connection.prepareStatement(query);
			rs = ps.executeQuery();
			if (!rs.next()){
				System.out.println("newMember is not a valid username");
	        	return false;
			}
			rs.close();
			
			// check if newMember is valid
			query = "SELECT * FROM MarkusUser WHERE username = " + newMember + ";";
			ps = connection.prepareStatement(query);
			rs = ps.executeQuery();
			rs.next();
			String usertype = rs.getString("usertype");
	        if (!usertype.equals("student")){
				System.out.println("newMember is not a student");
	        	return false;
			}
	        rs.close();
	        
	             
	        
	         // check if assignment is valid
	     	query = "SELECT * FROM Assignment WHERE assignment_id = " + assignmentID + ";";
	     	ps = connection.prepareStatement(query);
	     	rs = ps.executeQuery();
	     	if (!rs.next()){
				System.out.println("assignment_id is not exists");
	        	return false;
			}
	     	rs.close();
	     	
	       // check if group is valid
	     	query = "SELECT * FROM Assignment WHERE assignment_id = " + assignmentID + 
	     			"AND group_id = " + groupID + ";";
	     	ps = connection.prepareStatement(query);
	     	rs = ps.executeQuery();
	     	if (!rs.next()){
				System.out.println("group_id is not exists");
	        	return false;
			}
	     	rs.close();
	     	
	     	 // Check if member in group and number of members in group
			query = "SELECT * FROM Membership "+
					  "NATURAL JOIN AssignmentGroup "+
					  "WHERE (group_id = "+ groupID + "AND assignment_id = " +
					     assignmentID + " );";
			ps = connection.prepareStatement(query);
			rs = ps.executeQuery();
			Integer num = 0;
			Boolean assigned = false;
			while(rs.next()){
				num += 1;
				if (rs.getString("username") == newMember) {
					 assigned = true;
					 break;
				}
			}
			rs.close();
			
	     	query = "SELECT * FROM Assignment NATURAL JOIN AssignmentGroup "+
					  "WHERE (group_id = "+ groupID + "AND assignment_id = " +
					     assignmentID + " );";
	     	ps = connection.prepareStatement(query);
	     	rs = ps.executeQuery();
	     	rs.next();
	     	if (num >= rs.getInt("group_max")){
				return false;
			}
	     	
	     	if (assigned) {
				return true;
			}
	     	rs.close();
	     	
	     	query = "INSERT INTO Membership (username, group_id) VALUES (?, ?);";
			ps = connection.prepareStatement(query);
			ps.setString(1, newMember);
			ps.setInt(2, groupID);
			ps.executeUpdate();				
			return true;
			} catch (SQLException e) {
				e.printStackTrace();
				return false;
			}	

	}

    /**
     * Creates student groups for an assignment.
     * 
     * Finds all students who are defined in the Users table and puts each of
     * them into a group for the assignment. Suppose there are n. Each group
     * will be of the maximum size allowed for the assignment (call that k),
     * except for possibly one group of smaller size if n is not divisible by k.
     * Note that k may be as low as 1.
     * 
     * The choice of which students to put together is based on their grades on
     * another assignment, as recorded in table Results. Starting from the
     * highest grade on that other assignment, the top k students go into one
     * group, then the next k students go into the next, and so on. The last n %
     * k students form a smaller group.
     * 
     * In the extreme case that there are no students, does nothing and returns
     * true.
     * 
     * Students with no grade recorded for the other assignment come at the
     * bottom of the list, after students who received zero. When there is a tie
     * for grade (or non-grade) on the other assignment, takes students in order
     * by username, using alphabetical order from A to Z.
     * 
     * When a group is created, its group ID is generated automatically because
     * the group_id attribute of table AssignmentGroup is of type SERIAL. The
     * value of attribute repo is repoPrefix + "/group_" + group_id
     * 
     * Does nothing and returns false if there is no assignment with ID
     * assignmentToGroup or no assignment with ID otherAssignment, or if any
     * group has already been defined for this assignment.
     * 
     * @param assignmentToGroup
     *            the assignment ID of the assignment for which groups are to be
     *            created
     * @param otherAssignment
     *            the assignment ID of the other assignment on which the
     *            grouping is to be based
     * @param repoPrefix
     *            the prefix of the URL for the group's repository
     * @return true if successful and false otherwise
     */
    public boolean createGroups(int assignmentToGroup, int otherAssignment,
            String repoPrefix) {
      
    	PreparedStatement ps;
		ResultSet rs;
		String query;
		
		// check that otherAssignment exists
		query = "SELECT assignment_id FROM Assignment WHERE assignment_id = " 
		+ otherAssignment +";";
		ps = connection.prepareStatement(query);
		rs = ps.executeQuery();
		if (!rs.next()) {
			return false;
		}
		rs.close();

		// check that assignmentToGroup exists and get max group sizes
		query = "SELECT assignment_id FROM Assignment WHERE assignment_id = " 
				+ assignmentToGroup +";";
		ps = connection.prepareStatement(query);
		rs = ps.executeQuery();
		if (!rs.next()) {
			return false;
		}else{
			int groupmax = rs.getInt("group_max");
		}
		rs.close();
		
		
		
		
		
    }
    
 

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Boo!");
    }
}
