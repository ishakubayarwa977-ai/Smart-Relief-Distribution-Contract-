# 🎆 Smart Relief Distribution Contract

A comprehensive blockchain-based humanitarian aid distribution system built on the Stacks blockchain, enabling transparent, efficient, and accountable distribution of relief funds to verified beneficiaries through decentralized campaigns and donor management.

## 🚀 Features

- **Beneficiary Registration** 📝: Secure registration system with verification workflow for aid recipients
- **Relief Campaigns** 🎯: Create and manage targeted relief campaigns with specific goals and categories
- **Transparent Donations** 💰: Public donation tracking with donor profiles and reputation systems
- **Verified Distribution** ✅: Controlled aid distribution to verified beneficiaries with priority scoring
- **Multi-Category Support** 🏷️: Emergency, food, medical, housing, and education aid categories
- **Verifier Network** 👥: Approved verifier system for beneficiary validation
- **Donor Analytics** 📈: Comprehensive donor profiles with reputation and contribution tracking
- **Emergency Controls** 🆘: Admin controls for emergency situations and fund recovery

## 📁 Project Structure

```
Smart-Relief-Distribution-Contract-/
├── contracts/
│   └── smart-relief-distribution.clar    # Main smart contract
├── tests/
│   └── smart-relief-distribution.test.ts # TypeScript tests
├── Clarinet.toml                         # Project configuration
└── README.md                             # This file
```

## 🛠️ Installation & Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) (for testing)

### Quick Start
```bash
# Clone the repository
git clone <your-repo-url>
cd Smart-Relief-Distribution-Contract-

# Check contract syntax
clarinet check

# Run tests
npm install
npm test

# Start local development network
clarinet integrate
```

## 📖 Contract Functions

### Public Functions

#### Beneficiary Management
- `register-beneficiary` - Register as a beneficiary with name, location, and aid category
- `verify-beneficiary` - Approve or reject beneficiary applications (verifiers only)
- `suspend-beneficiary` - Suspend beneficiary access (admin only)

#### Campaign Operations
- `create-relief-campaign` - Create targeted relief campaigns with funding goals
- `donate-to-campaign` - Contribute STX to specific relief campaigns
- `register-for-campaign` - Register verified beneficiaries for campaign participation
- `close-campaign` - Close campaigns (campaign creator only)

#### Distribution Management
- `distribute-aid` - Distribute funds to registered beneficiaries (campaign creator only)
- `emergency-withdraw` - Emergency fund withdrawal (admin only)

#### Administrative Functions
- `approve-verifier` - Approve new verifiers (admin only)

### Read-Only Functions
- `get-beneficiary` - Retrieve beneficiary information and status
- `get-campaign` - View campaign details and statistics
- `get-donation` - Check donation records for specific donors and campaigns
- `get-distribution` - View distribution records and amounts
- `get-campaign-beneficiary` - Check beneficiary registration for campaigns
- `get-donor-profile` - Access donor statistics and reputation
- `is-verifier-approved` - Verify if a principal is an approved verifier
- `get-campaign-stats` - Get comprehensive campaign analytics
- `get-contract-stats` - Platform-wide statistics and metrics

## 🎯 Usage Examples

### Registering as a Beneficiary
```clarity
(contract-call? .smart-relief-distribution register-beneficiary
  "Maria Rodriguez"     ;; Name
  "Valencia, Venezuela" ;; Location
  u1                     ;; Food aid category
)
```

### Verifying a Beneficiary (Verifier Only)
```clarity
(contract-call? .smart-relief-distribution verify-beneficiary
  'SP-BENEFICIARY-PRINCIPAL-ADDRESS  ;; Beneficiary to verify
  true                               ;; Approval status
)
```

### Creating a Relief Campaign
```clarity
(contract-call? .smart-relief-distribution create-relief-campaign
  "Hurricane Relief Fund"                    ;; Campaign title
  "Emergency relief for hurricane victims in coastal areas with immediate food and shelter assistance"  ;; Description
  u0                                          ;; Emergency category
  u100000000                                  ;; Target: 100 STX
  u525600                                     ;; End date: ~365 days from now
  u1000000                                    ;; 1 STX per beneficiary
)
```

### Donating to a Campaign
```clarity
(contract-call? .smart-relief-distribution donate-to-campaign
  u1        ;; Campaign ID
  u5000000  ;; 5 STX donation
)
```

### Registering for a Campaign (Verified Beneficiary)
```clarity
(contract-call? .smart-relief-distribution register-for-campaign
  u1  ;; Campaign ID
)
```

### Distributing Aid (Campaign Creator)
```clarity
(contract-call? .smart-relief-distribution distribute-aid
  u1                              ;; Campaign ID
  'SP-BENEFICIARY-PRINCIPAL-ADDR  ;; Beneficiary address
)
```

### Approving a Verifier (Admin Only)
```clarity
(contract-call? .smart-relief-distribution approve-verifier
  'SP-VERIFIER-PRINCIPAL-ADDRESS  ;; New verifier address
)
```

## 📊 Beneficiary Status Flow

```
PENDING (0) → Verification → VERIFIED (1) → Eligible for Aid
     ↓                              ↓
REJECTED (2)                   SUSPENDED (3)
```

## 🏷️ Aid Categories

```
EMERGENCY (0)  - Disaster relief and urgent assistance
FOOD (1)       - Food assistance and nutrition programs
MEDICAL (2)    - Healthcare and medical aid
HOUSING (3)    - Shelter and housing assistance
EDUCATION (4)  - Educational support and resources
```

## 🏋️ Campaign Status Types

```
ACTIVE (0)  - Campaign accepting donations and beneficiaries
PAUSED (1)  - Temporarily suspended
CLOSED (2)  - Campaign ended or completed
```

## 💼 Business Model

### Fee Structure
- **Registration**: Free for beneficiaries and donors
- **Donations**: No platform fees - 100% goes to campaigns
- **Verification**: Performed by approved volunteer verifiers
- **Distribution**: Campaign creators manage distribution to beneficiaries

### Minimum Requirements
- **Minimum Donation**: 0.1 STX to prevent spam
- **Verification Period**: 1,440 blocks (~10 days) for verification
- **Distribution Period**: 144 blocks (~1 day) for distribution processing

## 🔒 Security Features

- **Verified Recipients**: Only verified beneficiaries can receive aid
- **Approved Verifiers**: Admin-controlled verifier network ensures quality
- **Campaign Creator Controls**: Only campaign creators can distribute funds
- **Emergency Admin Powers**: Admin can suspend beneficiaries and emergency withdraw
- **Anti-Fraud Measures**: Priority scoring and registration tracking
- **Transparent Tracking**: All transactions publicly verifiable
- **Donation Protection**: STX funds secured in smart contract escrow

## 💡 Use Cases

### Disaster Relief
- **Natural Disasters**: Hurricane, earthquake, and flood relief
- **Emergency Response**: Immediate aid distribution to affected areas
- **Refugee Assistance**: Support for displaced populations
- **Crisis Intervention**: Rapid response to humanitarian crises

### Community Support
- **Food Security**: Local food assistance programs
- **Medical Aid**: Healthcare support for underserved communities
- **Education Support**: Scholarships and educational resources
- **Housing Assistance**: Temporary and permanent housing support

### International Aid
- **Cross-Border Relief**: International humanitarian assistance
- **Development Programs**: Long-term community development projects
- **NGO Operations**: Support for non-governmental organizations
- **Charitable Initiatives**: Individual and organizational philanthropy

## 🎨 Stakeholder Benefits

### For Donors
- **Full Transparency** 🔍: Complete visibility into fund usage and distribution
- **Direct Impact** 🎯: Funds go directly to verified beneficiaries
- **Reputation Building** ⭐: Build donor reputation through consistent contributions
- **Global Reach** 🌍: Support causes worldwide through blockchain technology
- **Tax Documentation** 📄: Immutable donation records for tax purposes

### For Beneficiaries
- **Fair Access** ⚖️: Merit-based priority system for aid distribution
- **Direct Funding** 💰: Receive funds directly without intermediaries
- **Privacy Protection** 🔒: Secure registration with privacy safeguards
- **Multiple Opportunities** 🎆: Access to various aid categories and campaigns
- **Verified Status** ✅: Credible verification process builds trust

### For Campaign Creators
- **Easy Setup** 🛠️: Simple campaign creation and management
- **Donor Attraction** 🧡: Transparent system attracts more donors
- **Distribution Control** 🎯: Full control over aid distribution process
- **Impact Tracking** 📈: Monitor campaign progress and effectiveness
- **Global Platform** 🌎: Reach international donor community

## 📈 Platform Analytics

The contract provides comprehensive analytics:
- **Campaign Performance**: Track funding progress and beneficiary registration
- **Donor Engagement**: Monitor donation patterns and donor retention
- **Distribution Efficiency**: Analyze aid distribution speed and coverage
- **Beneficiary Demographics**: Understand aid recipient populations
- **Geographic Impact**: Track relief efforts across different regions
- **Category Analysis**: Monitor aid distribution across different need categories

## 🧪 Testing

Run the comprehensive test suite:

```bash
npm install
npm test
```

Tests cover:
- Beneficiary registration and verification workflows
- Campaign creation and management
- Donation processing and tracking
- Aid distribution mechanisms
- Admin controls and security features
- Priority scoring algorithms
- Emergency procedures
- Error handling and validation

## 🚦 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 401 | ERR_UNAUTHORIZED | Access denied for operation |
| 402 | ERR_BENEFICIARY_NOT_FOUND | Beneficiary record doesn't exist |
| 403 | ERR_ALREADY_REGISTERED | Already registered for service |
| 404 | ERR_INSUFFICIENT_FUNDS | Insufficient funds for operation |
| 405 | ERR_INVALID_AMOUNT | Invalid amount specified |
| 406 | ERR_DISTRIBUTION_CLOSED | Distribution period has ended |
| 407 | ERR_ALREADY_RECEIVED | Beneficiary already received aid |
| 408 | ERR_INVALID_CATEGORY | Invalid aid category specified |
| 409 | ERR_CAMPAIGN_NOT_FOUND | Campaign ID doesn't exist |
| 410 | ERR_INVALID_PERIOD | Invalid time period specified |

## 🌟 Platform Benefits

- **Decentralized Trust** 🏛️: No central authority controls aid distribution
- **Global Accessibility** 🌐: Anyone can donate or request aid worldwide
- **Transparent Operations** 📊: All transactions publicly verifiable on blockchain
- **Reduced Corruption** 🛡️: Smart contracts eliminate human intermediaries
- **Efficient Distribution** 🚀: Direct transfers reduce administrative overhead
- **Permanent Records** 📜: Immutable record of all aid activities
- **Real-Time Tracking** ⏱️: Live updates on campaign progress and distributions

## 🎯 Target Organizations

- **Humanitarian NGOs**: International relief organizations
- **Local Charities**: Community-based charitable organizations
- **Government Agencies**: Public sector disaster response units
- **Religious Organizations**: Faith-based relief initiatives
- **Corporate CSR**: Corporate social responsibility programs
- **Individual Philanthropists**: Private donors and foundations
- **Emergency Response Teams**: First responder organizations

## 🌟 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Run `clarinet check` to validate
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🤝 Support

For questions or support:
- Create an issue on GitHub
- Check the [Stacks documentation](https://docs.stacks.co/)
- Visit the [Clarinet documentation](https://docs.hiro.so/stacks/clarinet-js-sdk)

## 🚀 Deployment

Ready for deployment on:
- **Stacks Testnet**: For testing and development
- **Stacks Mainnet**: For production relief distribution

---

Built with ❤️ for humanitarian aid and global relief efforts using Stacks blockchain technology.
