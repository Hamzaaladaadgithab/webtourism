importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDJHxZZpVDTFEkDyYkFYhZcUWJJGxEDXsY",
  authDomain: "webtourism-c6ae1.firebaseapp.com",
  projectId: "webtourism-c6ae1",
  storageBucket: "webtourism-c6ae1.appspot.com",
  messagingSenderId: "1052949333289",
  appId: "1:1052949333289:web:5c3d9e0a7d6a5f8f7c6d8b"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
