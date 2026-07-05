import { Controller } from '@hotwired/stimulus';

// Демо Stimulus-контролер: за кліком пише привітання у ціль.
export default class extends Controller {
  static targets = ['output'];
  static values = { name: { type: String, default: 'світ' } };

  greet() {
    this.outputTarget.textContent = `Привіт, ${this.nameValue}! (Stimulus)`;
  }
}
