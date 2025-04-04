// Hey, ignore @ts-nocheck, it's just me stopping the compiler from being stupid
// @ts-nocheck compiler errors

// Basic Server Functionality
import { dbInit, dbReset } from "./DatabaseThings.ts"; // DB initialization and reset (Reset doesn't work, just delete the file and reload)
import { oakCors } from "https://deno.land/x/cors/mod.ts"; // Cross Origin Resource Sharing (Restrict who can see server data)
import {Application, _Context, Router,} from "https://deno.land/x/oak@v12.5.0/mod.ts"; // Server things OAK
import { createHash, randomBytes } from "node:crypto"; // Secure random state value generation
import { Session, CookieStore } from "https://deno.land/x/oak_sessions/mod.ts"; // Session storing and cookie caching
// Misc
import nodemailer from "npm:nodemailer"; // Email sending (Doesn't work, don't use)

/**
 * 🚨 ATTENTION: (REALLY IMPORTANT) 🚨
 *
 * This server will NOT run unless you have a ".env" file inside this directory. (src/main/Deno/)
 * Please read ".env.example" before creating ".env" or running the server.
 */
// Map holding emails and a timer, email in this list cannot log in until timer=0
const loginAttemptTimers = new Map<string, NodeJS.Timeout>();
//dbID of user loggedIn
let dbID;
// Get env file
let env;
try {
    env = config({ path: "./.env" }); //(/src/main/Deno/.env)
} catch (error) {
    console.error(
        "Error reading .env file: ",
        error,
        "\n Ensure You have created the .env file correctly",
    );
    Deno.exit(1);
}

// Generate a secure 32 byte sha256 hex hash
function generateState(): string {
    return createHash("sha256").update(randomBytes(32)).digest("hex");
}

// Create a new database and fill it if it doesn't exist
const db = await dbInit();

// Create a new session
type AppState = {
    session: Session;
};

// Create a new application
const app = new Application<AppState>();

//Create a new router (routes to webpages)
const router = new Router<AppState>();

/** Reoute to get login status
 * Testing and Working - 2/4
 *
 * @returns {boolean} GoogleLoggedIn- True if user is logged in with Google, false if not
 * @returns {integer} userID - The active user's dbID
 */
router.get("/getLoggedIn", async (ctx) => {
    // const userId = ctx.state.session.get("id");
    const userId = dbID
    console.log(userId)
    if (userId !== undefined && userId !== null) {
        ctx.response.body = {GoogleLoggedIn: await validateLogin(), userID: userId};
        ctx.response.status = 200;
        console.log("User is logged in with TAC");
    } else {
        ctx.response.body = {GoogleLoggedIn: false, message: "User is not logged in"};
        ctx.response.status = 402;
        console.log("User is not logged in with TAC");
    }
});

/** Route to login user
 * Tested and Working - 2/4
 *
 * @param {string} email - The email of the user
 * @param {string} password - The password of the user
 *
 * @returns {integer} - status of route
 * 200: Login successful + DB id of teacher
 * 401: Invalid email or password
 */
router.post("/login", async (ctx) => {
    const { email, password } = await ctx.request.body().value;

    // Check login attemps
    if (ctx.state.session.get("loginAttempts") > 3) {
        const email = await ctx.request.body().value.email;
        if (!loginAttemptTimers.has(email)) {
            loginAttemptTimers.set(email, setTimeout(() => {
                ctx.state.session.set("loginAttempts", 0);
                loginAttemptTimers.delete(email);
            }, 5 * 60 * 1000)); // 5 minutes
        }

        ctx.response.status = 429;
        ctx.response.body = { message: "Too many login attempts, try again later" };
        return;
    }


    // Check if email and password are in the database
    const idResult = db.query("SELECT id FROM teachers WHERE email = ? AND password = ?", [email, password]);
    let hasGoogleResult = db.query("SELECT hasGoogle FROM teachers WHERE id = ?", idResult[0]);
    hasGoogleResult = (hasGoogleResult == 1) ? true : false;
    if(idResult[0][0] !== 0) {
        const id = idResult[0][0];
        console.log("Stored id in cookie as ", id)
        ctx.state.session.set("id", id);
        dbID = id;

        // Code no worky
        // let hasGoogle = false;
        // if (hasGoogleResult.length != 0 && hasGoogleResult[0].hasGoogle) {
        //   hasGoogle = true;
        // }
        let hasGoogle = true;


        console.log("Login successful \n\n\n\n\n\n\n\n\n");
        ctx.response.status = 200;
        ctx.response.body = { message: "Login successful", id: id , hasGoogle: hasGoogle};
    } else {
        ctx.response.status = 401;
        ctx.response.body = { message: "Invalid email or password, check server logs for more info" };

        if (ctx.state.session.get("loginAttempts") != 0) {
            ctx.state.session.set("loginAttempts", ctx.state.session.get("loginAttempts") + 1);
        } else {
            ctx.state.session.set("loginAttempts", 1);
        }
    }
});

/** Route to get all students
 * Tested and Working - 2/4
 *
 * @returns {JSON} - JSON object with all students in the database and their dbID, name, age, classID placeholder, and grade
 */
router.get("/students", (ctx) => {
    const students = [...db.query("SELECT * FROM students")];
    ctx.response.body = { students: students };
    ctx.response.status = 200;
});

/** Route to get a specific student by ID
 * Tested and Working - 2/4
 *
 * @param {integer} id - The dbID of the student
 * @returns {JSON} - JSON object with student dbID, name, age, classID placeholder and grade
 */
router.get("/student/:id", (ctx) => {
    const id = parseInt(ctx.params.id, 10);
    //Validation
    if (isNaN(id)) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Invalid ID" };
        return;
    }
    // Get user with according ID
    // If user is found, return user, else return 404
    const user = db.query("SELECT * FROM students WHERE id = ?", [id]);
    if (user.length > 0) {
        ctx.response.body = { student: user[0] };
        ctx.response.status = 200;
    } else {
        ctx.response.status = 404;
        ctx.response.body = { message: "Student not found" };
    }
});

/** Route to delete a student by ID
 * @deprecated
 *
 * DO NOT USE
 */
router.delete("/deleteStudent/:id", (ctx) => {
    const id = parseInt(ctx.params.id, 10);
    //Validation
    if (isNaN(id)) {
        ctx.response.status = 400;
        ctx.response.body = { message: "Invalid ID" };
        return;
    }
    // Get student with according ID
    // If student is found, delete student, else return 404
    const user = db.query("SELECT * FROM students WHERE id = ?", [id]);
    if (user.length > 0) {
        db.query("DELETE FROM students WHERE id = ?", [id]);
        ctx.response.body = { message: "Student deleted successfully, route is deprecated. Do not use" };
    } else {
        ctx.response.status = 404;
        ctx.response.body = { message: "Student not found, route is deprecated. Do not use" };
    }
});


/** Route to get all className, teacherName, and roomNumbers
 * Tested and Working - 2/4
 *
 * @input none
 *
 * @output JSON object with all classNames, roomNumbers and teacherNames (in that order)
 * @example
 * {
 *   "classes": [
 *     [
 *       1,
 *       "Math 101",
 *       101,
 *       "Mr. Smith"
 *     ]
 *  ]
 * }
 */
router.get("/classes", (ctx) => {
    const classes = [
        ...db.query(
            "SELECT c.*, t.name FROM classes c JOIN teacherClasses tc ON c.id = tc.class_id JOIN teachers t ON tc.teacher_id = t.id",
        ),
    ];
    ctx.response.body = { classes: classes };
});

/** Route to get a specific class by ID
 * Tested and Working - 2/4
 *
 * @param {integer} id - dbID of the class
 * @returns {JSON} - JSON object with dbID, name, and roomNumber of the class
 */
router.get("/class/:id", (ctx) => {
    const id = ctx.params.id;
    const classDetails = db.query("SELECT * FROM classes WHERE id = ?", [id]);
    if (classDetails.length > 0) {
        ctx.response.body = { class: classDetails[0] };
    } else {
        ctx.response.status = 404;
        ctx.response.body = { message: "class not found" };
    }
});

/** Reoute to get all classes for a specific teacher
 * Tested and Working - 2/4
 *
 * @param {integer} id - The teacher's dbID
 * @returns {JSON} - JSON object with all data for the classes for that teacher
 */
router.get("/teacherClasses/:id", (ctx) => {
    const id = ctx.params.id;
    const classes = db.query(
        "SELECT c.*, t.name FROM classes c JOIN teacherClasses tc ON c.id = tc.class_id JOIN teachers t ON tc.teacher_id = t.id WHERE t.id = ?",
        [id],
    );
    ctx.response.body = { classes: classes };
});

/** Route to add a student
 * Tested and Working - 2/4
 *
 * @param {String} name - The name of the student.
 * @param {integer} age - The age of the student.
 * @param {integer} classID - The class the student is in. (use /classes to find classID's)
 * @param {integer} grade - Max is 12 (Senior)
 */
router.put("/addStudent", async (ctx) => {
    const { name, age, classID, grade } = await ctx.request.body.json();
    // Validate inputs
    let parsedAge: number, parsedClassID: number, parsedGrade: number;
    try {
        parsedAge = parseInt(age, 10);
        parsedClassID = parseInt(classID, 10);
        parsedGrade = parseInt(grade, 10);
        if (isNaN(parsedAge) || isNaN(parsedClassID) || isNaN(parsedGrade)) {
            throw new Error("Invalid input");
        }
    } catch {
        ctx.response.status = 400;
        ctx.response.body = { message: "Invalid input" };
        return;
    }

    // Add student to database
    try {
        db.query(
            "INSERT INTO students (name, age, classID, grade) VALUES (?, ?, ?, ?)",
            [name, parsedAge, parsedClassID, parsedGrade],
        );
        ctx.response.body = { message: "Student added successfully" };
    } catch {
        ctx.response.status = 400;
        ctx.response.body = { message: "Error adding student" };
    }
});

/**
 * Adds a new class to the database.
 * Tested and Working - 2/4
 *
 * @route PUT /addClass
 * @param {string} className - The name of the class.
 * @param {string} teacherName - The name of the teacher.
 * @param {string} roomNumber - The room number (must be an integer).
 * @returns {string} A message indicating success or failure.
 */
router.put("/addClass", async (ctx) => {
    const { className, roomNumber } = await ctx.request.body().value;
    let roomNumberParsed;
    try {
        roomNumberParsed = parseInt(roomNumber, 10);
        if (isNaN(roomNumberParsed)) {
            console.log("error parsing int")
            throw new Error("Invalid input");
        }
    } catch {
        ctx.response.status = 400;
        ctx.response.body = { message: "Invalid input" };
        return;
    }
    // Add class to database
    try {
        db.query(
            "INSERT INTO classes (class, roomNumber) VALUES (?, ?)",
            [className, roomNumberParsed],
        );
        ctx.response.body = { message: "Class added successfully" };
    } catch (error) {
        ctx.response.status = 400;
        ctx.response.body = { message: "Error adding class" };
        console.log(error);
    }
});
/** Route to clear DB and restart
 * @deprecated
 *
 * DO NOT USE
 */
router.delete("/resetDB", async (ctx) => {
    try {
        await dbReset(db);
        ctx.response.body = {
            message: "Database reset successfully, please restart server",
        };
    } catch (error) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Error resetting database" };
        console.log("Error resetting database, error message: ", error);
    }
});

/** Route to get all grades for a specific class
 * @deprecated
 *
 * DO NOT USE
 */
router.get("/classGrades/:id", (ctx) => {
    try {
        const specificClassId = ctx.params.id;
        const grades = db.query(
            `
      SELECT g.grade, s.name, a.title 
      FROM grades g 
      JOIN assignments a ON g.assignmentID = a.id 
      JOIN students s ON g.studentID = s.id 
      WHERE a.classID = ?`,
            [specificClassId],
        );
        ctx.response.body = grades;
        ctx.response.status = 200;
    } catch (error) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Error getting grades for that class" };
        console.log("Error getting grades for that class, error: ", error);
    }
});

/** Route to get all assignments for a specific class
 * Tested and works - 2/4
 *
 * @route GET /classAssignments/:id
 * @param id: the dbID that points to the specific class
 */
router.get("/classAssignments/:id", (ctx) => {
    try {
        const specificClassId = ctx.params.id;
        const assignments = db.query(
            "SELECT * FROM assignments WHERE classID = ?",
            [specificClassId],
        );
        ctx.response.body = assignments;
        ctx.response.status = 200;
    } catch (error) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Error getting assignments for that class" };
        console.log("Error getting assignments for that class, error: ", error);
    }
});

// Route to get students grades for all assignments from student ID
router.get("/studentGrades/:id", (ctx) => {
    try {
        const specificStudentId = ctx.params.id;
        const grades = db.query(
            "SELECT * FROM grades WHERE studentID = ?",
            [specificStudentId],
        );
        ctx.response.body = grades;
        ctx.response.status = 200;
    } catch (error) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Error getting grades for that student" };
        console.log("Error getting grades for that student, error: ", error);
    }
});

/**Route to get student's grades for all assignments in a specifc class
 * Tested and works - 2/4
 *
 *
 * @route GET /studentClassGrades/:studentID/:classID
 *
 * @param studentID: the dbID the points to specific student
 * @param classID: the dbID that points to the specific class
 * @outputs JSON object with all grades for that student in that class
 *
 */
router.get("/studentClassGrades/:studentID/:classID", (ctx) => {
    try {
        const studentID = ctx.params.studentID;
        const classID = ctx.params.classID;
        const assignments = db.query(
            "SELECT title FROM assignments WHERE classID = ?",
            [classID],
        );
        const grades = db.query(
            "SELECT grade FROM grades WHERE studentID = ? AND assignmentID IN (SELECT id FROM assignments WHERE classID = ?)",
            [studentID, classID],
        );

        ctx.response.body = { class: classID, assignments: assignments.map((assignment, index) => ({ ...assignment, grade: grades[index] })) };
        ctx.response.status = 200;
    } catch (error) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Error getting grades for that student" };
        console.log("Error getting grades for student in class, error: ", error);
    }
});

/**
 * Route to get all students in a class
 * Tested and working - 2/4
 *
 * @route GET /classStudents/:id
 * @returns JSON with student name, age and grade grouped per student
 *
 * @example /classStudent/1
 * {"students":[
 *  {
 *    "studentName":"Student1",
 *    "studentAge":17,
 *    "studentGrade":10
 *    }]
 * }
 */
router.get("/classStudents/:id", (ctx) => {
    const id = ctx.params.id;
    const students = db.query("SELECT id, name, age, grade FROM students WHERE classID = ?", [id]);
    ctx.response.body = { students: students.map(student => ({ id: student[0], studentName: student[1], studentAge: student[2], studentGrade: student[3] })) };
    ctx.response.status = 200
});

/** -----------------------------------------------------------------------------------------------
 * Everything past this is GC routes
 *
 *
 * Route to verify user has a valid Google accessToken and call getAllClasses.
 * Tested and Working - 2/4
 *
 * @route GET /GoogleClasses
 * @param {Context} ctx - The context object.
 * @returns {void}
 */
router.get("/googleClasses", async (ctx) => {
    if(!await validateLogin()) {
        console.error("User not logged in");
        ctx.response.status = 401;
        ctx.response.body = { message: "User not logged in" }
        return;
    }

    const classroom = google.classroom({ version: "v1", auth: oauth2Client });
    try {
        const request = await classroom.courses.list();
        const courses = request.data.courses;

        if (courses && courses.length) {
            console.log('Courses:');
            courses.forEach((course) => {
                console.log(`${course.name} (${course.id})`);
            });

            ctx.response.body = { courses: courses };
            ctx.response.status = 200;

        } else {
            console.log('No courses found.');
            ctx.response.body = { message: "No courses found" };
            ctx.response.status = 204;
        }
    } catch (error) {
        console.error("Error fetching courses:", error);
        ctx.response.status = 500;
        ctx.response.body = { message: "Error fetching courses" };
    }
});
/** Route to get all Google Classroom grades for a specifc class
 *
 */
router.get("/googleGrades/:courseId", async (ctx) => {
    if(!await validateLogin()) {
        console.error("User not logged in");
        ctx.response.status = 401;
        ctx.response.body = { message: "User not logged in" }
        return;
    }

    const classroom = google.classroom({ version: "v1", auth: oauth2Client });
    const courseId = ctx.params.courseId;
    try {
        const submissions: classroom_v1.Schema$StudentSubmission[] = [];
        let nextPageToken: string | undefined;
        do {
            const response = await classroom.courses.courseWork.studentSubmissions
                .list({
                    courseId,
                    pageToken: nextPageToken,
                });
            submissions.push(...(response.data.studentSubmissions || []));
            nextPageToken = response.data.nextPageToken;
        } while (nextPageToken);

        ctx.response.status = 200;
        ctx.response.body = {submissions};
    } catch (error) {
        console.error(`Error retrieving grades for course ${courseId}:`, error);
        throw new Error("Failed to retrieve grades");
    }
});

/** -----------------------------------------------------------------------------------------------
 * Everything past this is OAuth implementation
 *
 * Routes are labeled by their order in the Authorization flow
 * 🚨 ATTENTION: (REALLY IMPORTANT) 🚨
 * FUTURE ME: SECURE THIS SERVER BEFORE DEPLOYMENT
 *
 * OAuth Explained step by step:
 *
 * 1. Redirect user to Auth0 login page
 *    - User clicks login button on frontend
 *    - Frontend sends a request to this server to get the Auth0 login page
 *    - This server redirects the user to the Auth0 login page
 *    - User logs in and is redirected back to this server
 * 2. Handle Auth0 callback and exchange code for tokens
 *    - Auth0 redirects user back to this server with a code
 *    - This server shows OAuth the secure code and OAuth returns the tokens
 *    - Server sends stores tokens and uses them to access user info
 * 3. Test secured route
 *    - Simple test to OAuth servers to test for valid tokens
 *
 *  OAuth for Idiots:
 *  - OAuth is a secure way to login to a website
 *  - It allows users to sign in with Google or other providers
 *  - It is secure because it never sends passwords to the server and allows the server to restrict info to the owner
 *  - Server never sees password, username, or any other sensitive info
 *  - If the server cannot see it, neither can hackers
 */

// Step 1: Redirect user to Auth0 login page
router.get("/oauth/auth", async (ctx) => {
    /** State string is stored in cookies, to be used to verify Google's server is sending responses, not just anyone
     * If the state we get back from Google is not the same as the one we sent, we terminate the connection as to not allow anyone to access the user's info
     * (CSRF attack) */
    const state = generateState(); // SHA-256 encypted random 32 byte string
    const userSession = ctx.state.session; // Session Cookies
    await userSession.set("state", state); // Store state in session

    /** Generates the URL that the user will be redirected to for Google Sign-in
     * This could be exploited in a CSRF attack if the state is not verified
     * or if a bad actor could make API calls on behalf of the user */
    const authorizationUrl = oauth2Client.generateAuthUrl({
        access_type: "offline", // Requests a refresh token, allows TAC access to user info without user holding the program's hand
        scope: scopes, // API's that we want to access
        include_granted_scopes: true, // Makes this token include past-scopes as well as those in 'scopes'
        state: state, // Protects against CSRF attacks
    });

    // Redirect the user's browser to the authorization URL
    // (This completes the /auth route while /callback and /secure will hand the program back to the Frontend)
    ctx.response.status = 302;
    ctx.response.redirect(authorizationUrl);
});

// Step 2: Handle Auth0 callback and exchange code for tokens
router.get("/oauth/callback", async (ctx) => {
    const url = ctx.request.url;
    const checkState = url.searchParams.get("state");
    const code = url.searchParams.get("code");

    if (!code) {
        ctx.response.status = 400;
        ctx.response.body = { message: "Authorization code not found." };
        return;
    }
    // if (!checkState) {
    //   console.error("STATE NOT FOUND!!! CRITICAL ERROR!!!");
    //   ctx.response.status = 400;
    //   ctx.response.body = { message: "State not found, CSRF attack suspected." };
    //   return;
    // } else {
    //   if (checkState !== ctx.state.session.get("state")) {
    //     console.error("STATE MISMATCH!!! CRITICAL ERROR!!!");
    //     ctx.response.status = 400;
    //     ctx.response.body = { message: "State mismatch, CSRF attack suspected." };
    //   }
    // }

    try {
        const tokens = await oauth2Client.getToken(code);
        oauth2Client.setCredentials(tokens.tokens);


        // Check if tokens, scope, and
        if (!tokens) {
            console.error(
                "CRITIAL ERROR! Tokens not found, user has likely denied access",
            );
            ctx.response.status = 400;
            ctx.response.body = {
                message: "Tokens not found, user may have denied access",
            };
            return;
        }

        // Check if we have scopes and if they match the requested scopes
        if (tokens.tokens.scope !== scopes || !tokens.tokens.scope) {
            console.warn("Different scope than requested, user may have denied access. Backend runnning sweep");
            // TODO: Run sweep for permissions ( Basically just attempt each API and return what doesn't work in the DB along with user data)
        } else {
            console.log("Scope matches requested scope");
        }

        // Check if token is Bearer
        if (tokens.tokens.token_type !== "Bearer") {
            console.error("Token type is not Bearer, may be insecure");
            ctx.response.status = 400;
            ctx.response.body = {
                message: "Token type is not Bearer, unexpected outcome",
            };
            // await ctx.state.session.deleteSession()
            return;
        }

        // TODO: Store token in DB with user info, create new user if not found
        ctx.response.body = { message: "Authentication successful" };
        await ctx.state.session.set("tokens", tokens.tokens)
        await ctx.response.redirect(`http://localhost:${env.PORT}/oauth/secure`); // Redirect to test route, ideal
    } catch (error) {
        console.error("Error exchanging code for token:", error);
        ctx.response.status = 400;
        ctx.response.body = {
            message: "Failed to retrieve access token, check logs",
        };
    }
});

// Step 3: Test secured route
// Basically just runs fetch on something that would require a token
// FUTURE ME: Authorization token is really just accessToken
router.get("/oauth/secure", async (ctx) => {
    const tokenResponse = await oauth2Client.getAccessToken(); // Retrieve access token from OAuth2 client
    const token = tokenResponse?.token;

    //If no token is found, return 401 (access denied)
    if (!token) {
        ctx.response.status = 401;
        ctx.response.body = { message: "Access token is required." };
        return;
    }

    if(validateLogin()) {
        ctx.response.redirect(`http://localhost:${env.ORIGINPORT}/home`);
    } else {
        console.error("Error fetching user info:", err);
        ctx.response.status = 500;
        ctx.response.body = { message: "Failed to fetch user info." };
    }
});
/* Function to validate login
 * made purely for modulerization */
async function validateLogin() {
    try {
        const userInfoResponse = await oauth2Client.request({
            url: "https://www.googleapis.com/oauth2/v3/userinfo",
            headers: { Authorization: `Bearer ${oauth2Client.getAccessToken()}` },
        });
        const userInfo = await userInfoResponse;
        if (userInfo.status !== 200) {
            console.error("API access not functional, token may be invalid");
            ctx.response.status = userInfo.status;
            ctx.response.body = { message: userInfo.statusText };
            return false
        }
        console.log("User logged in as: ", userInfo.data.given_name)
        return true
    } catch (err) {
        console.error("User is not logged in", err);
        return false
    }
}


// Step 4: Logout route
// Basically just kills the tokens
// not implemented yet
router.get("/logout", (ctx) => {
    const logoutUrl =
        `https://${AUTH0_DOMAIN}/v2/logout?client_id=${AUTH0_CLIENT_ID}&returnTo=http://localhost:${env.ORIGINPORT}/login`;
    // ctx.state.session.deleteSession()
    ctx.response.redirect(logoutUrl);
});

/** -----------------------------------------------------------------------------------------------
 * Everything Past this is utilities for the frontend and server
 *
 * DOES NOT WORK!!!
 * Do not use this route
 */
router.post("/sendEmail", async (ctx) => {
    if (ctx.state.session.get("emailSends") > 2) {
        ctx.response.body = { message: "You have sent too many emails, please try again tomorrow" };
        ctx.response.status = 429;
        return;
    }
    try {
        const jsonData = await ctx.request.body.json();
        const { name, school, email, message } = jsonData;
        if (typeof jsonData != "object" || jsonData !== null) {
            if (jsonData == null) {
                ctx.response.body = {
                    message: "Invalid request body, should not be empty",
                };
                ctx.response.status = 400;
                throw new Error("Invalid request body, should not be empty");
            } else {
                ctx.response.body = {
                    message: "Invalid request body, should be a JSON object",
                };
                ctx.response.status = 400;
                throw new Error("Invalid request body, should be a JSON object");
            }
        }

        const transporter = nodemailer.createTransport({
            service: "gmail",
            auth: {
                // Sender Email and Password stored in the .env file
                user: env.EMAIL,
                pass: env.PASSWORD,
            },
        });

        const mailOptions = {
            from: email,
            to: ["diamondjdev@gmail.com", "berrybr@bentonvillek12.org"],
            subject: `Contact Form Submission from ${name} at ${school}`,
            text: `This is an automated message from TAC++, 
      the following is a support message from Name: ${name}\n School: ${school}\n Email: ${email}\n
      . The message is as follows: \n Message: \"${message}\"`,
        };

        try {
            await transporter.sendMail(mailOptions);
            console.log("Email sent successfully");
            ctx.response.body = { message: "Email sent successfully" };
            ctx.response.status = 200;
        } catch (error) {
            console.error("Error sending email:", error);
            ctx.response.status = 500;
            ctx.response.body = { message: "Error sending email" };
        }
    } catch (error) {
        console.error("Error parsing request body:", error);
        ctx.response.status = 400;
        ctx.response.body = { message: "Invalid request body" };
    }
    ctx.state.session.set("emailSends", ctx.state.session.get("emailSends") > 0 ? ctx.state.session.get("emailSends") + 1 : 1);
});

// Route to export a SQL table to an Excel file
router.get("/exportData/:tableName", (ctx) => {
    const tableName = ctx.params.tableName;
    try {
        const data = db.query(`SELECT * FROM ${tableName}`);
        const worksheet = utils.json_to_sheet(data);
        const workbook = utils.book_new();
        utils.book_append_sheet(workbook, worksheet, tableName);
        const excelData = writeXLSX(workbook, { type: "buffer" });
        ctx.response.headers.set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        ctx.response.headers.set("Content-Disposition", `attachment; filename=${tableName}.xlsx`);
        ctx.response.body = excelData;
    } catch (error) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Error exporting table to Excel", error: error.message };
    }
});

// Route to import data from a JSON file
router.post("/importData/:tableName", async (ctx) => {
    const tableName = ctx.params.tableName;
    try {
        const jsonData = await ctx.request.body().value;
        if (typeof jsonData !== "object" || jsonData === null) {
            ctx.response.status = 400;
            ctx.response.body = { message: "Invalid JSON data" };
            return;
        }
        const columns = Object.keys(jsonData[0]).join(", ");
        const values = jsonData.map(row => `(${Object.values(row).map(value => `'${value}'`).join(", ")})`).join(", ");
        db.query(`INSERT INTO ${tableName} (${columns}) VALUES ${values}`);
        ctx.response.body = { message: "Data imported successfully" };
    } catch (error) {
        ctx.response.status = 500;
        ctx.response.body = { message: "Error importing data", error: error.message };
    }
});



// Initialize session middleware with cookie caching
app.use(Session.initMiddleware(store, {
    cookieSetOptions: {
        httpOnly: true,
        sameSite: "none",
        secure: false
    },
    cookieGetOptions: {}
}));
/** -----------------------------------------------------------------------------------------------
 * HTTPS Server Setup
 * Reads key and cert from cert.crt and key.key respectfully
 */

// const handler = (req: Request) => {
//   return new Response("Secure Connection Established", { status: 200 });
// };

// const listener = Deno.listenTls({
//   hostname: "0.0.0.0",
//   port: env.PORT,
//   transport: "tcp",
//   cert: Deno.readTextFileSync("./httpsInfo/cert.pem"),
//   key: Deno.readTextFileSync("./httpsInfo/key.pem"),
//   alpnProtocols: ["h2", "http/1.1"],
// });

// Start server
// serveTls(handler, {
//   transport: "tcp",
//   certFile: "./httpsInfo/cert.pem",
//   keyFile: "./httpsInfo/key.pem",
//   port: env.PORT,
// })

// async function handleHttp(conn: Deno.Conn) {
//   for (const event of Deno.serveHTTP(conn)) {
//     event.respondWith(new Response("Secure Connection Established", { status: 200 }));
//   }
// }


// Run another process to listen for requests and print out the requested URL
app.use(async (ctx, next) => {
    console.log(`Received request: ${ctx.request.method} ${ctx.request.url}`);
    await next();
});

// Allow CORS
const origin = env.ORIGINPORT;
console.log(`CORS enabled for http://localhost:${origin}`);
app.use(
    oakCors({
        origin: `http://localhost:${origin}`,
        allowHeaders: ["Access-Control-Allow-Headers"],
    }),
);

// Set up routes
app.use(router.allowedMethods());
app.use(router.routes());

// Start server on custom port and log the port
const port = env.PORT;
console.log(`Server running on http://localhost:${port}`);
await app.listen({ port });%                                                    gintherc@BWHS2525LT03 Deno % nano sqlServer.ts

UW PICO 5.09                       File: sqlServer.ts

// Hey, ignore @ts-nocheck, it's just me stopping the compiler from being stupid
// @ts-nocheck compiler errors

// Basic Server Functionality
import { serveTls } from "https://deno.land/std/http/server.ts";
import { dbInit, dbReset } from "./DatabaseThings.ts"; // DB initialization and$
import { oakCors } from "https://deno.land/x/cors/mod.ts"; // Cross Origin Reso$
import {Application, _Context, Router,} from "https://deno.land/x/oak@v12.5.0/m$
import { createHash, randomBytes } from "node:crypto"; // Secure random state v$
import { Session, CookieStore } from "https://deno.land/x/oak_sessions/mod.ts";$

// OAuth2
import { getAllGrades, getAllClasses, initGoogle } from "./googleAPI.ts";
import { classroom_v1 } from "googleapis";
import { google } from "googleapis"; // Google API and Sign-in Client
import { config } from "https://deno.land/x/dotenv/mod.ts"; // Environment vari$

// Misc
import nodemailer from "npm:nodemailer"; // Email sending (Doesn't work, don't $

^G Get Help  ^O WriteOut  ^R Read File ^Y Prev Pg   ^K Cut Text  ^C Cur Pos
^X Exit      ^J Justify   ^W Where is  ^V Next Pg   ^U UnCut Text^T To Spell
