/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

const delivery = require('./products/delivery')

exports.deliveryDispatch = delivery.dispatch

exports.deleteUser = functions.https.onCall(async (data, context) => {
    try {
        // Potentially verify that the user calling the CF has the right to delete users
        await admin.auth().deleteUser(data.uid);
        return { result: 'user successfully deleted'};
    } catch (error) {
        throw new functionsGlobal.https.HttpsError('failed-precondition','The function must be called while authenticated.', 'hello');   // See https://firebase.google.com/docs/functions/callable#handle_errors
    }

});