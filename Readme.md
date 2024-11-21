# Hand Protocol Contract

## Cookie Jar & Scorer

Role-based Access: Admins can set scores, while the contract owner controls admin roles and the jar’s parameters.
Score-based Eligibility: Only users with a score above a minimum threshold can claim funds from the jar.
Deposits and Withdrawals: Both ETH and ERC20 tokens can be deposited into the jar, and funds can be claimed by eligible users.
Claim Limits: Each user can only claim up to a daily limit and only once per day.
Flexible Fund Management: The owner can manage both the daily limit and minimum score for claims, as well as withdraw funds from the jar if needed.
Tracking and Events: Events are emitted for deposits, claims, and updates to daily limits and score requirements, making it easy to track all actions.
