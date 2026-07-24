importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDM7XFcpCcJ8Hqu006Dvg3Gb2f0j98fHc0',
  appId: '1:976469473142:web:ae9744f6b3dc3c34dbac57',
  messagingSenderId: '976469473142',
  projectId: 'mvp-travel-prod',
  authDomain: 'mvp-travel-prod.firebaseapp.com',
  storageBucket: 'mvp-travel-prod.firebasestorage.app',
  measurementId: 'G-MKZTEXL0LB',
});

firebase.messaging();
