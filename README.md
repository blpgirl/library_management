# Library Management System

Welcome to the Library Management System, a robust backend API built with Ruby on Rails. This system is designed to handle core library operations, including managing books, authors, and genres, as well as user authentication and a full borrowing lifecycle.

---

### Key Features

* **User Management:** Secure user registration and login using **Devise JWT** for authentication. The system supports two user roles: `librarian` and `member`.
* **Role-Based Authorization:** Endpoints are protected to ensure only authorized users can perform specific actions (e.g., only librarians can add or remove books).
* **Book Catalog:** Comprehensive CRUD (Create, Read, Update, Delete) functionality for books, authors, and genres.
* **Soft Deletion:** Records are "soft-deleted" using an `is_active` flag instead of being permanently removed from the database, preserving data integrity.
* **Borrowing & Returns:**
    * **Borrowing:** Members can borrow available books, which automatically decrements the book's available copies.
    * **Returning:** Librarians can mark a book as returned, incrementing the book's available copies.
    * **Cancellation:** Librarians have the ability to cancel an active borrowing.
    * **Validation:** The system prevents users from borrowing a book they have already borrowed, an inactive book, or a book with no available copies.
* **Dashboard Views:** Separate API endpoints provide a tailored dashboard view for both librarians and members, showing relevant information like overdue books or borrowed titles.
* **Comprehensive Testing:** The backend is fully tested using **RSpec** to ensure all functionalities, validations, and unique constraints work as expected.

---

### Project Structure

This project follows a standard Ruby on Rails API structure.

* `app/models`: Contains all the database models, including `User`, `Book`, `Borrowing`, and `Role`. The `Activatable` concern is used for soft deletion.
* `app/controllers`: Houses the API controllers for each resource, handling business logic and authorization.
* `app/services`: Contains service objects like `BookManagerService` and `DashboardService` to encapsulate complex business logic and keep controllers clean.
* `config/routes.rb`: Defines all the API endpoints and authentication routes.
* `db/migrate`: Holds the database migration files for the schema.
* `spec/`: Contains the full RSpec test suite.

---

### Setup and Installation

Follow these steps to get the project running locally.

#### Prerequisites

* Ruby (3.2.2 or higher)
* Rails (7.1.3 or higher)
* A MariaDB or MySQL database server.

#### Backend Setup

1.  **Clone the repository:**
    ```bash
    git clone [repository-url]
    cd [project-folder]
    docker compose up --build
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    ```

3.  **Configure the database:**
    Update the database connection details in `config/database.yml` to match your local setup.

4.  **Create and migrate the database:**
    ```bash
    rails db:create
    rails db:migrate
    ```

5.  **Seed the database:**
    This command populates the database with initial data, including roles (`librarian`, `member`) and a few sample users, authors, genres, and books.
    ```bash
    rails db:seed
    ```

6.  **Start the server:**
    ```bash
    rails s
    ```
    The API will now be running at `http://localhost:3000`.

---

### API Endpoints

Here are the key API endpoints and what they do.

#### Authentication

| Method | Endpoint | Description |
|:-----|:---------------|:------------------------------------------------|
| `POST` | `/signup` | Register a new user with the `member` role. |
| `POST` | `/login` | Authenticate a user and get a JWT token. |
| `DELETE` | `/logout` | Log out a user by revoking their JWT token. |

#### Books

| Method | Endpoint | Authorization | Description |
|:-----|:-------------------|:--------------|:-------------------------------------------------------------------|
| `GET` | `/api/v1/books` | Public | Get all active books. Supports search by title, author, or genre. |
| `GET` | `/api/v1/books/:id` | Public | Get a single book. |
| `POST` | `/api/v1/books` | `librarian` | Create a new book. |
| `PUT` | `/api/v1/books/:id` | `librarian` | Update an existing book. |
| `DELETE` | `/api/v1/books/:id` | `librarian` | Soft delete a book. |

#### Authors & Genres

| Method | Endpoint | Authorization | Description |
|:-----|:-------|:--------------|:----------|
| `GET` | `/api/v1/authors` | `librarian` | List all active authors. |
| `POST` | `/api/v1/authors` | `librarian` | Create a new author. |
| `PUT` | `/api/v1/authors/:id` | `librarian` | Update an author. |
| `DELETE` | `/api/v1/authors/:id` | `librarian` | Soft delete an author. |
| `GET` | `/api/v1/genres` | `librarian` | List all active genres. |
| `POST` | `/api/v1/genres` | `librarian` | Create a new genre. |
| `PUT` | `/api/v1/genres/:id` | `librarian` | Update a genre. |
| `DELETE` | `/api/v1/genres/:id` | `librarian` | Soft delete a genre. |

#### Borrowings

| Method | Endpoint | Authorization | Description |
|:-----|:-------------------|:--------------|:----------------------------------------------------------------------|
| `GET` | `/api/v1/borrowings` | `librarian` | List all borrowing records. |
| `POST` | `/api/v1/borrowings` | `member` | Create a new borrowing. Requires `book_id` in the request body. |
| `PUT` | `/api/v1/borrowings/:id` | `librarian` | Mark a book as returned. |
| `PUT` | `/api/v1/borrowings/:id/cancel` | `librarian` | Cancel an active borrowing. |

#### Dashboards

| Method | Endpoint | Authorization | Description |
|:-----|:---------------------------|:--------------|:------------------------------------------------|
| `GET` | `/api/v1/dashboards/librarian` | `librarian` | Get an overview of overdue books and other library stats. |
| `GET` | `/api/v1/dashboards/member` | `member` | Get a list of the user's borrowed books and overdue titles. |

---

### Running the Test Suite

The project includes a full RSpec test suite to ensure code quality and functionality.

To run all the tests, use the following command:

```bash
rspec
```

The tests cover:
* **Model Validations:** Ensures all models, including `User`, `Book`, `Author`, `Genre`, and `Borrowing`, have the correct validations and unique constraints.
* **CRUD Operations:** Verifies that all API endpoints for books, authors, and genres behave as expected.
* **Borrowing Logic:** Confirms that a `Borrowing` record is correctly created, updated, and canceled. Crucially, tests are in place to prevent a user from borrowing a book that is **inactive** or has **no available copies**.
* **Authentication & Authorization:** Validates that only users with the correct roles can access protected endpoints.
