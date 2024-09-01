import { Application } from "@hotwired/stimulus"

const application = Application.start()

import { Dropdown, Toggle } from "tailwindcss-stimulus-components"
application.register('dropdown', Dropdown)
application.register('toggle', Toggle)


// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
