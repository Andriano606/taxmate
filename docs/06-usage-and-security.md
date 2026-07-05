# 06 — Використання клієнтів, файли, безпека

## Як користуватись (Ruby-клієнти)

З кореня Rails-проєкту, через `bin/rails runner` або консоль (`bin/rails console`):

```ruby
# Перевірка ДПС
signer = Dps::KepSigner.new(
  key_path: "../pb_3525511937.jks", cert_path: "../sign.crt", password_path: "../password.txt")
dps = Dps::Client.new(rnokpp: "3525511937", signer: signer)
dps.debt                        # борг; [] = боргу немає
dps.settlements(year: 2026)     # стан розрахунків з бюджетом
dps.declarations(year: 2026)    # подані декларації
dps.payer_card                  # реєстраційна картка
dps.declaration_xml(year: 2026, cod_regdoc: 265724572032994)  # XML декларації

# Дохід із banku
mono = Monobank::Client.new(token: File.read("../mono-token.txt").strip)
mono.fop_accounts               # ФОП-рахунки
mono.credits(account: id, from: Time.zone.local(2026,4,1), to: Time.zone.local(2026,7,1))
```

Тести: `bundle exec rspec spec/clients` (16 прикладів, HTTP застаблено WebMock — без мережі).

## Розкладка файлів

```
~/Documents/taxmate/              ← СЕКРЕТИ тут (поза Rails-проєктом, шлях "../" від коду)
├── pb_3525511937.jks           закритий КЕП-ключ (пароль-захищений)
├── sign.crt                    сертифікат (публічний)
├── password.txt                пароль до ключа
├── mono-token.txt              токен monobank (тільки читання)
└── taxmate/                    ← Rails-проєкт
    ├── app/clients/dps/         Dps::Client, Dps::KepSigner, Dps::Error
    ├── app/clients/monobank/    Monobank::Client, Monobank::Error
    ├── lib/kep/sign.js          КЕП-підписувач (jkurwa) — Ruby кличе через shell
    │   └── node_modules/        jkurwa, gost89 (yarn)
    ├── spec/clients/            RSpec на клієнти
    └── docs/                    ця документація
```

## Безпека (обов'язково дотримуватись агенту)

1. **Ніколи не друкувати в чат** вміст `password.txt`, `mono-token.txt`, `pb_*.jks` та base64 підпису/ключа.
   Читати з файлу, не просити текстом.
2. `.jks` + пароль = **повний юридичний підпис власника** (не лише податки — і договори). Не копіювати,
   не завантажувати нікуди, не передавати.
3. Ключ, пароль і токен **не покидають машину**. Підпис локальний. У мережу йде лише результат
   (base64 CMS → `cabinet.tax.gov.ua`; токен → `api.monobank.ua`).
4. **GET-запити безпечні.** Будь-яка **подача** документа чи **оплата** — незворотна дія з юридичними
   наслідками: підтверджувати з власником, показувати, що саме подається/сплачується.
5. Ліміти: ДПС ~1000/добу; monobank — виписка 1 запит/60с, діапазон ≤31 день.

## Гігієна секретів

- Секрети лежать у `~/Documents/taxmate/` (поза Rails-проєктом) — тож `.gitignore` Rails-проєкту їх і так
  не бачить. Якщо колись покласти секрети всередину — додати їх у `.gitignore`.
- Права доступу: `chmod 600 ../pb_3525511937.jks ../password.txt ../mono-token.txt`.
- Клієнти приймають шляхи параметрами — секрети не захардкоджені в коді.

## Обслуговування

- **Протермінування сертифіката** (дата у `05-status-snapshot.md`): перевипустити ключ у Privat24,
  замінити `../pb_3525511937.jks` + `../sign.crt`, оновити `../password.txt`.
- **Токен monobank** протухає — перевипустити на https://api.monobank.ua/ і оновити `../mono-token.txt`.
- **IBAN бюджетних рахунків** змінюються щороку: не хардкодити, брати з `/ta/splatp?year=YYYY`.
- **Оновлення `jkurwa`/`gost89`** (у `lib/kep`): після оновлення перевірити, що ДПС усе ще приймає підпис
  (нагадування: підпис має бути **без signingTime**, див. `04-keys-and-signing.md`).
```
```
