import { Controller } from "@hotwired/stimulus"
import { eyeOpenIcon, eyeClosedIcon } from "../utils/icons"
 
class TogglePasswordController extends Controller {
  static targets = ['passwordInput']

  toggle(event) {
    if (this.passwordInputTarget.type === "password") {
      this.passwordInputTarget.type = "text"
      event.currentTarget.innerHTML = eyeOpenIcon
    } else {
      this.passwordInputTarget.type = "password"
      event.currentTarget.innerHTML = eyeClosedIcon
    }
  }
}

export default TogglePasswordController