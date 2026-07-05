<template>
  <div class="hello-vue">
    <p>{{ message }}</p>
    <button type="button" @click="count++">Кліків: {{ count }}</button>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  name: { type: String, default: 'світ' },
});

const count = ref(0);
const message = computed(
  () => `Привіт, ${props.name}! Це окремий Vue-компонент.`,
);
</script>

<style scoped>
.hello-vue {
  padding: 1rem;
  border: 1px dashed #2b6cb0;
  border-radius: 8px;
}
.hello-vue button {
  cursor: pointer;
}
</style>
