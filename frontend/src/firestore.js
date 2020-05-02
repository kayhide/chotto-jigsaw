import firebase from "firebase/app";
import "firebase/firestore";
import "firebase/auth";

const firebaseConfig = JSON.parse(process.env.FIREBASE_CONFIG);
const firestoreSettings = process.env.FIRESTORE_EMULATOR_HOST ?
      { host: `${process.env.FIRESTORE_EMULATOR_HOST}:${process.env.FIRESTORE_EMULATOR_PORT}`,
        ssl: false
      } : {};


export default class Firestore {
  static init() {
    const { firebaseToken, gameId } = document.querySelector("#playboard").dataset;

    firebase.initializeApp(firebaseConfig);
    firebase
      .auth()
      .signInWithCustomToken(firebaseToken)
      .catch(error => {
        const { code, message } = error;
        if (code === 'auth/invalid-custom-token') {
          console.error('The token you provided is not valid.');
        } else {
          console.error(error);
        }
      });

    const db = firebase.firestore();
    db.settings(firestoreSettings);

    db.collection("games").doc(gameId)
      .collection("commands").orderBy("created_at")
      .onSnapshot(snapshot => {
      snapshot.docChanges().forEach(change => {
        console.log(change);
        console.log(change.doc.data());
      });
    });

    window.firebase = firebase;
  }
};
