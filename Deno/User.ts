/** ATTENTION: This file assumes that backend has already checked if the user is new
 * IF THE USER IS NOT NEW, DO NOT USE THE NEW USER CONSTRUCTOR
 *
 * User class meant to store temporary data for matches
 * Long term data will be re-directed to sql database upon changes
 *
 * Many properties are not assigned values upon instantiation
 * but will but filled with data once matches begin
 *
 * @class User
 * @property {string} userID - Unique identifier for the user
 * @property {string} name - Name of the user
 * @property {string} location - Location of the user
 *
 */
export class User {
    userID: string; // Unique identifier for the user
    name: string; // Name of the user
    location: string; // Location of the user

    sessionMatches: [number]
    heartRate: number; // Heart rate in beats per minute
    responseToStimulate: number; // in percent / 100
    poseAccuracy: number; // in percent / 100
    timeSignedIn: Date; // Date and time the user last signed in
    matchesPlayed: number; // Number of matches played by the user in this session

    constructor(name: string, location: string) {
        // Stored in a SQL database
        this.userID = Math.random().toString(36).substring(2, 10);
        this.name = name;
        this.location = location;
        this.matchesPlayed = 0;

        // Temporary data per session
        this.sessionMatches = [0];
        this.heartRate = 0;
        this.responseToStimulate = 0;
        this.poseAccuracy = 0;
        this.timeSignedIn = new Date();
    }

    /**
     * Calculate the score based on heart rate, response to stimulus, and pose accuracy
     * Score is standardized to a scale of 0-100
     * Formula: (heartRate * responseToStimulate * poseAccuracy) / 100
     *
     * @returns {number} - The calculated score
     */
    public calculateScore(): number {
        // Calculate the score based on heart rate, response to stimulus, and pose accuracy
        return (this.heartRate * this.responseToStimulate * this.poseAccuracy) / 100;
    }
}