import {Controller} from "@hotwired/stimulus";

import {checkIcon, clipboardIcon} from "../utils/icons";

class ClipboardController extends Controller {
    async copy({ params: { content } }) {
        try {
            await navigator.clipboard.writeText(content)
            this.element.innerHTML = checkIcon
            setTimeout(() => {
                this.element.innerHTML = clipboardIcon
            }, 1000)
        } catch (e) {
            console.error('Failed to copy')
        }
    }
}

export default ClipboardController