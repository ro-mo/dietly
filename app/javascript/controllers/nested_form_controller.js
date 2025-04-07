import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Nested Form Controller Connected!", this.element);
  }

  add(event) {
    console.log("Add action triggered by:", event.currentTarget);
    event.preventDefault();

    const button = event.currentTarget;
    const templateHtml = button.dataset.templateHtml;

    if (!templateHtml) {
      console.error("Template HTML non trovato nel data attribute del bottone.");
      return;
    }

    const mealContainer = button.closest('.border');
    const container = mealContainer ? mealContainer.querySelector('.mealfoods-container') : null;

    if (!container) {
      console.error("Contenitore .mealfoods-container non trovato.");
      return;
    }

    const decodedHtml = decodeURIComponent(templateHtml.replace(/\+/g, ' '));
    const newIndex = new Date().getTime();
    const newFields = decodedHtml.replace(/NEW_RECORD/g, newIndex);
    container.insertAdjacentHTML('beforeend', newFields);
  }

  remove(event) {
    console.log("Remove action triggered by:", event.currentTarget);
    event.preventDefault();

    const button = event.currentTarget;
    const wrapper = button.closest('.mealfood-fields');

    if (!wrapper) {
      console.error("Wrapper .mealfood-fields non trovato.");
      return;
    }

    const destroyField = wrapper.querySelector("input[type='hidden'][name*='_destroy']");

    if (destroyField) {
      destroyField.value = '1';
      wrapper.style.display = 'none';
      // wrapper.classList.add('opacity-50', 'pointer-events-none');
    } else {
      wrapper.remove();
    }
  }
} 