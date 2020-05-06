const functions = require("firebase-functions");

const admin = require("firebase-admin");

admin.initializeApp();
const fcm = admin.messaging();

exports.sendNewWallPaperNotification = functions.firestore
  .document("wallpaper/{wallpaperId}")
  .onCreate((snapshot) => {
    const data = snapshot.data();
    var payload = {
      notification: {
        title: "WallyApp",
        body: "New wallpaper is here",
        icon: "name",
        image: data.url,
      },
    };

    const topic = "promotion";

    return fcm.sendToTopic(topic, payload);
  });
