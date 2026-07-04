# TaxMate (Rails)

Rails 8.1 + Ruby 3.4.8 застосунок. Порожній старт із Hello World, налаштований під повний стек.

## Стек

| Область | Технологія |
|---|---|
| Backend | Ruby 3.4.8, Rails 8.1 |
| БД | PostgreSQL 18 |
| Фронтенд-збірка | **Vite** (`vite_rails`) |
| JS | **Vue 3** (окремі компоненти), **Stimulus**, **Turbo** (Hotwire) |
| Стилі | **SCSS** (через Vite) |
| Фонові задачі | **Solid Queue** + панель **Mission Control** (`/jobs`) |
| Сховище файлів | Active Storage → **MinIO** (S3-сумісне) |
| Локалізація | **I18n** (en, uk) |
| Тести | **RSpec** + **Cucumber** (Capybara) |
| Деплой | **Kamal** (`config/deploy.yml`) |

## Запуск (розробка)

```bash
# 1. Залежності (Postgres на :5435, MinIO на :9002 / консоль :9003)
docker compose up -d

# 2. Гем/JS-залежності та БД
bin/setup            # або: bundle install && npm install && bin/rails db:prepare

# 3. Запустити застосунок (Rails + Vite разом)
bin/dev
```

Відкрий http://localhost:3000 — сторінка Hello World демонструє Turbo (лінивий frame),
Stimulus (кнопка) і Vue-компонент. Перемикання мови: `/?locale=uk`.

- Панель фонових задач: http://localhost:3000/jobs
- MinIO-консоль: http://localhost:9003 (taxmate / taxmate123)

## Тести

```bash
bundle exec rspec       # request/unit специфікації
bundle exec cucumber    # приймальні сценарії (features/)
```

## Структура фронтенду (Vite)

```
app/frontend/
├── entrypoints/application.js   # точка входу: Turbo, Stimulus, Vue-острівці, стилі
├── controllers/hello_controller.js   # Stimulus
├── components/HelloVue.vue           # Vue-компонент
└── styles/application.scss           # SCSS
```

Vue монтується як «острівці»: будь-який елемент з `data-vue-component="HelloVue"` стає
точкою монтування (див. `entrypoints/application.js`).

## Порти (нестандартні — щоб не конфліктувати з іншими проєктами на машині)

| Сервіс | Порт |
|---|---|
| Postgres | localhost:**5435** |
| MinIO S3 API | localhost:**9002** |
| MinIO консоль | localhost:**9003** |

## Деплой (Kamal)

`config/deploy.yml` містить web-сервіс і accessories **postgres** + **minio**.
Перед деплоєм заповни: `servers`, `registry`, IP-адреси accessories та секрети в
`.kamal/secrets` (`TAXMATE_DATABASE_PASSWORD`, `MINIO_SECRET_KEY`). Тоді:

```bash
bin/kamal setup     # перший раз
bin/kamal deploy    # наступні викати
```
