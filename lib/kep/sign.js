// КЕП-підписувач для авторизації в приватному API ДПС (ДСТУ 4145 через jkurwa).
// Чистого Ruby-аналога немає, тому підпис накладаємо тут, а Ruby викликає це через shell.
//
// Використання: node sign.js <РНОКПП>
// ENV:
//   DPS_KEY_PATH           шлях до файлового ключа (.jks)
//   DPS_CERT_PATH          шлях до сертифіката (.crt)
//   DPS_KEY_PASSWORD       пароль до ключа            (або)
//   DPS_KEY_PASSWORD_PATH  шлях до файлу з паролем
// Вивід: base64 значення заголовка Authorization у stdout.

const fs = require('fs');
const jk = require('jkurwa');
const algo = require('gost89/lib/compat').algos();

const rnokpp = process.argv[2];
const keyPath = process.env.DPS_KEY_PATH;
const certPath = process.env.DPS_CERT_PATH;

let password = process.env.DPS_KEY_PASSWORD;
if (!password && process.env.DPS_KEY_PASSWORD_PATH) {
  password = fs.readFileSync(process.env.DPS_KEY_PASSWORD_PATH, 'utf8').replace(/\r?\n$/, '');
}

if (!rnokpp || !keyPath || !certPath || !password) {
  process.stderr.write('sign.js: потрібні <РНОКПП> та ENV DPS_KEY_PATH/DPS_CERT_PATH/DPS_KEY_PASSWORD[_PATH]');
  process.exit(2);
}

(async () => {
  const box = new jk.Box({ algo });
  box.load({
    keyBuffers: [fs.readFileSync(keyPath)],
    certBuffers: [fs.readFileSync(certPath)],
    password,
  });
  // ВАЖЛИВО: без атрибута signingTime. З ним ДПС відхиляє підпис ("хибний підпис").
  const der = await box.pipe(Buffer.from(rnokpp), [{ op: 'sign' }], {});
  process.stdout.write(Buffer.from(der).toString('base64'));
})().catch((e) => {
  process.stderr.write(String((e && e.message) || e));
  process.exit(1);
});
