// Envía un Data Message de borrado remoto vía firebase-admin (FCM HTTP v1).
//
// firebase-admin obtiene el token OAuth2 automáticamente desde la cuenta de
// servicio, así que NO hace falta gcloud ni gestionar tokens a mano.
//
// Uso:
//   1) npm install        (instala firebase-admin)
//   2) coloca service-account.json en esta carpeta (tools/)
//   3) node send_wipe.js

const admin = require("firebase-admin");
const serviceAccount = require("./service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Token FCM del dispositivo (cópialo del log `═══ FCM TOKEN ═══` de flutter run).
const deviceToken =
  "";

admin
  .messaging()
  .send({
    token: deviceToken,
    android: { priority: "high" }, // entrega inmediata en segundo plano
    data: {
      accion: "wipe",
      clave: "", // la palabra clave que configuraste en la app
    },
  })
  .then((res) => {
    console.log("✅ Data Message enviado:", res);
    process.exit(0);
  })
  .catch((err) => {
    console.error("❌ Error:", err);
    process.exit(1);
  });
