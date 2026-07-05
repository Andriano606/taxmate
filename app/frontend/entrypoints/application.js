// TaxMate — головна точка входу Vite.
// Тут вантажимо Turbo, Stimulus, стилі та монтуємо Vue-компоненти як окремі острівці.

// --- Hotwire: Turbo ---
import '@hotwired/turbo';

// --- Стилі (SCSS через Vite) ---
import '../styles/application.scss';

// --- Stimulus ---
import { Application } from '@hotwired/stimulus';
import HelloController from '../controllers/hello_controller';

const stimulus = Application.start();
stimulus.register('hello', HelloController);

// --- Vue як окремі компоненти (islands) ---
// Будь-який елемент з data-vue-component="ІмʼяКомпонента" стає точкою монтування Vue.
import { createApp } from 'vue';
import HelloVue from '../components/HelloVue.vue';

const VUE_COMPONENTS = { HelloVue };

function mountVueComponents() {
  document.querySelectorAll('[data-vue-component]').forEach((el) => {
    if (el.dataset.vueMounted) return;
    const component = VUE_COMPONENTS[el.dataset.vueComponent];
    if (!component) return;
    const props = el.dataset.vueProps ? JSON.parse(el.dataset.vueProps) : {};
    createApp(component, props).mount(el);
    el.dataset.vueMounted = 'true';
  });
}

// Монтуємо і на першому завантаженні, і після Turbo-навігацій.
document.addEventListener('DOMContentLoaded', mountVueComponents);
document.addEventListener('turbo:load', mountVueComponents);
