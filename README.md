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


### Prompt used

Prompt: I need your help developing a web application for a library management system with the requirements described in the next section. Read carefully all the requirements and create a product that fits the expectations. Your development should be driven by an informal user story that you will create, and which should be included in your presentation as mentioned on the tasks below.

Tasks:
1. Make an UML model of the database according to the requirements
2. Choose a monolithic architecture with api only backend and frontend separate. Use best coding practices for it.
3. Develop the code in Ruby on Rails for backend and React for front end with the tests to run in Rspec for all the functionalities on the requirements. Include a README with setup instructions and any other documentation you deem necessary. Also, the application should have seeded data / credentials for demo purposes. Make sure to stick to the principles below. Make the application with a minimalist but modern design with nice css presentation and user friendly. Create the dashboards really visual so it´s easy to read all the data but try to keep it with standard libraries like bootstrap or something that is visually beautiful and also has lots of support and documentation and lets you interact with it.
   
#### Requirements:
* **Backend**
	* Authentication and Authorization:
		* Users should be able to register, log in, and log out.
		* Two types of users: Librarian and Member.
		* Only Librarian users should be able to add, edit, or delete books.
		
	* Book Management:
		* Ability to add a new book with details like title, author, genre, ISBN, and total
		copies.
		* Ability to edit and delete book details.
		* Search functionality:
			* Users should be able to search for a book by title, author, or genre.

	* Borrowing and Returning:
		* Member users should be able to borrow a book if it's available. They can't borrow
		the same book multiple times.
		* The system should track when a book was borrowed and when it's due (2
		weeks from the borrowing date).
		* Librarian users can mark a book as returned.
		
	* Dashboard:		
		* Librarian:
			* A dashboard showing total books, total borrowed books, books due today,
			and a list of members with overdue books.
		* Member:
			* A dashboard showing books they've borrowed, their due dates, and any
			overdue books.

* **API Endpoints:**
	* Develop a RESTful API that allows CRUD operations for books and borrowings.
	* Ensure proper status codes and responses for each endpoint.
	* Testing should be done with RSPEC.
	* Spec files should be included for all the requirements above.

Principles: 
* Clean Architecture: Your architecture should adhere to Clean Architecture principles,
including separation of concerns and independence of components.
* Application testing: Your project should have sufficient test coverage. Use of TDD is
preferable.
* Code quality: Your code should be well-organized, readable, and adhere to best
practices.
* Functionality: Your application should perform as expected in the requirements without
errors or bugs. Optional but desired: no warnings in the browser console.

-----------------------------------

After which I began iterating over the main idea
