<%@page import="java.util.*,
				java.lang.Integer,
				blackboard.base.*,
				blackboard.data.*,
                blackboard.data.user.*,
				blackboard.data.course.*,
                blackboard.persist.*,
                blackboard.persist.user.*,
				blackboard.persist.course.*,
                blackboard.platform.*,
                blackboard.platform.persistence.*"
        errorPage="/error.jsp"                
%>

<%@ taglib uri="/bbData" prefix="bbData"%>                
<%@ taglib uri="/bbUI" prefix="bbUI"%>
<bbData:context id="ctx">
<%
/* This building block displays a student roster in every course and organization.
 * The student roster is only accessible through the control panel, thus only users with
 * access to the control panel can see it (such as instructors or teaching assitants)
 */
// create a persistence manager - needed for using loaders and persisters
BbPersistenceManager bbPm = BbServiceManager.getPersistenceService().getDbPersistenceManager();

//get the course id for the current course (that we are in) - this is the internal id e.g. "_2345_1"
Id courseId = bbPm.generateId(Course.DATA_TYPE, request.getParameter("course_id")); 
%>
 <style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
-->
 </style>
 
<bbUI:docTemplate title="Student Roster">
<bbUI:coursePage courseId="<%=courseId%>">
<bbUI:breadcrumbBar handle="control_panel" isContent="true">
 <bbUI:breadcrumb>Student Roster EX</bbUI:breadcrumb>
</bbUI:breadcrumbBar>
<bbUI:titleBar>Student Roster EX</bbUI:titleBar>
<%
// makes sure that this option should be available for the course we are in
// Exco course along with any non-department, non-advising oganisations do not have access
//get the external course id - this is the Id you can search for in blackboard e.g. "DEPT-BIOL" or "200702-GEOL-110-01"
String id = ((Course)courseId.load()).getCourseId();
// is this a course which should have the roster? Roster is only made available for regular courses
boolean course;

try{
		// try converting the first 4 characters of the id to an integer (regular course id's start with the year they are taught)
		Integer temp = new Integer(id.substring(0,4));
		// make sure that the course is not EXCO
		if(id.substring(6).startsWith("-EXCO-")){
			course = false;
		}
		else{
			course = true;
		}
	}
catch(NumberFormatException e){
	course = false;
}
if(id.startsWith("P-")){
			course = true;
		}
// if the option should be available - make available only for departments, advising organizations and regular courses
if(id.startsWith("DEPT-") || id.startsWith("AD-") || id.startsWith("DSt-AmReads") || id.startsWith("SL-ODS") || id.startsWith ("OC-Fac_Coll") || id.startsWith("CD-") ||course)
{ 
	// if current user has clicked "I understand", display the photos
	//if(request.getParameter("displayPhotos")!=null)
	//{
%>
			<span class="style1">Note:</span> These pictures are confidential and should only be used to help you
			identify the students in your course. Please make every effort to guard the
			confidentiality of your students by keeping the printed copy in your
			possession or storing it in a secure location at all times.
			<%
		// create a Dbloader for users
		UserDbLoader loader = (UserDbLoader) bbPm.getLoader( UserDbLoader.TYPE );
		blackboard.base.BbList userlist = null;
		//load all users enrolled in the current course
		userlist = loader.loadByCourseId(courseId);
		
		
		
		// create a database loader for course membership objects
		CourseMembershipDbLoader cmLoader = (CourseMembershipDbLoader)bbPm.getLoader( CourseMembershipDbLoader.TYPE );
		// create a list to hold all students
		BbList students = new BbList();
		
		// iterate thorugh the user list, keep only people enrolled with role Student/Participant
		BbList.Iterator userIter = userlist.getFilteringIterator();
		while(userIter.hasNext())
		{	//get the next user
			User thisUser = (User)userIter.next();
			
			// now use the CourseMembershipDBLoader to load the CourseMembership data for this user in this course.
			CourseMembership cmData = cmLoader.loadByCourseAndUserId(courseId, thisUser.getId());
			if (cmData.getRole() == cmData.getRole().STUDENT)
			{	//add the user to the list of students if he/she is a student
				 students.add(thisUser);
			}
		} 
		
			// sort students by last name, first name
			GenericFieldComparator comparator = new GenericFieldComparator(BaseComparator.ASCENDING,"getFamilyName",User.class);
			comparator.appendSecondaryComparator(new GenericFieldComparator(BaseComparator.ASCENDING,"getGivenName",User.class));
			Collections.sort(students,comparator);
		%>
		<table cellpadding="30"><tr>
		<%
		// display the pictures of students
		BbList.Iterator studIter = students.getFilteringIterator();
		int i = 0;
		while(studIter.hasNext())
		{ 
			User thisUser = (User)studIter.next();
			i++;
			%>
			<td><div align="left"><img src="https://idcard.oberlin.edu/feed/photo/profile.php?id=<%=thisUser.getUserName()%>&b/profileImage" onError="imageError(this)">
				<br>
				<%=thisUser.getGivenName() %> &nbsp;<%=thisUser.getFamilyName() %><br/>
				<%=thisUser.getBusinessFax() %><br/>
				<a href="mailto:<%=thisUser.getEmailAddress()"%> %><br/>
				Class Dean <%=thisUser.getBusinessPhone2() %><br/>
				<%=thisUser.getDepartment() %></div></td>
			<%
			if(i%4==0)
			{
			%></tr><tr><%
			}
		}
		%>
		</table>
		<%


}
else // exco courses and general organizations do not have access to student photos
{
out.print("This option is not available for your course/organization at this time.");
}
%>
</bbUI:coursePage>
</bbUI:docTemplate>
 </bbData:context>
 
