import { Controller } from "@hotwired/stimulus";

import { eyeOpenIcon, eyeCloseIcon } from "../utils/icons";

class TogglePasswordController extends Controller {
    static targets = ['input']
    toggle (event) {
        if (this.inputTarget.type == 'password') {
            this.inputTarget.type = 'text'
            event.currentTarget.innerHTML = eyeCloseIcon
        }
        else {
            this.inputTarget.type = 'password'
            event.currentTarget.innerHTML = eyeOpenIcon
        }
    }
}

export default TogglePasswordController