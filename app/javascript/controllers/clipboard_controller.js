import { Controller } from "@hotwired/stimulus"

const COPIED_HTML = `
<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="inline size-3">
  <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
</svg>
copied
`

export default class extends Controller {
  static values = {
    text: String
  }

  copy(event) {
    event.preventDefault();
    const previousHTML = event.target.innerHTML;

    navigator.clipboard.writeText(this.textValue)
    event.target.innerHTML = COPIED_HTML;

    setTimeout(() => {
      event.target.innerHTML = previousHTML;
    }, 400)
  }
}
