import {User} from "./User.ts";

/** Represents a single match in the game
 * Tracks leaderboard, users and their scores, matchID + pre-written messages
 * Calculates scores based on heart rate, response to stimulus, and pose accuracy
 * Uses a Map to store the leaderboard for efficient sorting and retrieval
 *
 * @class Match
 * @property {string} MatchID - Unique identifier for the match
 * @property {Map<string, number>} leaderboard - Map of user's names to their scores
 * @property {User[]} users - Array of users in the match
 */
export class Match {

    // MatchID is used to identify the match and allow others to join a specific game (UNIQUE CODE)
    private MatchID: string;
    private leaderboard: Map<string, number>; // Map of user's names to their scores
    private users: User[];

    constructor() {
        this.MatchID = Math.random().toString(36).substring(2, 10);
        this.users = [];
        this.leaderboard = new Map<string, number>();
    }

    addUser(user: User): void {
        // Assign users to basic array first, add to leaderboard assigned to scores later
        this.users.push(user);
    }

    /** Compare users based on their scores and heart rates
     * Chooses between mentioning HR and Score in the message based on percent difference
     *
     * @returns: A message berating the user who is performing worse
     * @example:
     * const league = new League();
     * const user1 = { score: 90, heartRate: 75 };
     * const user2 = { score: 100, heartRate: 70 };
     * league.addUser(user1);
     * league.addUser(user2);
     * console.log(league.compareScores(user1, user2)); // Output: "Wow user1.name, user2.name is doing SO much better"
     * @param user1
     */
    compareScores(user1: User): string {
        //messages for when user2 is higher than user1
        //TODO: Rewrite messages to include blanks for mentioning HR and Score differences
        const higherMessages = [
            `Wow {loser}, {winner} is doing SO much better`,
            `I can't believe you {loser}, you need to catch up with {winner}`,
            `{winner} is outperforming {loser} by a mile!`,
            `Look at {winner} go! {loser}, you need to step it up!`,
            `{winner} is crushing it! {loser}, you need to work harder!`
        ];
        const lowerMessages = [
            `Wow {loser}, {winner} is doing SO much worse`,
            `I can't believe you {loser}, you need to catch up with {winner}`,
            `{winner} is outperforming {loser} by a mile!`,
            `Look at {winner} go! {loser}, you need to step it up!`,
            `{winner} is crushing it! {loser}, you need to work harder!`
        ];
        // Only let user2 be within 2 indexes of user1
        for (let i = Math.max(0, this.users.indexOf(user1) - 2); i <= Math.min(this.users.length - 1, this.users.indexOf(user1) + 2); i++) {
            // Set user2 to the user at index i
            const user2 = this.users[i];

            // Setup referenced variables
            const user1Score = user1.calculateScore();
            const user2Score = user2.calculateScore();
            const user1HeartRate = user1.heartRate;
            const user2HeartRate = user2.heartRate;

            //checks if user1 is worse than user2
            const isWorse = user1Score < user2Score || user1HeartRate > user2HeartRate;

            // If user2 is better in at least one category, we can give user1 a berating message
            if (isWorse) {
                // Choose from HigherMessages or LowerMessages based on position difference
                const randomMessage = isWorse ? higherMessages[Math.floor(Math.random() * higherMessages.length)] : lowerMessages[Math.floor(Math.random() * lowerMessages.length)];

                // Replace placeholders with user's names
                const winner = user1Score > user2Score ? user1 : user2;
                const loser = user1Score > user2Score ? user2 : user1;

                return randomMessage.replace('{loser}', loser.name || 'User2').replace('{winner}', winner.name || 'User1');
            }
        }
        // If no users are worse, return a basic message
        //TODO: Rewrite messages to include blanks for mentioning HR and Score differences
        const basicMessages = [
            "Nice try, but someone else is just better.",
            "Maybe consider a different hobby? Someone else is way ahead.",
            "It's okay, not everyone can be as good as others.",
            "Did you even try? Someone else is miles ahead.",
            "Don't feel bad, someone else is just naturally talented.",
            "Wow, you are doing SO much worse.",
            "I can't believe you, you need to catch up.",
            "Someone else is outperforming you by a mile!",
            "Look at someone else go! You need to step it up!",
            "Someone else is crushing it! You need to work harder!"
        ];
        return basicMessages[Math.floor(Math.random() * basicMessages.length)];
    }

    // Share the matchID
    public getMatchID(): string {
        return this.MatchID;
    }

    // Refresh the leaderboard every three seconds using an efficient sorting algorithm
    public refreshLeaderboard(): void {
        setInterval(() => {
            this.leaderboard = new Map(
                [...this.leaderboard.entries()].sort((a, b) => b[1] - a[1])
            );
            console.log("Leaderboard refreshed:", this.leaderboard);
        }, 3000);
    }
}