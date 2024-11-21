# Hand Protocol Contract

## Cookie Jar & Scorer

1. Role-based Access: Admins can set scores, while the contract owner controls admin roles and the jar’s parameters.
2. Score-based Eligibility: Only users with a score above a minimum threshold can claim funds from the jar.
3. Deposits and Withdrawals: Both ETH and ERC20 tokens can be deposited into the jar, and funds can be claimed by eligible users.
4. Claim Limits: Each user can only claim up to a daily limit and only once per day.
5. Flexible Fund Management: The owner can manage both the daily limit and minimum score for claims, as well as withdraw funds from the jar if needed.
6. Tracking and Events: Events are emitted for deposits, claims, and updates to daily limits and score requirements, making it easy to track all actions.

## WIP & Deployed Contracts 

Scorer Contract : [https://sepolia.arbiscan.io/address/0x5aea83d3c2837832fcb12703bc677549bdbeb9a7](https://testnet.routescan.io/address/0x5aea83D3C2837832fCb12703Bc677549bdBeb9A7/contract/421614/writeContract?chainid=421614)
Cookie Jar Contract : [https://sepolia.arbiscan.io/address/0xbc6043be52c675b3d465d60a1f7b7b951a3ff343](https://testnet.routescan.io/address/0xBC6043bE52c675b3d465D60a1f7b7b951A3fF343/contract/421614/readContract?chainid=421614)
