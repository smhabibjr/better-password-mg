# Ruby on Rails — Learning Notes (BetterPassApp)

A personal reference of everything learned while building **BetterPassApp** in Ruby on Rails. Each section answers: *What is it? Why use it? How to define and use it?*

---

## Table of Contents

1. [Routing — Defining Pages](#1-routing--defining-pages)
2. [Devise — User Authentication](#2-devise--user-authentication)
3. [ApplicationHelper — Logo Helper](#3-applicationhelper--logo-helper)
4. [Flash Messages with Toast Notifications](#4-flash-messages-with-toast-notifications)
5. [Form Validation Error Styling](#5-form-validation-error-styling)
6. [Custom Boolean Helper — `account_page?`](#6-custom-boolean-helper--account_page)
7. [Conditional Rendering in Views](#7-conditional-rendering-in-views)
8. [Model — Generator, Migrations & Cheatsheet](#8-model--generator-migrations--cheatsheet)
9. [Routing — `resources` Cheatsheet](#9-routing--resources-cheatsheet)
10. [Table Relationships](#10-table-relationships)
11. [Controller & View](#11-controller--view)
12. [ActiveRecord Validations](#12-activerecord-validations)
13. [ActiveRecord Encryption](#13-activerecord-encryption)

---

## 1. Routing — Defining Pages

### What is it?
Routes map incoming URLs to controller actions. Defined in `config/routes.rb`.

### Purpose
Tell Rails: *"When a user visits this URL, run this controller action."*

### Code
```ruby
# config/routes.rb
get "home",  to: "pages#home"
get "about", to: "pages#about"
root "pages#home"
```

### Breakdown
| Line | Meaning |
|------|---------|
| `get "home", to: "pages#home"` | HTTP GET `/home` → `PagesController#home` action |
| `get "about", to: "pages#about"` | HTTP GET `/about` → `PagesController#about` action |
| `root "pages#home"` | The root URL `/` loads `PagesController#home` |

### Usage
- `root_path` → returns `/`
- `home_path` → returns `/home`
- `about_path` → returns `/about`

---

## 2. Devise — User Authentication

### What is it?
Devise is a Rails gem that provides a full authentication system out of the box (sign up, sign in, sign out, password reset, etc.).

### Purpose
Add user login/registration to your app without writing auth logic from scratch.

### Installation
```ruby
# Gemfile
gem "devise"
```
```bash
rails generate devise:install
rails generate devise User
rails db:migrate
```

### Custom Path
```ruby
# config/routes.rb
devise_for :users, path: "secure"
```

This mounts all Devise routes under `/secure` instead of the default `/users`:

| Default | Custom |
|---------|--------|
| `/users/sign_in` | `/secure/sign_in` |
| `/users/sign_up` | `/secure/sign_up` |
| `/users/sign_out` | `/secure/sign_out` |

### Usage in Views
```erb
<%= link_to "Sign In", new_user_session_path %>
<%= link_to "Sign Out", destroy_user_session_path, data: { turbo_method: :delete } %>
```

---

## 3. ApplicationHelper — Logo Helper

### What is it?
A **helper** is a Ruby module that provides reusable methods you can call inside your views. `ApplicationHelper` is available across all views by default.

### Purpose
Extract repeated or complex view logic into a clean, reusable method — in this case, rendering a logo link.

### Definition
```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def logo(size = 'h2')
    link_to(root_path, class: "logo #{size}") do
      '<i class="bi bi-safe-fill me-2"></i> BetterPass'.html_safe
    end
  end
end
```

### Breakdown
| Part | Meaning |
|------|---------|
| `size = 'h2'` | Default argument — uses `h2` unless you pass something else |
| `link_to(root_path, ...)` | Generates an `<a>` tag pointing to `/` |
| `class: "logo #{size}"` | Adds dynamic CSS classes like `logo h2` or `logo h4` |
| `.html_safe` | Tells Rails not to escape the HTML string |

### Usage in Views
```erb
<!-- With default size (h2) -->
<%= logo %>

<!-- With custom size -->
<div class="container">
  <%= logo('h4') %>
</div>
```

**Renders:**
```html
<a href="/" class="logo h4">
  <i class="bi bi-safe-fill me-2"></i> BetterPass
</a>
```

---

## 4. Flash Messages with Toast Notifications

### What is it?
Flash messages are one-time messages set by controllers (e.g., "Successfully signed in" or "Invalid password"). This pattern renders them as animated Bootstrap Toast popups.

### Purpose
Show user-friendly feedback notifications that automatically disappear, without cluttering your page layout.

### Parts Involved

#### A) Flash Helper — Map type to Bootstrap color
```ruby
# app/helpers/flash_helper.rb
module FlashHelper
  def flash_class(type)
    case type
    when "notice" then "success"
    when "alert"  then "danger"
    end
  end
end
```
Maps Devise flash types (`notice`, `alert`) to Bootstrap color classes (`success`, `danger`).

#### B) Flash Partial — The Toast HTML
```erb
<%# app/views/shared/_flash.html.erb %>
<% flash.each do |type, message| %>
  <div class="toast align-items-center text-bg-<%= flash_class(type) %> border-0 position-absolute top-0 end-0 z-1 mt-5 me-5"
       role="alert"
       aria-live="assertive"
       aria-atomic="true"
       data-controller="toast">
    <div class="d-flex">
      <div class="toast-body">
        <%= message %>
      </div>
      <button type="button"
              class="btn-close btn-close-white me-2 m-auto"
              data-bs-dismiss="toast"
              aria-label="Close">
      </button>
    </div>
  </div>
<% end %>
```

#### C) Layout — Render the partial
```erb
<%# app/views/layouts/devise.html.erb %>
<div class="vh-100">
  <%= render "shared/flash" %>
  ...
</div>
```

#### D) Stimulus Controller — Auto-show the Toast
```javascript
// app/javascript/controllers/toast_controller.js
import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() {
    const toast = bootstrap.Toast.getOrCreateInstance(this.element)
    toast.show()
  }
}
```
The `data-controller="toast"` attribute on the div automatically triggers `connect()` when the element appears in the DOM, showing the toast.

### How It All Works Together
```
Controller sets flash["notice"] = "Welcome!"
       ↓
Layout renders shared/_flash partial
       ↓
Flash helper converts "notice" → "success" (Bootstrap class)
       ↓
Stimulus `connect()` fires → Bootstrap Toast shows
       ↓
Toast auto-dismisses or user clicks ✕
```

---

## 5. Form Validation Error Styling

### What is it?
By default, Rails wraps invalid form fields with a `<div class="field_with_errors">` which can break your layout. This customizes that behavior to instead add a CSS class directly to the input.

### Purpose
Apply your own error styling class (`input-with-errors`) to inputs without the extra wrapper div breaking your Bootstrap/CSS layout.

### Definition
```ruby
# config/initializers/form_validation_errors.rb
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  match = html_tag.to_s.match(/class\s*=\s*"([^"]*)"/)
  if html_tag.start_with?("<label")
    html_tag.html_safe
  else
    html_tag.to_s.gsub(match[0], "class=\"#{match[1]} input-with-errors\"").html_safe
  end
end
```

### Breakdown
| Part | Meaning |
|------|---------|
| `field_error_proc` | A Rails hook — called for every field with a validation error |
| `html_tag` | The generated HTML string for that field (e.g., `<input class="form-control">`) |
| `match` | Extracts the existing `class="..."` attribute using Regex |
| `html_tag.start_with?("<label")` | Skip labels — only style inputs |
| `.gsub(match[0], ...)` | Replace old class with old class + `input-with-errors` |
| `.html_safe` | Mark the modified string as safe to render |

### Result
Before (Rails default):
```html
<div class="field_with_errors">
  <input class="form-control" type="email">
</div>
```

After (with customization):
```html
<input class="form-control input-with-errors" type="email">
```

### CSS to Style It
```css
.input-with-errors {
  border-color: red;
}
```

---

## 6. Custom Boolean Helper — `account_page?`

### What is it?
A helper method that returns `true` or `false` based on the current page. The `?` at the end is a Ruby convention for methods that return a boolean.

### Purpose
Avoid repeating page-detection logic across views. Use it to show/hide elements depending on which page the user is on.

### Definition
```ruby
# app/helpers/application_helper.rb
def account_page?
  current_page?(edit_user_registration_path)
end
```

| Part | Meaning |
|------|---------|
| `current_page?(path)` | Rails helper — returns `true` if the current URL matches `path` |
| `edit_user_registration_path` | Devise path for the account/edit page (`/secure/edit`) |
| `?` suffix | Ruby convention — signals this method returns `true`/`false` |

### Usage
```erb
<%= render "shared/navbar" if account_page? %>
```

---

## 7. Conditional Rendering in Views

### What is it?
Showing or hiding HTML blocks in ERB templates based on a condition, using `if` and `unless`.

### Purpose
Render different UI depending on context — e.g., hide the logo on the account page, show the navbar only when needed.

### `if` — render when condition is true
```erb
<%= render "shared/navbar" if account_page? %>
```
The navbar only appears on the account/edit page.

### `unless` — render when condition is false
```erb
<% unless account_page? %>
  <%= logo %>
<% end %>
```
The logo appears on every page *except* the account page.

### Full Example (from layout)
```erb
<%= render partial: "shared/flash" %>
<%= render partial: "shared/navbar" if account_page? %>

<div class="h-100 container d-flex flex-column justify-content-center align-items-center">
  <% unless account_page? %>
    <%= logo %>
  <% end %>
</div>
```

| Condition | `account_page?` = true | `account_page?` = false |
|-----------|----------------------|------------------------|
| Flash | ✅ always shown | ✅ always shown |
| Navbar | ✅ shown | ❌ hidden |
| Logo | ❌ hidden | ✅ shown |

---

## 8. Model — Generator, Migrations & Cheatsheet

### Generator Command
```bash
rails g model Entry name:string url:string username:string password user:belongs_to
```

**Key naming rules:**
- Model name → **singular + capitalized** → `Entry`
- Controller name → **plural** → `EntriesController`
- Default data type is `string` — `name` alone means `name:string`

### What gets generated
| File | Purpose |
|------|---------|
| `app/models/entry.rb` | Model class |
| `db/migrate/..._create_entries.rb` | Migration file |

### Run the migration
```bash
rails db:migrate
```
This updates `db/schema.rb` automatically every time you run it.

### Migration Cheatsheet
```ruby
# Common data types
name:string        # short text (255 chars)
bio:text           # long text
age:integer
price:decimal
active:boolean
birthday:date
created_at:datetime
photo:binary       # file data
user:belongs_to    # adds user_id integer column + foreign key + index
```

### Model Cheatsheet
```ruby
# Generate
rails g model Post title body:text user:belongs_to

# Destroy (undo generate)
rails destroy model Post

# Migrate
rails db:migrate

# Rollback last migration
rails db:rollback

# Check migration status
rails db:migrate:status

# Open Rails console to test model
rails console
Entry.all           # all records
Entry.first         # first record
Entry.count         # total count
Entry.find(1)       # find by id
Entry.where(name: "Gmail")  # filter
```

---

## 9. Routing — `resources` Cheatsheet

### What is it?
`resources` generates all 7 standard RESTful routes for a resource in one line.

```ruby
# config/routes.rb
resources :entries
```

### All 7 routes generated
| Helper | Verb | Path | Controller#Action | Purpose |
|--------|------|------|-------------------|---------|
| `entries_path` | GET | `/entries` | `entries#index` | List all |
| `entries_path` | POST | `/entries` | `entries#create` | Save new |
| `new_entry_path` | GET | `/entries/new` | `entries#new` | Show new form |
| `edit_entry_path(id)` | GET | `/entries/:id/edit` | `entries#edit` | Show edit form |
| `entry_path(id)` | GET | `/entries/:id` | `entries#show` | Show one |
| `entry_path(id)` | PATCH/PUT | `/entries/:id` | `entries#update` | Save edit |
| `entry_path(id)` | DELETE | `/entries/:id` | `entries#destroy` | Delete |

### Why do two routes share `/entries`?
```
GET  /entries  →  entries#index   (read — show the list)
POST /entries  →  entries#create  (write — save a new entry)
```
The **HTTP verb** (GET vs POST) determines which action runs, not the path. Same URL, different intent.

### Useful options
```ruby
# Custom URL path
resources :entries, path: "diary"
# → /diary, /diary/new, /diary/:id etc.

# Exclude specific actions
resources :entries, except: [:destroy]
resources :entries, except: [:index, :show]

# Only specific actions
resources :entries, only: [:index, :new, :create]

# Combined example
resources :entries, path: "diary", except: [:destroy]
# All 6 routes (no delete) but under /diary/... URL
```

### Nested resources
```ruby
resources :users do
  resources :entries  # /users/:user_id/entries
end
```

### Check all routes
```bash
rails routes
rails routes | grep entries   # filter by name
```

---

## 10. Table Relationships

### What is it?
Associations tell Rails how models relate to each other so you can query across tables easily.

### One-to-Many (most common)
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :entries, dependent: :destroy
end

# app/models/entry.rb
class Entry < ApplicationRecord
  belongs_to :user
end
```

| Part | Meaning |
|------|---------|
| `has_many :entries` | A user can have many entries |
| `belongs_to :user` | Each entry must belong to one user |
| `dependent: :destroy` | If user is deleted, all their entries are deleted too |

### Usage
```ruby
user.entries          # all entries for a user
user.entries.count    # count entries
user.entries.new      # build a new entry for this user
entry.user            # the user who owns this entry
```

### Migration creates `user_id` column
```bash
rails g model Entry name user:belongs_to
# Adds: t.belongs_to :user, null: false, foreign_key: true
# = adds user_id integer column + index
```

---

## 11. Controller & View

### Generate a controller
```bash
rails g controller ControllerName action1 action2
# Example:
rails g controller Entries index new create show edit update
```
Creates: `app/controllers/entries_controller.rb` + view files.

### Inspect an object in view (debugging)
```erb
<%= @entry.inspect %>
```
Prints the raw object data — useful for debugging. Remove before going to production.

### `form_with` — Rails form helper
```erb
<%= form_with(model: @entry) do |form| %>
  <%= form.text_field :name, class: "form-control" %>
  <%= form.submit "Save", class: "btn btn-primary" %>
<% end %>
```
- Rails auto-detects: new record → POST `/entries`, existing → PATCH `/entries/:id`
- `model: @entry` binds the form to the model for error display and value pre-filling

### Create action pattern
```ruby
def create
  # current_user comes from Devise — the logged-in user
  # .new builds a record associated with that user
  @entry = current_user.entries.new(entry_params)

  if @entry.save
    flash[:notice] = "Entry created successfully."
    redirect_to root_path
  else
    flash[:alert] = "Failed to create entry."
    render :new, status: :unprocessable_entity
  end
end

private

def entry_params
  # Rails 8+ simplified strong parameters
  params.expect(entry: [:name, :url, :username, :password])
  # Rails 7 and below:
  # params.require(:entry).permit(:name, :url, :username, :password)
end
```

| Part | Meaning |
|------|---------|
| `current_user` | Devise helper — returns the logged-in user object |
| `current_user.entries.new` | Builds entry pre-associated with this user |
| `@entry.save` | Returns `true` if saved, `false` if validation fails |
| `render :new, status: :unprocessable_entity` | Re-renders form with errors (422 status) |
| `params.expect` | Rails 8 strong params — whitelist allowed fields |

---

## 12. ActiveRecord Validations

> 📖 Full docs: https://guides.rubyonrails.org/active_record_validations.html

### Purpose
Prevent bad/incomplete data from being saved to the database.

### Built-in validations
```ruby
# app/models/entry.rb
class Entry < ApplicationRecord
  # Presence — field must not be blank
  validates :name, :url, :username, :password, presence: true

  # Length
  validates :name, length: { minimum: 2, maximum: 100 }

  # Uniqueness
  validates :username, uniqueness: true

  # Format (regex)
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

### Custom validation
```ruby
validate :url_must_be_valid

private

def url_must_be_valid
  uri = URI.parse(url)
  unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    errors.add(:url, "must be a valid HTTP or HTTPS URL")
  end
rescue URI::InvalidURIError
  errors.add(:url, "must be a valid URL")
end
```
- `validate` (not `validates`) — calls a custom method
- `errors.add(:field, "message")` — adds an error to a specific field

### Display errors in view
```erb
<% if @entry.errors.any? %>
  <div class="alert alert-danger">
    <h6>Please fix the <%= pluralize(@entry.errors.count, 'error') %> below:</h6>
    <ul>
      <% @entry.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

| Helper | Output example |
|--------|----------------|
| `@entry.errors.count` | `2` |
| `pluralize(2, 'error')` | `"2 errors"` |
| `error.full_message` | `"Name can't be blank"` |
| `@entry.errors.any?` | `true` if any errors exist |

---

## 13. ActiveRecord Encryption

> 📖 Full docs: https://guides.rubyonrails.org/active_record_encryption.html

### Purpose
Encrypt sensitive fields (passwords, usernames, tokens) in the database so they're unreadable if the DB is compromised.

### Step 1 — Generate encryption keys
```bash
bin/rails db:encryption:init
```
Outputs three keys — copy them into your credentials file.

### Step 2 — Add keys to credentials
```bash
# VS Code
EDITOR="code --wait" bin/rails credentials:edit
```
Paste the output from step 1 inside the credentials file.

### Step 3 — Declare encrypted fields in model
```ruby
# app/models/entry.rb
class Entry < ApplicationRecord
  encrypts :username, deterministic: true
  encrypts :password
end
```

| Option | Meaning |
|--------|---------|
| `encrypts :password` | Encrypted — different ciphertext each time. Cannot query by value. |
| `deterministic: true` | Same input → same ciphertext. Allows `where(username: "...")` queries. |

### When to use which
- `deterministic: true` → fields you need to **search/query** (username, email)
- Without it → fields you only **read back** (password, secret tokens) — more secure

---

*Last updated: BetterPassApp — ongoing learning notes.*