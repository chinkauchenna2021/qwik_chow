const functions = require('firebase-functions');
const admin = require ("firebase-admin");
// admin.initializeApp();
const firestore = admin.firestore();

/*
** Dispatch orders to vendors and drivers
*/
exports.dispatch = functions.firestore
.document("restaurant_orders/{orderID}")
.onWrite(async (change, context) => {

    const orderData = change.after.data();
    
    if (!orderData) {
        console.log("No order data");
        return;
    }

    if (orderData.status === "Order Cancelled") {
        console.log("Order #" + change.after.ref.id + " was cancelled.")
        return null
    }

    if (orderData.status === "Order Placed") {
        // this is a new order, so we need to send it to the vendor for approval
        console.log("Order #" + change.after.ref.id + " was sent to vendor for approval.")
        return null
    }

    if (orderData.takeAway === true) {
        // this is a new order, so we need to send it to the vendor for approval
        console.log("Order #" + change.after.ref.id + " was sent as takeAway to vendor for approval.")
        return null
    }

   if (orderData.status === "Order Accepted" || orderData.status === "Driver Rejected") {
        // the vendor accepted the order, so we need to find an available driver
        console.log("Finding a driver for order #" + change.after.ref.id)

        const rejectedByDrivers = orderData.rejectedByDrivers ? orderData.rejectedByDrivers : []

        var orderId = change.after.ref.id;
        var driverNearByData = await getDriverNearByData();
        var minimumDepositToRideAccept = 0;
        var orderAcceptRejectDuration = 0;
        var kDistanceRadiusForDispatchInMiles = 50;
        var singleOrderReceive = false;
        
        if(driverNearByData !== undefined){
            if(driverNearByData.minimumDepositToRideAccept !== undefined){
                minimumDepositToRideAccept = parseInt(driverNearByData.minimumDepositToRideAccept);
            }
            if(driverNearByData.driverOrderAcceptRejectDuration !== undefined){
                 orderAcceptRejectDuration = parseInt(driverNearByData.driverOrderAcceptRejectDuration);
            }
            if(driverNearByData.driverRadios !== undefined){
                 kDistanceRadiusForDispatchInMiles = parseInt(driverNearByData.driverRadios);
            }
            if(driverNearByData.singleOrderReceive !== undefined){
                 singleOrderReceive = driverNearByData.singleOrderReceive;
            }
        }

        console.log('minimumDepositToRideAccept',minimumDepositToRideAccept);
        console.log('orderAcceptRejectDuration',orderAcceptRejectDuration);

        // change.after.ref.set({ status: "Pending Driver" }, {merge: true})
        return firestore
            .collection("users")
            .where('role', '==', "driver")
            .where('isActive', '==', true)
            .where('wallet_amount', '>=', minimumDepositToRideAccept)
            .get()
            .then(snapshot => {
                var found = false
                snapshot.forEach(doc => {
                    if (!found) {
                        // We simply assign the first available driver who's within a reasonable distance from the vendor and who did not reject the order and who is not delivering already
                        const driver = doc.data();
                        console.log(driver)

                        if (driver.location && rejectedByDrivers.indexOf(driver.id) === -1) {
                            const vendor = orderData.vendor
                            if (vendor) {
                                const distance = distanceRadius(driver.location.latitude, driver.location.longitude, vendor.latitude, vendor.longitude)
                                console.log("Driver (" + driver.email + " Location: ")
                                console.log(driver.location)
                                console.log("Vendor Location: lat " + vendor.latitude + " long" + vendor.longitude)
                                console.log(distance)
                                if (distance < kDistanceRadiusForDispatchInMiles) {
                                    found = true

                                    //set data for notification
                                    var time = Math.floor(orderAcceptRejectDuration / 60) + ":" + (orderAcceptRejectDuration % 60 ? orderAcceptRejectDuration % 60 : '00');
                                    const payload = {
                                        "notification": {
                                            "title": "New order received",
                                            "body": "You have a new order, please accept the order in "+time+" mins",
                                            "sound": "default",
                                        },
                                    };
                                    //send notification to driver
                                    admin.messaging().sendToDevice([driver.fcmToken], payload).then((response) => {
                                        console.log('Notification Success:',response);
                                        return null
                                    }).catch((error) => {
                                        console.log('Notification Error:',error);
                                    });

                                    // We update the order status
                                    change.after.ref.set({ status: "Driver Pending" }, {merge: true})
                                    .then(async function (result) {
                                        // After update the order status get new updated status
                                         firestore.collection("restaurant_orders").doc(orderId).get().then((querySnapshot) => {	
                                            var newOrderData = querySnapshot.data();
                                            // Check if driver is accepting the order within defined time or not
                                            if(orderAcceptRejectDuration > 0 && newOrderData.status === "Driver Pending"){
                                                setTimeout(function(){ 
                                                    // Re-check order status after time limit exceed before find out other driver
                                                    firestore.collection("restaurant_orders").doc(orderId).get().then((querySnapshot) => {
                                                        var newOrderData2 = querySnapshot.data();
                                                        // If order status is driver pending then and only we will find new driver and current driver will add to rejected list
                                                        if(newOrderData2.status === "Driver Pending"){
                                                            // We changed the ordering method to assign multiple orders to single driver so now find orderRequestData for current driver
                                                            firestore.collection("users").doc(driver.id).get().then((querySnapshot) => {
                                                                var driverData = querySnapshot.data();
                                                                //Now remove current orderId from all assigned order to this driver because they have not accepted current order in time
                                                                const newOrderRequestData = driverData.orderRequestData.filter(function (oid) {
                                                                    return oid !== orderId;
                                                                });
                                                                //Now update new orderRequestData after removing current order
                                                                firestore.collection('users').doc(driver.id).update({
                                                                    'orderRequestData': newOrderRequestData,
                                                                });
                                                                // Current driver is adding to rejected list so they will not receive order again and update status to find new driver
                                                                rejectedByDrivers.push(driver.id);
                                                                firestore.collection('restaurant_orders').doc(orderId).update({
                                                                    'status': 'Order Accepted',
                                                                    'rejectedByDrivers': rejectedByDrivers
                                                                })
                                                                console.log("Order not accepted by driver #" + driver.id + " for order #" + orderId + " within " + orderAcceptRejectDuration + " seconds, searching for next driver.")
                                                            })
                                                        }
                                                        return null
                                                    })
                                                    .catch(error => {
                                                        console.log(error)
                                                    })
                                                },orderAcceptRejectDuration*1000);
                                            }
                                            return null
                                        })
                                        .catch(error => {
                                            console.log(error)
                                        })
                                        return null
                                    })
                                    .catch(error => {
                                        console.log(error)
                                    })
                                    // We changed the ordering method to assign multiple orders to single driver
                                    // We send the order to the driver, by appending orderRequestData to the driver's user model in the users table
                                    var orderRequestData = [];
                                    if(driver.orderRequestData != undefined){
                                        if(singleOrderReceive == false){
                                            if(driver.orderRequestData.length == 0){
                                                orderRequestData.push(orderId);
                                            }else{
                                                if(driver.orderRequestData.indexOf(orderId) === -1) {
                                                    driver.orderRequestData.push(orderId);
                                                }
                                                orderRequestData = driver.orderRequestData;
                                            }
                                        }else{
                                            orderRequestData.push(orderId);
                                        }
                                    }else{
                                        orderRequestData.push(orderId);
                                    }
                                    firestore.collection('users').doc(driver.id).update({
                                        orderRequestData: orderRequestData,
                                    });

                                    console.log("Order sent to driver #" + driver.id + " for order #" + change.after.ref.id + " with distance at " + distance)
                                }
                            }
                        }
                    }
                })
                if (!found) {
                    // We did not find an available driver
                    console.log("Could not find an available driver for order #" + change.after.ref.id)
                }
                return null
            })
            .catch(error => {
                console.log(error)
            })
    }

    if (orderData.status === "Driver Accepted") {
        // Vendor accepted, driver accepted, so we update the delivery status
        change.after.ref.set({ status: "Order Shipped" }, {merge: true})
        console.log("Order #" + change.after.ref.id + " was shipped")
        return null
    }
    return null
});

const distanceRadius = (lat1, lon1, lat2, lon2) => {
	if ((lat1 === lat2) && (lon1 === lon2)) {
		return 0;
	}
	else {
		var radlat1 = Math.PI * lat1/180;
		var radlat2 = Math.PI * lat2/180;
		var theta = lon1-lon2;
		var radtheta = Math.PI * theta/180;
		var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
		if (dist > 1) {
			dist = 1;
		}
		dist = Math.acos(dist);
		dist = dist * 180/Math.PI;
		dist = dist * 60 * 1.1515;
		return dist;
	}
}

async function getDriverNearByData(){
    var snapshot =  await firestore.collection("settings").doc('DriverNearBy').get();
    return snapshot.data();
}