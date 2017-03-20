<!--
Program: Student Roster Building Block code
Author : Zachary Levine
-->
<%@page import="java.util.*,
	blackboard.base.*,
	blackboard.data.*,
		blackboard.data.course.*,
		blackboard.data.user.*,
	blackboard.persist.*,
		blackboard.persist.user.*,
		blackboard.persist.data.*,
		blackboard.persist.course.*,
	blackboard.platform.*,
		blackboard.platform.persistence.*"
	errorPage="/error.jsp"                
%>

<SCRIPT LANGUAGE="JavaScript">
function imageError( theImage ){
	
	theImage.src="https://octet1.csr.oberlin.edu/octet/Bb/Faculty/img/noimage.jpg";
	theImage.onerror = null;
}
</script>

<%@ taglib uri="/bbData" prefix="bbData"%>               
<%@ taglib uri="/bbUI" prefix="bbUI"%>
<bbData:context id="ctx">

<%
//Getting the course ID from Blackboard as a string
BbPersistenceManager bbPM = PersistenceServiceFactory.getInstance().getDbPersistenceManager();
Id id = bbPM.generateId( Course.DATA_TYPE, request.getParameter("course_id"));
String courseID = ((Course) id.load() ).getCourseId();
%>

 <style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
-->
 </style>

<!--Blackboard navigation/display information-->
<bbUI:docTemplate title="Student Roster">
<bbUI:coursePage courseId="<%=id%>">
<bbUI:breadcrumbBar handle="control_panel" isContent="true">
 <bbUI:breadcrumb>Student Roster</bbUI:breadcrumb>
</bbUI:breadcrumbBar>
<bbUI:titleBar>Student Roster</bbUI:titleBar>
<%
	//Make sure this is a course and not an organization or exco
	boolean validCourse = false;
	if( courseID.startsWith( "20" ) ){
		if( courseID.contains( "EXCO" ) ){
			validCourse = false;
		}else{
			validCourse = true;
		}
	}
	//If the option should be available - make available only for departments, advising organizations and regular courses 
	if( courseID.startsWith("P-") || courseID.startsWith("DEPT-") || courseID.startsWith("AD-") || courseID.startsWith("DSt-AmReads") || courseID.startsWith("SL-ODS") || 
		courseID.startsWith ( "OC-Fac_Coll" ) || courseID.startsWith( "CD-" ) || validCourse ){
		validCourse = true;
	}
	//If it is allowed to view the roster in this situation
	if( validCourse ){
		
		%>
		<span class="style1">Note:</span> These pictures are confidential and should only be used to help you
		identify the students in your course. Please make every effort to guard the
		confidentiality of your students by keeping the printed copy in your
		possession or storing it in a secure location at all times.
		<%
		
		//Get the UserList, and the Loader to get each person's Course Membership
		UserDbLoader udbl = (UserDbLoader)bbPM.getLoader( UserDbLoader.TYPE );
		CourseMembershipDbLoader cmdbl = (CourseMembershipDbLoader)bbPM.getLoader( CourseMembershipDbLoader.TYPE );
		//The actual user list
		BbList allUsers = udbl.loadByCourseId( id );
		BbList.Iterator filterIt = allUsers.getFilteringIterator();
		//List to add all the *students* in the userlist to
		BbList students = new BbList();
		
		//Counter for how many users will be displayed
		int j = 0;
		while( filterIt.hasNext() ){
			
			//Check the user's role and add from the UserList if they are *students*
			User currUser = (User)filterIt.next();
			CourseMembership membership = cmdbl.loadByCourseAndUserId( id, currUser.getId() );
			if( membership.getRole() == membership.getRole().STUDENT ){
				students.add( currUser );
				j++;
			}
		}%>
		<br/>
		Number of student users: <%=j%>
		<br/>
		<%
		
		//Sort alphabetically in ascending order by last name, then first name 
		GenericFieldComparator gfc1 = new GenericFieldComparator( true, "getFamilyName", User.class );
		GenericFieldComparator gfc2 = new GenericFieldComparator( true, "getGivenName", User.class );
		gfc1.appendSecondaryComparator( gfc2 );
		Collections.sort( students, gfc1 );
		
		BbList.Iterator it = students.getFilteringIterator();
		int i = 0;
		%>
		<table cellpadding="30">
		<%
		//Display each students photo, and information
		while( it.hasNext() ){ 
			//Display user information
			User curr = (User)it.next();
			i++;
			%>
			<!--Display user's photo, followed by their name-->
			<td><div align="left"><img src="https://octet1.csr.oberlin.edu/octet/Bb/Photos/expo/<%=curr.getUserName() %>/profileImage" onError="imageError(this)"><br>
				<%=curr.getGivenName() %> &nbsp;<%=curr.getFamilyName() %><br/><%
				//Display this student's email address
				String address = curr.getEmailAddress();
				if( !address.isEmpty() ){
					%><a href="mailto:<%=address%>"><%=curr.getUserName() %>@oberlin.edu</a><br/><%
				}else{
					%><br/><%
				}
				//Display this student's educational level
				String bus = curr.getBusinessFax();
				if( !bus.isEmpty() ){
					%><%=bus %><br/><%
				}else{
					%><br/><%
				}
				//Display this student's majors
				String dept = curr.getDepartment();
				if( !dept.isEmpty() ){
					%><%=dept %><br/><%
				}else{
					%><br/><%
				}
				//Display this student's particular class dean (with their email address)
				String dean = curr.getStudentId();
				if( !dean.isEmpty() ){					
					%>Class Dean<br/><%
					if( dean.contains( "awaguchi" ) ){
						%>&nbsp;&nbsp;&nbsp;<a href="mailto:shozo.kawaguchi@oberlin.edu">Shozo Kawaguchi</a></div></td><%
					}
					else if( dean.contains( "onaldson" ) ){
						%>&nbsp;&nbsp;&nbsp;<a href="mailto:chris.donaldson@oberlin.edu">Chris Donaldson</a></div></td><%
					}
					else if( dean.contains( "urgdorf" ) ){
						%>&nbsp;&nbsp;&nbsp;<a href="mailto:monique.burgdorf@oberlin.edu">Monique Burgdorf</a></div></td><%
					}
					else if( dean.contains( "autista" ) ){
						%>&nbsp;&nbsp;&nbsp;<a href="mailto:adrian.bautista@oberlin.edu">Adrian Bautista</a></div></td><%
					}
					else if( dean.contains( "iller" ) ){
						%>&nbsp;&nbsp;&nbsp;<a href="mailto:brenda.grier-miller@oberlin.edu">Brenda Grier-Miller</a></div></td><%
					}
					else if( dean.contains( "lood" ) ){
						%>&nbsp;&nbsp;&nbsp;<a href="mailto:lori.flood@oberlin.edu">Lori Flood</a></div></td><%
					}
					else{
						%>&nbsp;&nbsp;&nbsp;<a href="mailto:shozo.kawaguchi@oberlin.edu">Dean of Students</a></div></td><%
					}
				}else{
					%></div></td><%
				}
			if( i % 4 == 0 ){
				//Display four students per row
				%></tr><tr><%
			}
		}
		%>
		</table>
		<%
	
	}else{
		out.print( "You do not have permission to access student photos." );
	}
%>
</bbUI:coursePage>
</bbUI:docTemplate>
 </bbData:context>
 
