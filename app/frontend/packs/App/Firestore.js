const firebase = require("firebase/app");
require("firebase/firestore");
require("firebase/auth");

const firebaseConfig = JSON.parse(process.env.FIREBASE_CONFIG);
const firestoreSettings = process.env.FIRESTORE_EMULATOR_HOST ?
      { host: `${process.env.FIRESTORE_EMULATOR_HOST}:${process.env.FIRESTORE_EMULATOR_PORT}`,
        ssl: false
      } : {};

exports.connect = () => {
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

  window.firebase = firebase;

  return { db, gameId };
};

exports.addCommand = obj => ({ db, gameId }) => () => {
  db.collection("games")
    .doc(gameId)
    .collection("commands")
    .add(
      Object.assign(obj, {
        created_at: firebase.firestore.FieldValue.serverTimestamp()
      }));
};

exports.onSnapshotCommandAdd = listener => ({ db, gameId }) => () => {
  db.collection("games")
    .doc(gameId)
    .collection("commands")
    .orderBy("created_at")
    .onSnapshot(snapshot => {
      snapshot.docChanges().forEach(change => {
        if (!change.doc.metadata.hasPendingWrites) {
          if (change.type === "added") {
            listener(change.doc.data())();
          }
        }
      });
    });
};
