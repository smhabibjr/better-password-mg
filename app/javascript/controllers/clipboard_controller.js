import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"
import { checkIcon, clipboardIcon } from "../utils/icons"

class ClipboardController extends Controller {

  async copy({ params: { content } }) {
    const toastEl = document.getElementById("clipboard-toast")
    const toast = toastEl ? bootstrap.Toast.getOrCreateInstance(toastEl) : null

    try {
      await navigator.clipboard.writeText(content);
      this.element.innerHTML = checkIcon;
      setTimeout(() => {
        this.element.innerHTML = clipboardIcon;
      }, 2000);
      toast?.show()
    } catch (error) {
      toast?.show()
    }
  } 
}

export default ClipboardController;