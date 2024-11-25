# nCookieJar & Scorer Contracts

This repository contains the smart contracts for the **nCookieJar** and **Scorer**. These contracts provide functionality for managing token deposits and claims, integrating scoring mechanisms for eligibility, and supporting round-based deposit/claim systems.

## Contracts Overview

### nCookieJar Contract
The `nCookieJar` contract allows users to deposit ERC20 tokens or Ether into the contract, with a mechanism to claim funds based on eligibility scores determined by the `Scorer` contract. It also supports round-based logic to manage claims within specific time windows.

### Scorer Contract
The `Scorer` contract manages the scoring system that determines eligibility for claiming funds from the `nCookieJar`. It allows admins to set and manage user scores, and defines score types for various purposes (e.g., Trust score).

## Directory Structure
- `/contracts`: Contains all Solidity contracts.
  - `/cookie-jar.md`: Readme for the `nCookieJar` contract.
  - `/scorer.md`: Readme for the `Scorer` contract.
  