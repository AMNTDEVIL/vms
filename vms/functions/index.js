const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Cloud Function that listens to updates in the 'orders' collection
exports.sendOrderStatusNotification = functions.firestore
  .document('orders/{orderId}') // Trigger the function when an order is updated
  .onUpdate(async (change, context) => {
    const order = change.after.data(); // Get the updated order data
    const orderId = context.params.orderId; // Get the orderId from the document path
    
    // Check if the order status is 'Accepted' or 'Rejected'
    if (order.status === 'Accepted' || order.status === 'Rejected') {
      const userUID = order.userUID; // Assuming the user UID is saved in the order document

      try {
        // Fetch user document from Firestore using the userUID
        const userDoc = await admin.firestore().collection('users').doc(userUID).get();

        if (userDoc.exists) {
          const userFCMToken = userDoc.data().fcmToken; // Assuming FCM token is stored in the user document

          // Check if the user has a valid FCM token
          if (userFCMToken) {
            // Prepare the notification payload
            const payload = {
              notification: {
                title: `Order ${order.status}`, // Title of the notification
                body: `Your order with ID ${orderId} has been ${order.status}.`, // Body of the notification
              },
            };

            // Send the notification to the user's device using the FCM token
            await admin.messaging().sendToDevice(userFCMToken, payload);

            console.log('Notification sent to user:', userUID);
          } else {
            console.log('No FCM token found for user:', userUID);
          }
        } else {
          console.log('User document not found for UID:', userUID);
        }
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    } else {
      console.log('Order status not accepted or rejected:', order.status);
    }
  });
