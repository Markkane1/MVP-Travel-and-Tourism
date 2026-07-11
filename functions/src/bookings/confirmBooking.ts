import * as admin from 'firebase-admin';

/**
 * Reusable core transaction logic to confirm a booking.
 * 
 * Verifies document ownership and status, creates a unique reference code,
 * awards loyalty points, and writes a user notification.
 */
export async function confirmBookingLogic(
  db: admin.firestore.Firestore,
  bookingId: string,
  userId: string,
  stripePaymentIntentId?: string
): Promise<{ bookingReferenceCode: string; totalPrice: number }> {
  const bookingRef = db.collection('bookings').doc(bookingId);
  const userRef = db.collection('users').doc(userId);

  return db.runTransaction(async (transaction) => {
    // 1. Get the booking doc
    const bookingDoc = await transaction.get(bookingRef);
    if (!bookingDoc.exists) {
      throw new Error('Booking not found');
    }
    const bookingData = bookingDoc.data();
    if (!bookingData) {
      throw new Error('Booking data is empty');
    }

    // Verify ownership and status
    if (bookingData.userId !== userId) {
      throw new Error('Unauthorized booking ownership');
    }
    if (bookingData.status !== 'pending') {
      throw new Error(`Booking is already ${bookingData.status}`);
    }

    // 2. Fetch the corresponding tour to get its category
    const tourId = bookingData.tourId;
    if (!tourId) {
      throw new Error('Booking does not specify a tour ID');
    }
    const tourRef = db.collection('tours').doc(tourId);
    const tourDoc = await transaction.get(tourRef);
    if (!tourDoc.exists) {
      throw new Error('Associated tour not found');
    }
    const tourData = tourDoc.data();
    if (!tourData) {
      throw new Error('Tour data is empty');
    }

    const category = tourData.category || 'GEN';
    const categoryCode = category.slice(0, 3).toUpperCase();

    // 3. Generate bookingReferenceCode (pattern: "LT-" + 5 random digits + "-" + categoryCode)
    const randomDigits = Math.floor(10000 + Math.random() * 90000).toString();
    const bookingReferenceCode = `LT-${randomDigits}-${categoryCode}`;

    // 4. Update booking to status: 'confirmed'
    const updateData: any = {
      status: 'confirmed',
      bookingReferenceCode: bookingReferenceCode,
    };
    if (stripePaymentIntentId) {
      updateData.stripePaymentIntentId = stripePaymentIntentId;
    }
    transaction.update(bookingRef, updateData);

    // 5. Calculate authentic price and override client data
    const pricePerPerson = tourData.pricePerPerson || 0;
    const adults = bookingData.adults || 0;
    const children = bookingData.children || 0;
    
    // Base price
    let authenticTotalPrice = pricePerPerson * (adults + (children * 0.5));
    
    // Group Size Modifier
    const groupSizeOptions = tourData.groupSizeOptions || [];
    const clientOption = bookingData.groupSizeOption || '';
    const selectedOption = groupSizeOptions.find((opt: any) => opt.label === clientOption);
    if (selectedOption && typeof selectedOption.priceModifier === 'number') {
      authenticTotalPrice += selectedOption.priceModifier;
    }
    
    // Private Vehicle Surcharge
    if (bookingData.privateVehicle === true) {
      authenticTotalPrice += (tourData.privateVehicleSurcharge || 0);
    }
    
    // Override the total price to ensure integrity
    transaction.update(bookingRef, {
      totalPrice: authenticTotalPrice,
    });

    // Update user's loyaltyPoints by floor(authenticTotalPrice / 10)
    const pointsAwarded = Math.floor(authenticTotalPrice / 10);
    
    const userDoc = await transaction.get(userRef);
    let currentPoints = 0;
    if (userDoc.exists) {
      currentPoints = userDoc.data()?.loyaltyPoints || 0;
    }
    transaction.update(userRef, {
      loyaltyPoints: currentPoints + pointsAwarded,
    });

    // 6. Write a notifications/{uid}/items document
    const notificationRef = db.collection('notifications').doc(userId).collection('items').doc();
    transaction.set(notificationRef, {
      title: 'Booking Confirmed',
      body: `Your expedition to ${bookingData.tourSnapshot?.title || 'your destination'} is ready!`,
      type: 'booking',
      deepLink: `/trips/${bookingId}`,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { bookingReferenceCode, totalPrice: authenticTotalPrice };
  });
}
