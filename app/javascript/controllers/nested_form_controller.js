import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template"]

  connect() {
    console.log("Nested Form Controller Connected!", this.element);
  }

  add(event) {
    console.log("Add action triggered by:", event.currentTarget);
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
    
    // Log del template decodificato
    console.log("Template decodificato:", decodedHtml);
    console.log("Nuovo indice:", newIndex);
    console.log("Campi generati:", newFields);
    
    // Inserisci il nuovo campo prima del pulsante "Aggiungi"
    const addButton = container.querySelector('[data-action="nested-form#add"]');
    if (addButton) {
      addButton.insertAdjacentHTML('beforebegin', newFields);
    } else {
      container.insertAdjacentHTML('beforeend', newFields);
    }
  }

  remove(event) {
    console.log("Remove action triggered by:", event.currentTarget);
    const wrapper = event.currentTarget.closest('.mealfood-fields');
    
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove();
    } else {
      wrapper.style.display = 'none';
      wrapper.querySelector("input[name*='_destroy']").value = 1;
    }
  }
} 