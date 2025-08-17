# Pepu Domains (pepudomains)

A decentralized naming service for the Pepe Unchained blockchain that maps human-readable domain names to wallet addresses.

## 🚀 Contract Details

- **Contract Address**: `0x7Dd0f22672C9AC0B2a88C0a3C8fac1A517C7f324`
- **Network**: Pepe Unchained Mainnet (Chain ID: 97741)
- **Status**: ✅ **VERIFIED & LIVE**
- **Explorer**: [View on Block Explorer](https://explorer-pepu-v2-mainnet-0.t.conduit.xyz/address/0x7Dd0f22672C9AC0B2a88C0a3C8fac1A517C7f324)

## 📋 Core Features

- **Domain Registration**: Register `.pepu` domains with USDC payments
- **Name Resolution**: Map domains to wallet addresses
- **Character-based Pricing**: Shorter domains cost more
- **Admin Controls**: Manage TLDs and fees
- **One Domain Per Wallet**: Each wallet can own one domain

## 💰 Pricing (USDC per year)

| Length | Price |
|--------|-------|
| 1 char | 50 USDC |
| 3 chars| 35 USDC |
| 4 chars| 20 USDC |
| 5+ chars| 10 USDC |

## 🛠️ Key Functions

### Domain Management
```solidity
// Register a new domain
function registerDomain(string calldata name, string calldata tld, uint256 duration) external

// Renew domain registration
function renewDomain(string calldata name, string calldata tld, uint256 duration) external

// Update domain's wallet address
function setDomainWallet(string calldata name, string calldata tld, address newWallet) external
```

### Domain Lookup
```solidity
// Resolve domain to wallet
function resolveName(string calldata name, string calldata tld) external view returns (address)

// Check domain availability
function isDomainAvailable(string calldata name, string calldata tld) external view returns (bool)

// Get domain info
function getDomainInfo(string calldata name, string calldata tld) external view
    returns (address walletAddress, address owner, uint256 registrationTimestamp, uint256 expiryTimestamp)
```

### Admin Functions
```solidity
// Manage TLDs
function addTld(string calldata tld) external onlyOwner
function removeTld(string calldata tld) external onlyOwner

// Update contract addresses
function setUsdcAddress(address usdc) external onlyOwner
function setTreasuryAddress(address treasury) external onlyOwner

// Set registration fees
function setRegistrationFee(uint256 chars, uint256 fee) external onlyOwner
```

## 📝 Usage Examples

### Check Domain Availability
```javascript
const isAvailable = await contract.isDomainAvailable("tosh", ".pepu");
console.log(isAvailable ? "Available" : "Taken");
```

### Register a Domain
```javascript
const tx = await contract.registerDomain("tosh", ".pepu", 5); // 5 years
await tx.wait();
console.log("Domain registered!");
```

### Resolve a Domain
```javascript
const walletAddress = await contract.resolveName("tosh", ".pepu");
console.log("Wallet:", walletAddress);
```

## 🔒 Security Features

- Reentrancy protection
- Input validation
- Access control (onlyOwner)
- SafeERC20 for USDC transfers
- Overflow protection (Solidity 0.8.20+)

## 📡 Events

Key contract events for tracking:
```solidity
event DomainRegistered(string indexed name, string indexed tld, address indexed owner, address walletAddress);
event DomainRenewed(string indexed name, string indexed tld, uint256 expiryTimestamp);
event WalletUpdated(string indexed name, string indexed tld, address newWallet);
```

## 🛠️ Development

### Prerequisites
- Node.js 16+
- Hardhat
- ethers.js

### Setup
```bash
npm install
npx hardhat compile
```

### Testing
```bash
npx hardhat test
```

## 📜 License
MIT
The Pepu Domains contract is designed to work seamlessly with modern frontend frameworks. This comprehensive guide covers everything you need to build production-ready web applications that interact with the Pepu Domains service.

### **Frontend Architecture Overview**

When building a frontend for Pepu Domains, you'll need to consider several key architectural components that work together to create a seamless user experience:

**1. Wallet Connection Layer**
The frontend must establish secure connections to user wallets. This involves implementing wallet connectors for popular providers like MetaMask, WalletConnect, Coinbase Wallet, or other Web3 wallets. The wallet connection is essential for domain registration, renewal, and management operations that require user signatures. This layer should handle wallet switching, account changes, and network validation.

**2. Contract Interaction Layer**
This layer handles all direct communication with the smart contract. It includes functions for reading domain data (resolution, availability checks) and writing operations (registration, renewal, wallet updates). The contract interaction layer should implement proper error handling, transaction status monitoring, and gas estimation. This layer should also handle contract events and provide real-time updates.

**3. State Management**
Frontend applications need robust state management to handle domain data, user wallet states, transaction statuses, and UI states. This ensures a smooth user experience with real-time updates and proper loading states. Consider using state management libraries like Redux, Zustand, or React Context API depending on your application complexity.

**4. User Interface Components**
The UI should provide intuitive interfaces for domain search, registration forms, domain management dashboards, and transaction monitoring. Each component should handle different states like loading, success, error, and pending transactions. The interface should be responsive and accessible across all devices.

### **Key Frontend Features to Implement**

**Domain Search and Resolution**
Implement a search interface that allows users to check domain availability and resolve existing domains to wallet addresses. This should include real-time validation, instant feedback on domain status, and suggestions for similar available domains. The search should be fast and provide immediate results as users type.

**Domain Registration Flow**
Create a comprehensive registration process that guides users through domain selection, duration choice, fee calculation, and payment confirmation. The flow should include proper validation, error handling, transaction monitoring, and success confirmation. Consider implementing a multi-step wizard for complex registration processes.

**Domain Management Dashboard**
Build a user dashboard where domain owners can view their registered domains, check expiration dates, renew domains, and update wallet addresses. This should include bulk operations for users with multiple domains, filtering and sorting capabilities, and export functionality for domain lists.

**Transaction Monitoring**
Implement real-time transaction tracking that shows users the status of their domain operations. This includes pending transactions, confirmation status, success/error notifications, and transaction history. Provide clear feedback about gas costs and confirmation times.

**Admin Interface**
If building for administrators, create interfaces for managing fees, adding/removing TLDs, and performing administrative operations. This requires proper access control, security measures, and audit trails for all administrative actions.

### **User Experience Considerations**

**Responsive Design**
Ensure the frontend works seamlessly across all devices - desktop, tablet, and mobile. Domain management should be accessible and user-friendly on any screen size. Implement touch-friendly interfaces for mobile users and ensure proper navigation on smaller screens.

**Loading States and Feedback**
Implement proper loading indicators, progress bars, and status messages to keep users informed about ongoing operations. This is especially important for blockchain transactions that may take time to confirm. Use skeleton screens and optimistic updates for better perceived performance.

**Error Handling**
Provide clear, user-friendly error messages for common issues like insufficient funds, network errors, or invalid domain names. Include helpful suggestions for resolving these issues and provide alternative solutions when possible. Implement retry mechanisms for failed transactions.

**Accessibility**
Follow web accessibility guidelines to ensure the application is usable by people with disabilities. This includes proper contrast ratios, keyboard navigation, screen reader compatibility, and semantic HTML structure. Test with accessibility tools and real users.

**Performance Optimization**
Optimize the frontend for fast loading times and smooth interactions. This includes efficient data fetching, caching strategies, code splitting, and minimizing unnecessary re-renders. Implement lazy loading for components and data to improve initial load times.

### **Security Best Practices**

**Private Key Protection**
Never expose private keys in frontend code. Always use secure wallet connections and never prompt users to enter private keys directly in the application. Implement proper session management and secure storage for user preferences.

**Input Validation**
Implement comprehensive client-side validation for all user inputs, including domain names, wallet addresses, and transaction parameters. This prevents invalid data from reaching the smart contract and provides immediate feedback to users.

**Transaction Confirmation**
Always require explicit user confirmation for all transactions, especially those involving payments. Provide clear information about what the transaction will do, its associated costs, and potential risks. Implement confirmation dialogs with transaction summaries.

**Network Security**
Use secure RPC endpoints and implement proper error handling for network issues. Consider implementing fallback RPC providers for better reliability and always validate network connections before performing critical operations.

### **Integration Patterns**

**Wallet Integration**
Implement support for multiple wallet providers to give users flexibility in how they connect to the application. This includes MetaMask, WalletConnect, Coinbase Wallet, and other popular Web3 wallets. Handle wallet switching and account changes gracefully.

**Blockchain Event Listening**
Set up listeners for blockchain events to provide real-time updates when domains are registered, renewed, or transferred. This enhances the user experience with immediate feedback and keeps the UI synchronized with blockchain state.

**Data Caching**
Implement intelligent caching strategies for frequently accessed data like domain availability and user domain lists. This reduces RPC calls and improves performance. Use local storage for user preferences and session data.

**Offline Support**
Consider implementing offline capabilities for viewing domain information and preparing transactions, with synchronization when the connection is restored. This improves user experience in areas with poor connectivity.

### **Testing Strategy**

**Unit Testing**
Test individual components and functions to ensure they work correctly in isolation. This includes testing domain validation, fee calculations, UI components, and utility functions. Use testing libraries appropriate for your framework.

**Integration Testing**
Test the complete user flows from wallet connection through domain registration and management. This ensures all components work together properly and identifies issues with component interactions.

**User Acceptance Testing**
Conduct testing with real users to identify usability issues and gather feedback on the user experience. This helps refine the interface and improve user satisfaction. Include users with different technical backgrounds and device types.

**Security Testing**
Perform security audits to identify potential vulnerabilities in the frontend code, especially around wallet connections and transaction handling. Test for common web vulnerabilities and blockchain-specific security issues.

### **Deployment Considerations**

**Environment Configuration**
Set up different configurations for development, staging, and production environments. This includes RPC endpoints, contract addresses, feature flags, and API keys. Use environment variables and configuration files for easy management.

**Performance Monitoring**
Implement monitoring and analytics to track application performance, user behavior, and error rates. This helps identify issues and optimize the user experience. Use tools like Google Analytics, Sentry, or custom monitoring solutions.

**Continuous Integration**
Set up automated testing and deployment pipelines to ensure code quality and reliable releases. Implement code quality checks, automated testing, and deployment automation for consistent releases.

**User Support**
Implement support features like help documentation, FAQ sections, and contact forms to assist users with questions or issues. Provide clear error messages and troubleshooting guides for common problems.

### **Frontend Framework Recommendations**

**React/Next.js**
React and Next.js provide excellent support for building Web3 applications with their component-based architecture and server-side rendering capabilities. Next.js is particularly well-suited for domain resolution pages and SEO optimization. The large ecosystem and community support make it an excellent choice for production applications.

**Vue.js/Nuxt.js**
Vue.js offers a progressive framework that's easy to learn and implement. Nuxt.js provides additional features like automatic routing and server-side rendering that are beneficial for domain management applications. Vue's reactivity system works well with blockchain data updates.

**Angular**
Angular provides a comprehensive framework with built-in dependency injection and powerful tooling. It's well-suited for large-scale applications with complex state management requirements. Angular's TypeScript-first approach provides excellent type safety for blockchain interactions.

**Vanilla JavaScript/TypeScript**
For lightweight applications or when you need maximum control, vanilla JavaScript with TypeScript provides a solid foundation. This approach is particularly useful for simple domain resolution tools or embedded widgets that need to be integrated into existing applications.

### **Essential Frontend Libraries**

**Web3 Integration**
Ethers.js is the primary library for interacting with the Ethereum blockchain and smart contracts. It provides comprehensive functionality for wallet connections, transaction handling, and contract interactions. Consider using Web3Modal for simplified wallet integration.

**Wallet Connection**
Web3Modal or similar libraries provide pre-built components for connecting to various wallet providers. These libraries handle the complexity of wallet integration and provide a consistent user experience across different wallet types.

**State Management**
For complex applications, consider using state management libraries like Redux, Zustand, or React Context API. These help manage application state, user data, and transaction statuses effectively. Choose based on your application complexity and team expertise.

**UI Component Libraries**
Frameworks like Tailwind CSS, Material-UI, or Chakra UI provide pre-built components that can accelerate development. Choose based on your design requirements and team expertise. Consider accessibility and customization needs when selecting a UI library.

**Form Handling**
Libraries like React Hook Form or Formik provide robust form management with validation capabilities. These are essential for domain registration forms and user input handling. Include proper error handling and user feedback in form implementations.

### **Data Flow Architecture**

**User Interaction Flow**
The typical user journey involves connecting a wallet, searching for domain availability, registering domains, and managing existing registrations. Each step requires different data handling and UI states. Design the flow to be intuitive and minimize friction points.

**State Synchronization**
Frontend applications need to maintain synchronization between local state and blockchain state. This includes handling transaction confirmations, domain updates, and real-time data changes. Implement proper state management to handle these synchronization challenges.

**Caching Strategy**
Implement intelligent caching for frequently accessed data like domain availability and user domain lists. This reduces RPC calls and improves application performance. Use appropriate cache invalidation strategies to ensure data freshness.

**Error Recovery**
Design the application to handle network errors, transaction failures, and other blockchain-related issues gracefully. Provide clear feedback and recovery options for users. Implement retry mechanisms and fallback strategies for critical operations.

### **Performance Optimization**

**Lazy Loading**
Implement lazy loading for components and data to improve initial load times. This is particularly important for domain management dashboards with multiple domains. Use code splitting and dynamic imports to reduce bundle sizes.

**Optimistic Updates**
Use optimistic updates for better user experience during transactions. Show immediate feedback while waiting for blockchain confirmations. This improves perceived performance and user satisfaction.

**Bundle Optimization**
Optimize JavaScript bundles to reduce load times and improve performance. This includes code splitting, tree shaking, and efficient dependency management. Use tools like Webpack Bundle Analyzer to identify optimization opportunities.

**CDN Integration**
Use content delivery networks for static assets to improve global performance and reduce server load. This is especially important for applications with global user bases.

### **Mobile Considerations**

**Responsive Design**
Ensure all components work well on mobile devices with touch-friendly interfaces and appropriate sizing for small screens. Test on various devices and screen sizes to ensure consistent experience.

**Progressive Web App**
Consider implementing PWA features for better mobile experience, including offline capabilities and app-like functionality. This can improve user engagement and provide native app-like experience.

**Mobile Wallet Integration**
Ensure compatibility with mobile wallet applications and provide appropriate fallbacks for different wallet types. Test with popular mobile wallets to ensure smooth integration.

### **Analytics and Monitoring**

**User Analytics**
Implement analytics to track user behavior, popular domains, and application usage patterns. This data helps improve the user experience and identify areas for optimization. Use privacy-compliant analytics solutions.

**Performance Monitoring**
Monitor application performance metrics like load times, transaction success rates, and error frequencies. This helps identify and resolve issues quickly. Set up alerts for critical performance issues.

**Error Tracking**
Implement comprehensive error tracking to identify and fix issues in production. This includes both frontend errors and blockchain transaction failures. Use tools like Sentry or similar error tracking services.

### **Accessibility and Compliance**

**WCAG Compliance**
Follow Web Content Accessibility Guidelines to ensure the application is accessible to users with disabilities. This includes proper contrast ratios, keyboard navigation, and screen reader support. Conduct accessibility audits regularly.

**Internationalization**
Consider implementing internationalization for global users, including support for different languages and regional preferences. This includes proper text formatting, currency display, and cultural considerations.

**Legal Compliance**
Ensure compliance with relevant regulations and legal requirements, especially regarding data privacy and financial transactions. This includes GDPR compliance, data protection, and financial regulations where applicable.

### **Future-Proofing**

**Upgradeability**
Design the frontend to easily accommodate new features and contract upgrades. This includes modular architecture and flexible component design. Plan for contract upgrades and new feature additions.

**Scalability**
Plan for application growth and increased user load. This includes efficient data handling, optimized queries, and scalable infrastructure. Consider horizontal scaling and performance optimization strategies.

**Feature Extensibility**
Design the application architecture to easily add new features like additional TLDs, advanced domain management tools, or integration with other services. Use modular design patterns and plugin architectures where appropriate.

## 📋 **Deployment Information**

### **Current Deployment**
- **Contract Address**: `0x7Dd0f22672C9AC0B2a88C0a3C8fac1A517C7f324`
- **Network**: Pepe Unchained Mainnet (Chain ID: 97741)
- **RPC URL**: `https://rpc-pepu-v2-mainnet-0.t.conduit.xyz`
- **Explorer**: `https://explorer-pepu-v2-mainnet-0.t.conduit.xyz`
- **Status**: ✅ **VERIFIED & LIVE**

### **Constructor Parameters**
```solidity
constructor(
    address _usdcAddress,    // USDC token contract address
    address _treasuryAddress // Treasury wallet address
)
```

### **Deployment Commands**
```bash
# Compile contract
npx hardhat compile

# Deploy to mainnet
npx hardhat run scripts/deploy.js --network pepe-unchained-mainnet

# Verify contract
npx hardhat verify --network pepe-unchained-mainnet <CONTRACT_ADDRESS> <USDC_ADDRESS> <TREASURY_ADDRESS>
```

## Dependencies

```json
{
  "@openzeppelin/contracts": "^5.0.0",
  "hardhat": "^2.19.0",
  "@nomicfoundation/hardhat-toolbox": "^4.0.0"
}
```

## 🧪 **Testing Guide**

### **Contract Testing**
```bash
# Run contract tests
npx hardhat test

# Test specific functions
npx hardhat test --grep "domain registration"
```

### **SDK Testing**
```typescript
// tests/sdk.test.ts
import { PepuDomainsSDK } from '../src/PepuDomainsSDK';

describe('PepuDomainsSDK', () => {
    let sdk: PepuDomainsSDK;

    beforeEach(() => {
        const provider = new ethers.JsonRpcProvider('https://rpc-pepu-v2-mainnet-0.t.conduit.xyz');
        sdk = new PepuDomainsSDK('0x7Dd0f22672C9AC0B2a88C0a3C8fac1A517C7f324', provider);
    });

    test('should resolve domain name', async () => {
        const walletAddress = await sdk.resolveName('tosh', '.pepu');
        expect(walletAddress).toBeDefined();
    });

    test('should check domain availability', async () => {
        const isAvailable = await sdk.isAvailable('newdomain', '.pepu');
        expect(typeof isAvailable).toBe('boolean');
    });
});
```

### **Integration Testing**
```typescript
// Test complete registration flow
test('complete registration flow', async () => {
    const signer = new ethers.Wallet(privateKey, provider);
    const sdk = new PepuDomainsSDK(contractAddress, provider, signer);
    
    // Check availability
    const isAvailable = await sdk.isAvailable('testdomain', '.pepu');
    expect(isAvailable).toBe(true);
    
    // Get fee
    const fee = await sdk.getRegistrationFee('testdomain', 1);
    expect(parseFloat(fee)).toBeGreaterThan(0);
    
    // Register domain
    const tx = await sdk.registerDomain('testdomain', '.pepu', 1);
    await tx.wait();
    
    // Verify registration
    const walletAddress = await sdk.resolveName('testdomain', '.pepu');
    expect(walletAddress).toBe(signer.address);
});
```

## 🔒 **Security Considerations**

### **Contract Security**
- ✅ **Reentrancy Protection**: All state-changing functions use `nonReentrant` modifier
- ✅ **Access Control**: Admin functions restricted to contract owner
- ✅ **SafeERC20**: Secure USDC transfers with proper error handling
- ✅ **Input Validation**: Comprehensive checks for all parameters
- ✅ **Overflow Protection**: Built-in Solidity 0.8.20 + custom checks
- ✅ **Case-Insensitive**: Domain names normalized to lowercase for consistency
- ✅ **Emergency Pause**: Pausable functionality for critical situations

### **SDK Security**
- **Private Key Management**: Never expose private keys in client-side code
- **Provider Security**: Use trusted RPC providers
- **Input Validation**: Validate all user inputs before sending to contract
- **Error Handling**: Implement proper error handling for failed transactions
- **Gas Estimation**: Always estimate gas before transactions

### **Best Practices**
```typescript
// ✅ Good: Secure private key handling
const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// ❌ Bad: Exposing private key
const signer = new ethers.Wallet('0x123...', provider);

// ✅ Good: Input validation
if (!ethers.isAddress(walletAddress)) {
    throw new Error('Invalid wallet address');
}

// ✅ Good: Error handling
try {
    const tx = await sdk.registerDomain(name, tld, duration);
    await tx.wait();
} catch (error) {
    console.error('Registration failed:', error.message);
}
```

## 📚 **Additional Resources**

### **Documentation**
- [Contract ABI](https://explorer-pepu-v2-mainnet-0.t.conduit.xyz:443/address/0x7Dd0f22672C9AC0B2a88C0a3C8fac1A517C7f324#code)
- [Audit Report](./AUDIT.md)
- [API Reference](./docs/api.md)

### **Community**
- **Discord**: [Join our community](https://discord.gg/pepudomains)
- **Twitter**: [@PepuDomains](https://twitter.com/PepuDomains)
- **GitHub**: [Contribute to the project](https://github.com/pepudomains)

### **Support**
- **Documentation**: [docs.pepudomains.com](https://docs.pepudomains.com)
- **Issues**: [GitHub Issues](https://github.com/pepudomains/issues)
- **Email**: support@pepudomains.com

## 📄 **License**

MIT License - see [LICENSE](LICENSE) file for details.

---

**Built with ❤️ for the Pepe Unchained community** 