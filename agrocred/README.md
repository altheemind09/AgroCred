# AgroCred

**AgroCred** is a Clarity smart contract-based registry designed to authenticate, track, and showcase the professional credentials, certifications, and endorsements of agricultural professionals — including farmers, agronomists, and agricultural experts. It supports crop specialization tracking, certification verification, peer endorsements, and cooperative partnerships.

---

## 🌾 Features

- **Farmer Profiles**  
  Farmers can register professional profiles including crop specializations, farm regions, and disclosure preferences.

- **Harvest Records**  
  Log and manage harvest details including crop variety, yield notes, and farming methods with disclosure control.

- **Agricultural Certifications**  
  Add certifications with hash validation and optional expiration dates. Certifications can be verified by the contract owner.

- **Farming Endorsements**  
  Enable peer-to-peer endorsements for specific areas of expertise, tracked with count metrics.

- **Cooperative Partnerships**  
  Farmers can form and manage cooperative relationships for trust-based data access and collaboration.

- **Access Control via Disclosure Levels**  
  Fine-grained control over who can view data: public, certified partners, or confidential.

- **Admin Tools**  
  Contract owner can certify farmers, verify certifications, and update platform-wide fees.

---

## 🧩 Data Structures

- `farmer-profiles`  
- `harvest-records`  
- `agricultural-certifications`  
- `farming-endorsements`  
- `cooperative-partnerships`  
- `expertise-endorsements`

---

## 🔐 Disclosure Levels

- `DISCLOSURE-PUBLIC (0)`
- `DISCLOSURE-CERTIFIED-FARMERS (1)`
- `DISCLOSURE-CONFIDENTIAL (2)`

These control visibility of profile, harvest, and certification data.

---

## 📤 Public Functions

| Function | Description |
|---------|-------------|
| `register-farmer-profile` | Create a farmer profile |
| `log-harvest-record` | Add harvest data |
| `add-agricultural-certification` | Register a new certification |
| `send-partnership-request` | Request a partnership |
| `accept-partnership-request` | Accept a pending partnership |
| `provide-farming-endorsement` | Endorse another farmer |
| `verify-agricultural-certification` | Admin: verify a certification |
| `certify-farmer` | Admin: mark farmer as certified |
| `update-agriculture-fee` | Admin: update platform fee |

---

## 🔍 Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-farmer-profile` | Fetch a farmer’s profile |
| `get-harvest-record` | Fetch a specific harvest entry |
| `get-agricultural-certification` | Fetch a certification |
| `get-farming-endorsement` | Fetch an endorsement |
| `get-partnership-status` | Check partnership state |
| `are-farmers-partners` | Confirm if two farmers are partners |
| `can-view-confidential-content` | Check access rights |
| `get-expertise-endorsement-count` | Count of endorsements per expertise |

---

## ⚙️ Admin Operations

Only the contract owner (`contract-owner`) can:
- Verify certifications
- Certify farmers
- Adjust the `agriculture-fee`

---

## 📜 License

MIT License

---

## 👨‍🌾 Use Case

- Empower rural and smallholder farmers to digitally showcase validated expertise
- Facilitate collaboration via trust-based endorsement and certification
- Strengthen agritech platforms with authenticated, on-chain farmer data

---

## 📬 Contributions

Contributions, feedback, and ideas are welcome! Please submit issues or pull requests to improve the platform.
