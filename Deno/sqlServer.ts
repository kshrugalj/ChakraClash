// Hey, ignore @ts-nocheck, it's just me stopping the compiler from being stupid
// @ts-nocheck compiler errors

// Basic Server Functionality
import { oakCors } from "https://deno.land/x/cors/mod.ts"; // Cross Origin Resource Sharing (Restrict who can see server data)
import {Application, _Context, Router,} from "https://deno.land/x/oak@v12.5.0/mod.ts"; // Server things OAK
import { createHash, randomBytes } from "node:crypto"; // Secure random state value generation
import { config } from "https://deno.land/x/dotenv/mod.ts";
// ChakraClash Specifics
import { User } from "./User.ts"; // User class
import {Match} from "./Match.ts"; // League class

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
// const db = await dbInit(); TODO
// Create a new session
type AppState = {
    session: Session;
};

// Create a new application
const app = new Application<AppState>();

//Create a new router (routes to webpages)
const router = new Router<AppState>();

let activeMatches = []; // Array of matches that are currently ongoing
let activeUsers = [] // Array of users that are actively logged in

/* User specific routes
 * These routes are specific to the user and are meant to be called rapidly
 * (e.g. login, logout, status, update biometrics, pose accuracy, etc.)
 *
 */
router.post("/login", async (ctx) => {
    try {
        const { username, password } = await ctx.request.body().value;

        // Validate the username and password (this is a placeholder, replace with actual validation logic)
        // if (username === "validUser" && password === "validPassword") {
        if (true) {
            // Create a new User object
            const user = new User(0, 0, 0, 0);

            // Add the user to the list of actively logged-in users
            activeUsers.push(user);

            // Set the session
            ctx.state.session.set("user", user);

            ctx.response.body = {message: "Login successful", user};
            ctx.response.status = 200;
        }
    } catch (error) {
        console.error("Error during login:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.get("/status", async (ctx) => {
    try {
        const userID = ctx.request.url.searchParams.get("userID");
        const user = activeUsers.find((u) => u.id === userID);

        if (user) {
            ctx.response.body = { message: "User is active", user };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "User is not active" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error checking user status:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.post("/logout", async (ctx) => {
    try {
        const { userID } = await ctx.request.body().value;

        // Remove the user from the list of actively logged-in users
        activeUsers = activeUsers.filter((u) => u.id !== userID);

        // Clear the session
        ctx.state.session.set("user", null);
        ctx.response.body = { message: "Logout successful" };
        ctx.response.status = 200;
    } catch (error) {
        console.error("Error during logout:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

/* ------------------------------------------------------------------------------------------------
 * Routes designed for frontend to upload user-specific data to be stored locally
 */

// Route to update user heart rate
router.post("/updateHeartRate", async (ctx) => {
    try {
        const { userID, heartRate } = await ctx.request.body().value;
        // Find the user by userID and update heart rate
        const user = activeUsers.find((u) => u.id === userID);
        if (user) {
            user.heartRate = heartRate;
            ctx.response.body = { message: "Heart rate updated successfully" };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "User not found" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error updating heart rate:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

// Route to update user pose accuracy
router.post("/updatePoseAccuracy", async (ctx) => {
    try {
        const { userID, poseAccuracy } = await ctx.request.body().value;
        // Find the user by userID and update pose accuracy
        const user = activeUsers.find((u) => u.id === userID);
        if (user) {
            user.poseAccuracy = poseAccuracy;
            ctx.response.body = { message: "Pose accuracy updated successfully" };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "User not found" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error updating pose accuracy:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

// Route to update user response to stimuli
router.post("/updateResponseToStimuli", async (ctx) => {
    try {
        const { userID, responseToStimuli } = await ctx.request.body().value;
        // Find the user by userID and update response to stimuli
        const user = activeUsers.find((u) => u.id === userID);
        if (user) {
            user.responseToStimuli = responseToStimuli;
            ctx.response.body = { message: "Response to stimuli updated successfully" };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "User not found" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error updating response to stimuli:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

/* ------------------------------------------------------------------------------------------------
 * Routes designed for the frontend to achieve core app functionality
 * These routes are meant to be called less frequently but control the flow of the app
 */

/**
 * Route to create a new match and fill it with users.
 *
 * @route POST /createMatch
 * @param {Context} ctx - The context object containing the request and response.
 * @returns {Object} - A message indicating the match creation status and the match ID.
 * @throws {Error} - If there is an error during match creation.
 */
router.post("/createMatch", async (ctx) => {
    try {
        const { userIDs } = await ctx.request.body().value;
        const users = activeUsers.filter((user) => userIDs.includes(user.id));
        const match = new Match();
        activeMatches.push(match);

        users.forEach((user: User) => {
            match.addUser(user);
        });

        ctx.response.body = { message: "Match created successfully", matchID: match.getMatchID() };
        ctx.response.status = 200;
    } catch (error) {
        console.error("Error creating match:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.post("/joinMatch", async (ctx) => {
    try {
        const { userID, matchID } = await ctx.request.body().value;
        const match = activeMatches.find((m) => m.id === matchID);
        const user = activeUsers.find((u) => u.id === userID);

        if (match && user) {
            match.addUser(user);
            ctx.response.body = { message: "User joined match successfully" };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "Match or user not found" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error joining match:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.post("/leaveMatch", async (ctx) => {
    try {
        const { userID, matchID } = await ctx.request.body().value;
        const match = activeMatches.find((m) => m.id === matchID);
        const user = activeUsers.find((u) => u.id === userID);

        if (match && user) {
            match.removeUser(user);
            ctx.response.body = { message: "User left match successfully" };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "Match or user not found" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error leaving match:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.post("/endMatch", async (ctx) => {
    try {
        const { matchID } = await ctx.request.body().value;
        const matchIndex = activeMatches.findIndex((m) => m.id === matchID);

        if (matchIndex !== -1) {
            activeMatches.splice(matchIndex, 1);
            ctx.response.body = { message: "Match ended successfully" };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "Match not found" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error ending match:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.get("/getLeaderboard", (ctx) => {
    try {
        const { matchID } = ctx.request.url.searchParams;
        const match = activeMatches.find((m) => m.getMatchID() === matchID);

        if (match) {
            ctx.response.body = { leaderboard: [...match.leaderboard.entries()] };
            ctx.response.status = 200;
        } else {
            ctx.response.body = { message: "Match not found" };
            ctx.response.status = 404;
        }
    } catch (error) {
        console.error("Error getting leaderboard:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.get("/getActiveMatches", (ctx) => {
    try {
        ctx.response.body = { activeMatches: activeMatches.map(match => match.getMatchID()) };
        ctx.response.status = 200;
    } catch (error) {
        console.error("Error getting active matches:", error);
        ctx.response.body = { message: "Internal server error" };
        ctx.response.status = 500;
    }
});

router.get("/getActiveUsers", (ctx) => {
   try {
         ctx.response.body = { activeUsers: activeUsers.map(user => user.id) };
         ctx.response.status = 200;
   } catch (error) {
         console.error("Error getting active users:", error);
         ctx.response.body = { message: "Internal server error" };
         ctx.response.status = 500;
   }
});


/* -----------------------------------------------------------------------------------------------
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



/* -----------------------------------------------------------------------------------------------
 * Everything Past this is utilities for the frontend and server
 *
 * DO NOT TOUCH!!!
 * This code is meticulously crafted to work with the frontend securely
 */
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
await app.listen({ port });