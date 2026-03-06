# MEE Database Schema

## Firestore Collections

### 1. users

Хранит информацию о пользователях.

```javascript
{
  id: string,                    // Firebase Auth UID
  email: string,                 // Email address
  username: string?,             // Unique username
  displayName: string?,          // Display name
  avatarUrl: string?,            // Profile picture URL
  bio: string?,                  // User bio
  dateOfBirth: timestamp?,       // For age verification
  
  // Wallet
  walletAddress: string?,        // Connected wallet address
  walletType: string,            // 'none' | 'phantom' | 'tonkeeper' | 'metamask'
  
  // Balance & Stats
  balance: number,               // Fiat balance (USD)
  totalEarned: number,           // Total earnings
  rating: number,                // User rating (0-5)
  
  // Referral
  referralCode: string,          // Unique referral code
  referredBy: string?,           // Referrer user ID
  
  // Status
  role: string,                  // 'user' | 'creator' | 'moderator' | 'admin'
  status: string,                // 'active' | 'inactive' | 'suspended' | 'banned'
  
  // Subscription
  subscription: string,          // 'free' | 'pro' | 'enterprise'
  subscriptionExpiresAt: timestamp?,
  
  // AI Generation Limits
  dailyGenerationsUsed: number,  // Today's usage
  lastGenerationDate: timestamp?, // Last generation date
  
  // Preferences
  interests: string[],           // User interests
  preferences: map,              // App preferences
  
  // Timestamps
  createdAt: timestamp,
  updatedAt: timestamp,
  lastLoginAt: timestamp?
}
```

**Indexes:**
- `username` (unique)
- `referralCode` (unique)
- `walletAddress`
- `status`
- `subscription`

---

### 2. experiences

Хранит микроопыты (цифровые активы).

```javascript
{
  id: string,                    // Auto-generated ID
  creatorId: string,             // Reference to users collection
  
  // Content
  type: string,                  // 'art' | 'text' | 'audio' | 'miniGame'
  title: string,                 // Experience title
  description: string?,          // Description
  aiPrompt: string?,             // AI generation prompt
  contentUrl: string,            // Main content URL (encrypted for buyers)
  thumbnailUrl: string?,         // Thumbnail image
  previewUrl: string?,           // Preview for non-buyers
  
  // Pricing
  price: number,                 // Price amount
  currency: string,              // 'usd' | 'eur' | 'gbp' | 'sol' | 'ton'
  
  // Status
  status: string,                // 'draft' | 'pending' | 'active' | 'soldOut' | 'expired' | 'hidden' | 'removed'
  
  // FOMO Timer
  createdAt: timestamp,
  expiresAt: timestamp,          // FOMO expiration
  publishedAt: timestamp?,       // When made active
  
  // Stats
  salesCount: number,
  viewsCount: number,
  likesCount: number,
  
  // Tags & Metadata
  tags: string[],
  metadata: map,                 // Type-specific data
  
  // NFT
  isNft: boolean,
  nftAddress: string?,           // NFT contract address
  
  // Purchasers
  purchasedBy: string[],         // Array of user IDs
  
  // Rating
  rating: number,                // Average rating (0-5)
  reviewCount: number,
  
  // Content Rating
  contentRating: string,         // 'everyone' | 'teen' | 'mature' | 'adult'
  language: string?,             // Content language
  
  // Featured
  isFeatured: boolean,
  featuredAt: timestamp?
}
```

**Indexes:**
- `creatorId`
- `type`
- `status`
- `price`
- `expiresAt`
- `salesCount` (descending)
- `viewsCount` (descending)
- `isFeatured`
- `tags` (array)
- `purchasedBy` (array)

---

### 3. transactions

Хранит финансовые транзакции.

```javascript
{
  id: string,                    // Auto-generated ID
  
  // Parties
  type: string,                  // 'purchase' | 'sale' | 'withdrawal' | 'deposit' | 'referralBonus' | 'subscription' | 'refund'
  status: string,                // 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled' | 'refunded' | 'disputed'
  
  // Users
  buyerId: string?,              // Buyer user ID
  sellerId: string?,             // Seller user ID
  
  // Experience
  experienceId: string?,         // Reference to experience
  
  // Amount
  amount: number,                // Total amount
  platformFee: number,           // 20% platform fee
  netAmount: number,             // 80% to seller
  currency: string,              // 'usd' | 'eur' | 'gbp' | 'sol' | 'ton'
  
  // Payment
  paymentMethod: string,         // 'stripe' | 'solanaPay' | 'tonConnect' | 'applePay' | 'googlePay' | 'internal'
  paymentIntentId: string?,      // Stripe payment intent ID
  blockchainTxHash: string?,     // Crypto transaction hash
  
  // Referral
  referralCode: string?,         // If referral bonus
  
  // Details
  description: string?,
  metadata: map,
  
  // Timestamps
  createdAt: timestamp,
  completedAt: timestamp?,
  failedAt: timestamp?,
  failureReason: string?,
  refundedAt: timestamp?,
  refundedAmount: number?
}
```

**Indexes:**
- `buyerId`
- `sellerId`
- `experienceId`
- `status`
- `type`
- `createdAt` (descending)
- `paymentMethod`

---

### 4. wallets

Хранит балансы кошельков пользователей.

```javascript
{
  userId: string,                // Same as users.id
  
  // Balances
  fiatBalance: number,           // USD balance
  solBalance: number,            // SOL balance
  tonBalance: number,            // TON balance
  pendingBalance: number,        // Pending withdrawals
  
  // Stats
  totalEarned: number,
  totalSpent: number,
  
  // Timestamps
  updatedAt: timestamp
}
```

**Indexes:**
- `userId` (unique)

---

### 5. likes

Хранит лайки пользователей (отдельная коллекция для масштабируемости).

```javascript
{
  userId: string,
  experienceId: string,
  createdAt: timestamp
}
```

**Indexes:**
- `userId`
- `experienceId`
- Composite: `[userId, experienceId]` (unique)

---

### 6. reports

Хранит жалобы на контент.

```javascript
{
  id: string,
  reporterId: string,            // User who reported
  targetType: string,            // 'experience' | 'user' | 'review'
  targetId: string,              // ID of reported item
  reason: string,                // Report reason
  details: string?,              // Additional details
  status: string,                // 'pending' | 'reviewing' | 'resolved' | 'dismissed'
  resolvedBy: string?,           // Moderator ID
  resolution: string?,           // Resolution notes
  createdAt: timestamp,
  resolvedAt: timestamp?
}
```

**Indexes:**
- `reporterId`
- `targetId`
- `status`
- `createdAt` (descending)

---

### 7. ai_generations

Хранит историю AI генераций.

```javascript
{
  id: string,
  userId: string,
  
  // Generation
  type: string,                  // 'image' | 'text' | 'audio' | 'game'
  prompt: string,
  enhancedPrompt: string?,
  contentUrl: string,
  thumbnailUrl: string?,
  
  // Settings
  style: string?,
  size: string?,
  
  // Credits
  creditsUsed: number,
  
  // Timestamps
  createdAt: timestamp,
  expiresAt: timestamp?          // If not saved as experience
}
```

**Indexes:**
- `userId`
- `type`
- `createdAt` (descending)

---

### 8. referrals

Хранит информацию о рефералах.

```javascript
{
  id: string,
  referrerId: string,            // User who referred
  referredId: string,            // New user
  referralCode: string,
  
  // Stats
  totalSpent: number,            // Total spent by referred user
  totalEarned: number,           // Total earned by referrer from this referral
  
  // Timestamps
  createdAt: timestamp
}
```

**Indexes:**
- `referrerId`
- `referredId`
- `referralCode`

---

### 9. notifications

Хранит уведомления пользователей.

```javascript
{
  id: string,
  userId: string,
  
  // Content
  type: string,                  // 'sale' | 'purchase' | 'like' | 'follow' | 'system'
  title: string,
  body: string,
  data: map,                     // Additional data
  
  // Status
  isRead: boolean,
  
  // Timestamps
  createdAt: timestamp
}
```

**Indexes:**
- `userId`
- `isRead`
- `createdAt` (descending)

---

## Security Rules

### users
```javascript
match /users/{userId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.auth.uid == userId;
  allow update: if request.auth != null && request.auth.uid == userId;
  allow delete: if false; // Only admin can delete
}
```

### experiences
```javascript
match /experiences/{experienceId} {
  allow read: if true; // Public read
  allow create: if request.auth != null 
    && request.resource.data.creatorId == request.auth.uid
    && request.resource.data.status == 'draft';
  allow update: if request.auth != null 
    && resource.data.creatorId == request.auth.uid;
  allow delete: if request.auth != null 
    && resource.data.creatorId == request.auth.uid
    && resource.data.salesCount == 0;
}
```

### transactions
```javascript
match /transactions/{transactionId} {
  allow read: if request.auth != null 
    && (resource.data.buyerId == request.auth.uid 
        || resource.data.sellerId == request.auth.uid);
  allow create: if false; // Only Cloud Functions
  allow update: if false; // Only Cloud Functions
  allow delete: if false;
}
```

---

## Cloud Functions

### Authentication Triggers

1. **onUserCreated** - Initialize user wallet and send welcome email
2. **onUserDeleted** - Clean up user data

### Experience Triggers

1. **onExperienceCreated** - Process AI generation, content moderation
2. **onExperiencePublished** - Send notifications to followers
3. **onExperiencePurchased** - Update stats, notify creator
4. **onExperienceExpired** - Archive experience

### Payment Functions

1. **createPaymentIntent** - Create Stripe payment intent
2. **confirmPayment** - Confirm payment and process purchase
3. **processWithdrawal** - Process withdrawal request
4. **handleStripeWebhook** - Handle Stripe webhooks

### AI Functions

1. **generateImage** - Generate image using Stable Diffusion
2. **generateText** - Generate text content
3. **checkContentSafety** - Moderate content

### Scheduled Functions

1. **dailyReset** - Reset daily generation limits
2. **expireExperiences** - Mark expired experiences
3. **processPayouts** - Process pending withdrawals

---

## Data Retention

- **AI Generations**: 30 days (unless saved as experience)
- **Notifications**: 90 days
- **Deleted Experiences**: 30 days soft delete, then permanent
- **Transaction Logs**: 7 years (compliance)

---

## Backup Strategy

- Daily automated backups
- Point-in-time recovery enabled
- Cross-region replication for critical data
