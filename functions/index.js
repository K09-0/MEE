/**
 * MEE Cloud Functions
 * 
 * Serverless backend for MicroExperiential Engine
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();

// ==================== CONFIGURATION ====================

const STRIPE_SECRET_KEY = functions.config().stripe?.secret_key || 'sk_test_your_key';
const stripeClient = stripe(STRIPE_SECRET_KEY);

const PLATFORM_FEE_PERCENT = 0.20; // 20%
const CREATOR_SHARE_PERCENT = 0.80; // 80%
const REFERRAL_BONUS_PERCENT = 0.10; // 10%

// ==================== PAYMENT FUNCTIONS ====================

/**
 * Create Stripe Payment Intent
 * 
 * Creates a payment intent for experience purchase
 */
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { experienceId, amount, currency, buyerId } = data;

  // Validate input
  if (!experienceId || !amount || !currency || !buyerId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  try {
    // Get experience details
    const experienceDoc = await db.collection('experiences').doc(experienceId).get();
    
    if (!experienceDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Experience not found');
    }

    const experience = experienceDoc.data();

    // Check if experience is available
    if (experience.status !== 'active') {
      throw new functions.https.HttpsError('failed-precondition', 'Experience is not available');
    }

    // Check if already purchased
    if (experience.purchasedBy && experience.purchasedBy.includes(buyerId)) {
      throw new functions.https.HttpsError('already-exists', 'Experience already purchased');
    }

    // Calculate amounts
    const platformFee = Math.round(amount * PLATFORM_FEE_PERCENT);
    const creatorAmount = Math.round(amount * CREATOR_SHARE_PERCENT);

    // Create payment intent
    const paymentIntent = await stripeClient.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: currency.toLowerCase(),
      automatic_payment_methods: { enabled: true },
      metadata: {
        experienceId,
        buyerId,
        sellerId: experience.creatorId,
        platformFee: platformFee.toString(),
        creatorAmount: creatorAmount.toString(),
      },
    });

    // Create pending transaction
    const transactionRef = db.collection('transactions').doc();
    await transactionRef.set({
      id: transactionRef.id,
      type: 'purchase',
      status: 'pending',
      buyerId,
      sellerId: experience.creatorId,
      experienceId,
      amount: amount / 100, // Convert back to dollars
      platformFee: platformFee / 100,
      netAmount: creatorAmount / 100,
      currency: currency.toLowerCase(),
      paymentMethod: 'stripe',
      paymentIntentId: paymentIntent.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      transactionId: transactionRef.id,
      amount: amount / 100,
      currency,
    };

  } catch (error) {
    console.error('Create payment intent error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Confirm Payment
 * 
 * Confirms successful payment and processes purchase
 */
exports.confirmPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { transactionId, paymentIntentId } = data;

  try {
    // Retrieve payment intent
    const paymentIntent = await stripeClient.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status !== 'succeeded') {
      throw new functions.https.HttpsError('failed-precondition', 'Payment not successful');
    }

    // Get transaction
    const transactionRef = db.collection('transactions').doc(transactionId);
    const transactionDoc = await transactionRef.get();

    if (!transactionDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Transaction not found');
    }

    const transaction = transactionDoc.data();

    // Update transaction
    await transactionRef.update({
      status: 'completed',
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update experience
    const experienceRef = db.collection('experiences').doc(transaction.experienceId);
    await experienceRef.update({
      salesCount: admin.firestore.FieldValue.increment(1),
      purchasedBy: admin.firestore.FieldValue.arrayUnion(transaction.buyerId),
    });

    // Update seller wallet
    const sellerWalletRef = db.collection('wallets').doc(transaction.sellerId);
    await sellerWalletRef.set({
      fiatBalance: admin.firestore.FieldValue.increment(transaction.netAmount),
      totalEarned: admin.firestore.FieldValue.increment(transaction.netAmount),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Process referral bonus if applicable
    const sellerDoc = await db.collection('users').doc(transaction.sellerId).get();
    const seller = sellerDoc.data();

    if (seller.referredBy) {
      const referralBonus = transaction.netAmount * REFERRAL_BONUS_PERCENT;
      
      // Update referrer wallet
      const referrerWalletRef = db.collection('wallets').doc(seller.referredBy);
      await referrerWalletRef.set({
        fiatBalance: admin.firestore.FieldValue.increment(referralBonus),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Create referral bonus transaction
      await db.collection('transactions').add({
        type: 'referralBonus',
        status: 'completed',
        sellerId: seller.referredBy,
        amount: referralBonus,
        netAmount: referralBonus,
        currency: transaction.currency,
        paymentMethod: 'internal',
        referralCode: seller.referralCode,
        description: `Referral bonus from ${seller.username || seller.email}`,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update referral stats
      const referralQuery = await db.collection('referrals')
        .where('referredId', '==', transaction.sellerId)
        .limit(1)
        .get();

      if (!referralQuery.empty) {
        await referralQuery.docs[0].ref.update({
          totalSpent: admin.firestore.FieldValue.increment(transaction.amount),
          totalEarned: admin.firestore.FieldValue.increment(referralBonus),
        });
      }
    }

    // Send notification to seller
    await db.collection('notifications').add({
      userId: transaction.sellerId,
      type: 'sale',
      title: 'New Sale!',
      body: `Someone purchased your experience for $${transaction.amount.toFixed(2)}`,
      data: {
        experienceId: transaction.experienceId,
        transactionId: transactionId,
        amount: transaction.amount,
      },
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      transaction: {
        id: transactionId,
        ...transaction,
        status: 'completed',
      },
    };

  } catch (error) {
    console.error('Confirm payment error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Stripe Webhook Handler
 * 
 * Handles Stripe webhook events
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = functions.config().stripe?.webhook_secret;

  let event;

  try {
    event = stripeClient.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle events
  switch (event.type) {
    case 'payment_intent.succeeded':
      // Payment already handled in confirmPayment
      console.log('Payment intent succeeded:', event.data.object.id);
      break;

    case 'payment_intent.payment_failed':
      const failedPayment = event.data.object;
      console.log('Payment failed:', failedPayment.id);
      
      // Update transaction status
      const failedTxQuery = await db.collection('transactions')
        .where('paymentIntentId', '==', failedPayment.id)
        .limit(1)
        .get();
      
      if (!failedTxQuery.empty) {
        await failedTxQuery.docs[0].ref.update({
          status: 'failed',
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
          failureReason: failedPayment.last_payment_error?.message || 'Payment failed',
        });
      }
      break;

    default:
      console.log(`Unhandled event type: ${event.type}`);
  }

  res.json({ received: true });
});

// ==================== AI FUNCTIONS ====================

/**
 * Generate Image
 * 
 * Generates image using AI (calls external API)
 */
exports.generateImage = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { prompt, style, size, userId } = data;

  try {
    // Check generation limits
    const userDoc = await db.collection('users').doc(userId).get();
    const user = userDoc.data();

    const now = new Date();
    const lastGenDate = user.lastGenerationDate?.toDate();
    
    // Reset daily count if new day
    if (!lastGenDate || 
        lastGenDate.getDate() !== now.getDate() ||
        lastGenDate.getMonth() !== now.getMonth()) {
      await userDoc.ref.update({
        dailyGenerationsUsed: 0,
        lastGenerationDate: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Check limit
    const dailyLimit = user.subscription === 'pro' ? 50 : 3;
    if (user.dailyGenerationsUsed >= dailyLimit) {
      throw new functions.https.HttpsError('resource-exhausted', 'Daily generation limit reached');
    }

    // TODO: Call AI generation API (Replicate, Hugging Face, etc.)
    // For now, return placeholder
    const generationId = `gen_${Date.now()}`;

    // Increment usage
    await userDoc.ref.update({
      dailyGenerationsUsed: admin.firestore.FieldValue.increment(1),
      lastGenerationDate: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Store generation record
    await db.collection('ai_generations').doc(generationId).set({
      id: generationId,
      userId,
      type: 'image',
      prompt,
      style: style || 'default',
      size: size || '1024x1024',
      contentUrl: '', // Will be updated after generation
      status: 'pending',
      creditsUsed: 1,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      generationId,
      status: 'pending',
      message: 'Image generation started',
    };

  } catch (error) {
    console.error('Generate image error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Check Content Safety
 * 
 * Moderates content using AI
 */
exports.checkContentSafety = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { content, contentType } = data;

  try {
    // TODO: Call moderation API (Perspective API, Hugging Face, etc.)
    // For now, return safe result
    
    // Basic profanity check
    const prohibitedWords = ['spam', 'scam', 'fake', 'illegal', 'hate', 'violence'];
    const lowerContent = content.toLowerCase();
    
    const flaggedWords = prohibitedWords.filter(word => 
      lowerContent.includes(word)
    );

    return {
      isSafe: flaggedWords.length === 0,
      safetyScore: flaggedWords.length === 0 ? 1.0 : 0.0,
      flaggedCategories: flaggedWords.length > 0 ? ['prohibited'] : null,
    };

  } catch (error) {
    console.error('Content safety check error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ==================== SCHEDULED FUNCTIONS ====================

/**
 * Daily Reset
 * 
 * Resets daily generation limits for all users
 */
exports.dailyReset = functions.pubsub.schedule('0 0 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    console.log('Running daily reset...');

    const batch = db.batch();
    let count = 0;

    // Get all users
    const usersSnapshot = await db.collection('users').get();

    usersSnapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {
        dailyGenerationsUsed: 0,
      });
      count++;

      // Firestore batch limit is 500
      if (count === 500) {
        batch.commit();
        count = 0;
      }
    });

    if (count > 0) {
      await batch.commit();
    }

    console.log(`Reset daily limits for ${usersSnapshot.size} users`);
    return null;
  });

/**
 * Expire Experiences
 * 
 * Marks expired experiences
 */
exports.expireExperiences = functions.pubsub.schedule('*/5 * * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    console.log('Checking for expired experiences...');

    const now = admin.firestore.Timestamp.now();

    const expiredQuery = await db.collection('experiences')
      .where('status', '==', 'active')
      .where('expiresAt', '<', now)
      .get();

    const batch = db.batch();

    expiredQuery.docs.forEach((doc) => {
      batch.update(doc.ref, {
        status: 'expired',
      });
    });

    await batch.commit();

    console.log(`Marked ${expiredQuery.size} experiences as expired`);
    return null;
  });

// ==================== TRIGGER FUNCTIONS ====================

/**
 * On User Created
 * 
 * Initialize user wallet and send welcome notification
 */
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  console.log('New user created:', user.uid);

  // Create wallet
  await db.collection('wallets').doc(user.uid).set({
    userId: user.uid,
    fiatBalance: 0,
    solBalance: 0,
    tonBalance: 0,
    pendingBalance: 0,
    totalEarned: 0,
    totalSpent: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send welcome notification
  await db.collection('notifications').add({
    userId: user.uid,
    type: 'system',
    title: 'Welcome to MEE!',
    body: 'Start creating and sharing your micro-experiences today.',
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return null;
});

/**
 * On Experience Created
 * 
 * Process AI generation and content moderation
 */
exports.onExperienceCreated = functions.firestore
  .document('experiences/{experienceId}')
  .onCreate(async (snap, context) => {
    const experience = snap.data();
    console.log('New experience created:', context.params.experienceId);

    // TODO: Trigger AI generation if needed
    // TODO: Run content moderation

    return null;
  });

// ==================== ADMIN FUNCTIONS ====================

/**
 * Get Admin Stats
 * 
 * Returns platform statistics (admin only)
 */
exports.getAdminStats = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Check admin role
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  const user = userDoc.data();

  if (user.role !== 'admin' && user.role !== 'superAdmin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }

  try {
    // Get stats
    const usersCount = await db.collection('users').count().get();
    const experiencesCount = await db.collection('experiences').count().get();
    const transactionsCount = await db.collection('transactions').count().get();

    // Get total revenue
    const transactionsSnapshot = await db.collection('transactions')
      .where('status', '==', 'completed')
      .get();

    let totalRevenue = 0;
    let totalPlatformFees = 0;

    transactionsSnapshot.docs.forEach((doc) => {
      const tx = doc.data();
      totalRevenue += tx.amount || 0;
      totalPlatformFees += tx.platformFee || 0;
    });

    return {
      users: usersCount.data().count,
      experiences: experiencesCount.data().count,
      transactions: transactionsCount.data().count,
      totalRevenue,
      totalPlatformFees,
    };

  } catch (error) {
    console.error('Get admin stats error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
