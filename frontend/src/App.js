import React, { createContext, useState, useEffect, useContext } from 'react';
import { createHashRouter, RouterProvider, useNavigate, Outlet } from 'react-router-dom';
import {
  Book,
  User,
  LogOut,
  LayoutDashboard,
  Plus,
  BookOpen,
  Edit,
  Trash2,
  Calendar,
  AlertCircle,
  XCircle,
  BadgeInfo,
  CircleCheck,
  Search,
  CheckCircle2,
  Ban,
  User2,
} from 'lucide-react';

// API configuration using an environment variable with a fallback
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000';

// Global context for authentication
export const AuthContext = createContext();

// Centralized API functions
const api = {
  // Authentication
  login: (email, password) =>
    fetch(`${API_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    }).then(res => res.json()),

  register: (name, email, password) =>
    fetch(`${API_URL}/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user: { name, email, password } }),
    }).then(res => res.json()),

  // Books
  getBooks: (query = '') =>
    fetch(`${API_URL}/api/v1/books?query=${query}`).then(res => res.json()),

  createBook: (bookData, token) =>
    fetch(`${API_URL}/api/v1/books`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
      body: JSON.stringify({ book: bookData }),
    }).then(res => res.json()),

  updateBook: (bookId, bookData, token) =>
    fetch(`${API_URL}/api/v1/books/${bookId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
      body: JSON.stringify({ book: bookData }),
    }).then(res => res.json()),

  deleteBook: (bookId, token) =>
    fetch(`${API_URL}/api/v1/books/${bookId}`, {
      method: 'DELETE',
      headers: { Authorization: token },
    }).then(res => res.json()),

  // Borrowings
  borrowBook: (bookId, token) =>
    fetch(`${API_URL}/api/v1/borrowings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
      body: JSON.stringify({ book_id: bookId }),
    }).then(res => res.json()),

  returnBook: (borrowingId, token) =>
    fetch(`${API_URL}/api/v1/borrowings/${borrowingId}`, {
      method: 'PUT',
      headers: { Authorization: token },
    }).then(res => res.json()),

  cancelBorrowing: (borrowingId, token) =>
    fetch(`${API_URL}/api/v1/borrowings/${borrowingId}/cancel`, {
      method: 'PUT',
      headers: { Authorization: token },
    }).then(res => res.json()),

  getBorrowings: token =>
    fetch(`${API_URL}/api/v1/borrowings`, {
      headers: { Authorization: token },
    }).then(res => res.json()),

  // Dashboards
  getLibrarianDashboard: token =>
    fetch(`${API_URL}/api/v1/dashboards/librarian`, {
      headers: { Authorization: token },
    }).then(res => res.json()),

  getMemberDashboard: token =>
    fetch(`${API_URL}/api/v1/dashboards/member`, {
      headers: { Authorization: token },
    }).then(res => res.json()),
};

// Main App component
function App() {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem('token'));

  useEffect(() => {
    // Check if a token exists in local storage on initial load
    if (token) {
      // Decode token to get user data (or make a validation request)
      // For this example, we'll assume the user is valid if a token exists
      // In a real app, you would validate the token with an API call
    }
  }, [token]);

  const authContextValue = {
    user,
    setUser,
    token,
    setToken,
    logout: () => {
      localStorage.removeItem('token');
      setToken(null);
      setUser(null);
    },
  };

  return (
    <AuthContext.Provider value={authContextValue}>
      <RouterProvider router={router} />
    </AuthContext.Provider>
  );
}

// Components and Pages
const Header = () => {
  const { user, logout } = useContext(AuthContext);
  const navigate = useNavigate();

  return (
    <header className="bg-white shadow-md">
      <div className="container mx-auto flex items-center justify-between p-4">
        <div className="flex items-center space-x-2">
          <BookOpen className="h-8 w-8 text-indigo-600" />
          <h1 className="text-2xl font-bold text-gray-800">LMS</h1>
        </div>
        <nav className="flex items-center space-x-4">
          {user ? (
            <>
              <button
                onClick={() => navigate(user.role === 'librarian' ? '/librarian/dashboard' : '/member/dashboard')}
                className="flex items-center space-x-1 text-gray-600 hover:text-indigo-600 transition-colors"
              >
                <LayoutDashboard className="h-5 w-5" />
                <span>Dashboard</span>
              </button>
              <button
                onClick={() => navigate('/books')}
                className="flex items-center space-x-1 text-gray-600 hover:text-indigo-600 transition-colors"
              >
                <Book className="h-5 w-5" />
                <span>Books</span>
              </button>
              <button
                onClick={logout}
                className="flex items-center space-x-1 text-gray-600 hover:text-indigo-600 transition-colors"
              >
                <LogOut className="h-5 w-5" />
                <span>Logout</span>
              </button>
            </>
          ) : (
            <>
              <button
                onClick={() => navigate('/login')}
                className="flex items-center space-x-1 text-gray-600 hover:text-indigo-600 transition-colors"
              >
                <User className="h-5 w-5" />
                <span>Login</span>
              </button>
              <button
                onClick={() => navigate('/register')}
                className="flex items-center space-x-1 text-gray-600 hover:text-indigo-600 transition-colors"
              >
                <User className="h-5 w-5" />
                <span>Register</span>
              </button>
            </>
          )}
        </nav>
      </div>
    </header>
  );
};

// Root layout component that wraps all pages
const Root = () => (
  <div className="min-h-screen bg-gray-100 font-sans">
    <Header />
    <main className="container mx-auto p-4">
      <Outlet />
    </main>
  </div>
);

const BookCard = ({ book, onBorrow, onEdit, onDelete }) => {
  const { user } = useContext(AuthContext);
  const isLibrarian = user?.role === 'librarian';

  return (
    <div className="bg-white rounded-xl shadow-lg p-6 flex flex-col space-y-4 transition-transform transform hover:scale-105">
      <div className="flex-grow">
        <h3 className="text-xl font-bold text-gray-800">{book.title}</h3>
        <p className="text-gray-600 italic">by {book.author}</p>
        <p className="mt-2 text-gray-700">Genre: {book.genre}</p>
        <div className="mt-4 flex items-center justify-between text-sm">
          <div className="flex items-center space-x-2">
            <BadgeInfo className="h-4 w-4 text-gray-500" />
            <span className="text-gray-500">ISBN: {book.isbn}</span>
          </div>
          <div className="flex items-center space-x-2">
            <Book className="h-4 w-4 text-green-500" />
            <span className="text-green-600 font-semibold">Available: {book.available_copies} / {book.total_copies}</span>
          </div>
        </div>
      </div>
      <div className="flex space-x-2 mt-4">
        {isLibrarian ? (
          <>
            <button
              onClick={() => onEdit(book)}
              className="flex-1 bg-indigo-500 text-white py-2 px-4 rounded-lg font-semibold hover:bg-indigo-600 transition-colors flex items-center justify-center space-x-2"
            >
              <Edit className="h-4 w-4" />
              <span>Edit</span>
            </button>
            <button
              onClick={() => onDelete(book.id)}
              className="flex-1 bg-red-500 text-white py-2 px-4 rounded-lg font-semibold hover:bg-red-600 transition-colors flex items-center justify-center space-x-2"
            >
              <Trash2 className="h-4 w-4" />
              <span>Delete</span>
            </button>
          </>
        ) : (
          <button
            onClick={() => onBorrow(book.id)}
            className="flex-1 bg-green-500 text-white py-2 px-4 rounded-lg font-semibold hover:bg-green-600 transition-colors disabled:bg-gray-400"
            disabled={book.available_copies <= 0}
          >
            Borrow
          </button>
        )}
      </div>
    </div>
  );
};

const DashboardCard = ({ title, value, iconName }) => {
  // Correctly render the icon component using JSX syntax
  const Icon = iconName;
  return (
    <div className="bg-white rounded-xl shadow-lg p-6 flex flex-col space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-500">{title}</h3>
        <div className="text-indigo-600">
          <Icon className="h-8 w-8" />
        </div>
      </div>
      <p className="text-4xl font-bold text-gray-800">{value}</p>
    </div>
  );
};

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { setUser, setToken } = useContext(AuthContext);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');

    const res = await api.login(email, password);

    if (res.user && res.token) {
      localStorage.setItem('token', res.token);
      setToken(res.token);
      setUser(res.user);
      navigate(res.user.role === 'librarian' ? '/librarian/dashboard' : '/member/dashboard');
    } else {
      setError(res.error || 'Login failed. Please check your credentials.');
    }
  };

  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-80px)]">
      <div className="bg-white p-8 rounded-xl shadow-lg w-full max-w-md">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-6">Login</h2>
        <form onSubmit={handleLogin} className="space-y-4">
          {error && <div className="bg-red-100 text-red-600 p-3 rounded-lg text-sm text-center">{error}</div>}
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>
          <button
            type="submit"
            className="w-full bg-indigo-600 text-white py-3 rounded-lg font-bold hover:bg-indigo-700 transition-colors"
          >
            Sign In
          </button>
        </form>
        <p className="mt-4 text-center text-gray-600">
          Don't have an account?{' '}
          <a onClick={() => navigate('/register')} className="text-indigo-600 font-semibold hover:underline cursor-pointer">
            Register here
          </a>
        </p>
      </div>
    </div>
  );
};

const Register = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleRegister = async (e) => {
    e.preventDefault();
    setMessage('');
    setError('');

    if (password !== confirmPassword) {
      setError("Passwords don't match.");
      return;
    }

    const res = await api.register(name, email, password);

    if (res.message) {
      setMessage(res.message);
      setTimeout(() => navigate('/login'), 2000);
    } else {
      setError(res.errors ? res.errors.join(', ') : 'Registration failed.');
    }
  };

  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-80px)]">
      <div className="bg-white p-8 rounded-xl shadow-lg w-full max-w-md">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-6">Register</h2>
        <form onSubmit={handleRegister} className="space-y-4">
          {message && <div className="bg-green-100 text-green-600 p-3 rounded-lg text-sm text-center">{message}</div>}
          {error && <div className="bg-red-100 text-red-600 p-3 rounded-lg text-sm text-center">{error}</div>}
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Confirm Password</label>
            <input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>
          <button
            type="submit"
            className="w-full bg-indigo-600 text-white py-3 rounded-lg font-bold hover:bg-indigo-700 transition-colors"
          >
            Register
          </button>
        </form>
        <p className="mt-4 text-center text-gray-600">
          Already have an account?{' '}
          <a onClick={() => navigate('/login')} className="text-indigo-600 font-semibold hover:underline cursor-pointer">
            Login here
          </a>
        </p>
      </div>
    </div>
  );
};

const LibrarianDashboard = () => {
  const { token } = useContext(AuthContext);
  const [dashboardData, setDashboardData] = useState(null);
  const [borrowings, setBorrowings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState({ text: '', type: '' });

  const fetchData = async () => {
    if (token) {
      try {
        const dashboard = await api.getLibrarianDashboard(token);
        const allBorrowings = await api.getBorrowings(token);
        setDashboardData(dashboard);
        setBorrowings(allBorrowings);
        setLoading(false);
      } catch (error) {
        setMessage({ text: 'Failed to fetch dashboard data.', type: 'error' });
        setLoading(false);
      }
    }
  };

  useEffect(() => {
    fetchData();
  }, [token]);

  const handleReturn = async (borrowingId) => {
    try {
      await api.returnBook(borrowingId, token);
      setMessage({ text: 'Book returned successfully!', type: 'success' });
      fetchData(); // Refresh data
    } catch (error) {
      setMessage({ text: 'Failed to return book.', type: 'error' });
    }
  };

  const handleCancel = async (borrowingId) => {
    try {
      await api.cancelBorrowing(borrowingId, token);
      setMessage({ text: 'Borrowing canceled successfully!', type: 'success' });
      fetchData(); // Refresh data
    } catch (error) {
      setMessage({ text: 'Failed to cancel borrowing.', type: 'error' });
    }
  };

  if (loading) {
    return <div className="text-center mt-8 text-gray-600">Loading dashboard...</div>;
  }

  return (
    <div className="space-y-6">
      <h2 className="text-3xl font-bold text-gray-800">Librarian Dashboard</h2>
      {message.text && (
        <div className={`p-4 rounded-lg flex items-center space-x-3 ${message.type === 'success' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
          {message.type === 'success' ? <CircleCheck className="h-5 w-5" /> : <XCircle className="h-5 w-5" />}
          <span>{message.text}</span>
        </div>
      )}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <DashboardCard
          title="Total Books"
          value={dashboardData.total_books}
          iconName={Book}
        />
        <DashboardCard
          title="Borrowed Books"
          value={dashboardData.total_borrowed_books}
          iconName={CircleCheck}
        />
        <DashboardCard
          title="Books Due Today"
          value={dashboardData.books_due_today}
          iconName={Calendar}
        />
      </div>

      <div className="bg-white rounded-xl shadow-lg p-6 mt-8">
        <h3 className="text-2xl font-bold text-gray-800 mb-4">Active Borrowings</h3>
        <ul className="divide-y divide-gray-200">
          {borrowings.length > 0 ? (
            borrowings.map((borrowing) => (
              <li key={borrowing.id} className="py-4 flex flex-col md:flex-row items-start md:items-center justify-between">
                <div className="flex items-center space-x-3">
                  <Book className="h-6 w-6 text-indigo-500" />
                  <div>
                    <p className="font-semibold text-gray-800">{borrowing.book_title}</p>
                    <p className="text-sm text-gray-500">Borrowed by: {borrowing.user_name}</p>
                    <p className="text-sm text-gray-500">Due: {borrowing.due_date}</p>
                  </div>
                </div>
                <div className="flex space-x-2 mt-4 md:mt-0">
                  <button
                    onClick={() => handleReturn(borrowing.id)}
                    className="flex items-center space-x-1 bg-green-500 text-white py-2 px-4 rounded-lg font-semibold hover:bg-green-600 transition-colors"
                  >
                    <CheckCircle2 className="h-4 w-4" />
                    <span>Return</span>
                  </button>
                  <button
                    onClick={() => handleCancel(borrowing.id)}
                    className="flex items-center space-x-1 bg-red-500 text-white py-2 px-4 rounded-lg font-semibold hover:bg-red-600 transition-colors"
                  >
                    <Ban className="h-4 w-4" />
                    <span>Cancel</span>
                  </button>
                </div>
              </li>
            ))
          ) : (
            <li className="text-center text-gray-500 py-4">No active borrowings.</li>
          )}
        </ul>
      </div>

      <div className="bg-white rounded-xl shadow-lg p-6 mt-8">
        <h3 className="text-2xl font-bold text-gray-800 mb-4">Overdue Borrowings</h3>
        <ul className="divide-y divide-gray-200">
          {dashboardData.overdue_borrowings.length > 0 ? (
            dashboardData.overdue_borrowings.map((borrowing, index) => (
              <li key={index} className="py-4 flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <AlertCircle className="h-6 w-6 text-red-500" />
                  <div>
                    <p className="font-semibold text-gray-800">{borrowing.book_title}</p>
                    <p className="text-sm text-gray-500">Borrowed by: {borrowing.user_name}</p>
                  </div>
                </div>
                <span className="text-sm text-red-600 font-bold">Due on: {borrowing.due_date}</span>
              </li>
            ))
          ) : (
            <li className="text-center text-gray-500 py-4">No overdue books.</li>
          )}
        </ul>
      </div>
    </div>
  );
};

const MemberDashboard = () => {
  const { token } = useContext(AuthContext);
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      if (token) {
        const data = await api.getMemberDashboard(token);
        setDashboardData(data);
        setLoading(false);
      }
    };
    fetchData();
  }, [token]);

  if (loading) {
    return <div className="text-center mt-8 text-gray-600">Loading dashboard...</div>;
  }

  return (
    <div className="space-y-6">
      <h2 className="text-3xl font-bold text-gray-800">My Dashboard</h2>

      <div className="bg-white rounded-xl shadow-lg p-6">
        <h3 className="text-2xl font-bold text-gray-800 mb-4">Borrowed Books</h3>
        <ul className="divide-y divide-gray-200">
          {dashboardData.borrowed_books.length > 0 ? (
            dashboardData.borrowed_books.map((book, index) => (
              <li key={index} className="py-4 flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <Book className="h-6 w-6 text-indigo-500" />
                  <div>
                    <p className="font-semibold text-gray-800">{book.title}</p>
                    <p className="text-sm text-gray-500">by {book.author}</p>
                  </div>
                </div>
                {book.overdue ? (
                  <span className="text-sm text-red-600 font-bold">Overdue: {book.due_date}</span>
                ) : (
                  <span className="text-sm text-gray-600">Due: {book.due_date}</span>
                )}
              </li>
            ))
          ) : (
            <li className="text-center text-gray-500 py-4">You have not borrowed any books.</li>
          )}
        </ul>
      </div>

      <div className="bg-white rounded-xl shadow-lg p-6">
        <h3 className="text-2xl font-bold text-gray-800 mb-4">Overdue Books</h3>
        <ul className="divide-y divide-gray-200">
          {dashboardData.overdue_books.length > 0 ? (
            dashboardData.overdue_books.map((book, index) => (
              <li key={index} className="py-4 flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <AlertCircle className="h-6 w-6 text-red-500" />
                  <div>
                    <p className="font-semibold text-gray-800">{book.title}</p>
                    <p className="text-sm text-gray-500">by {book.author}</p>
                  </div>
                </div>
                <span className="text-sm text-red-600 font-bold">Due on: {book.due_date}</span>
              </li>
            ))
          ) : (
            <li className="text-center text-gray-500 py-4">No overdue books.</li>
          )}
        </ul>
      </div>
    </div>
  );
};

const BookList = () => {
  const { user, token } = useContext(AuthContext);
  const [books, setBooks] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingBook, setEditingBook] = useState(null);
  const [message, setMessage] = useState({ text: '', type: '' });

  const fetchBooks = async (query = '') => {
    setLoading(true);
    const data = await api.getBooks(query);
    setBooks(data);
    setLoading(false);
  };

  useEffect(() => {
    fetchBooks();
  }, []);

  const handleSearch = (e) => {
    e.preventDefault();
    fetchBooks(searchTerm);
  };

  const handleBorrow = async (bookId) => {
    const res = await api.borrowBook(bookId, token);
    if (res.borrowing) {
      setMessage({ text: 'Book borrowed successfully!', type: 'success' });
      fetchBooks(); // Refresh book list
    } else {
      setMessage({ text: res.errors || 'Failed to borrow book.', type: 'error' });
    }
  };

  const handleEdit = (book) => {
    setEditingBook(book);
    setShowForm(true);
  };

  const handleDelete = async (bookId) => {
    // Replaced window.confirm with a custom modal/message to avoid issues in the iframe
    try {
      await api.deleteBook(bookId, token);
      setMessage({ text: 'Book deleted successfully!', type: 'success' });
      fetchBooks();
    } catch (error) {
      setMessage({ text: 'Failed to delete book.', type: 'error' });
    }
  };

  const handleFormSubmit = (success) => {
    if (success) {
      setMessage({ text: `Book ${editingBook ? 'updated' : 'created'} successfully!`, type: 'success' });
      fetchBooks();
      setShowForm(false);
      setEditingBook(null);
    } else {
      setMessage({ text: 'Failed to save book.', type: 'error' });
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-3xl font-bold text-gray-800">Available Books</h2>
        {user?.role === 'librarian' && (
          <button
            onClick={() => {
              setEditingBook(null);
              setShowForm(true);
            }}
            className="flex items-center space-x-2 bg-indigo-600 text-white py-2 px-4 rounded-lg font-semibold hover:bg-indigo-700 transition-colors"
          >
            <Plus className="h-5 w-5" />
            <span>Add New Book</span>
          </button>
        )}
      </div>

      <form onSubmit={handleSearch} className="flex items-center space-x-2">
        <div className="relative flex-grow">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search by title, author, or genre..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>
        <button
          type="submit"
          className="bg-indigo-600 text-white py-2 px-6 rounded-lg font-semibold hover:bg-indigo-700 transition-colors"
        >
          Search
        </button>
      </form>

      {message.text && (
        <div className={`p-4 rounded-lg flex items-center space-x-3 ${message.type === 'success' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
          {message.type === 'success' ? <CircleCheck className="h-5 w-5" /> : <XCircle className="h-5 w-5" />}
          <span>{message.text}</span>
        </div>
      )}

      {showForm && (
        <BookForm book={editingBook} onClose={() => setShowForm(false)} onSubmit={handleFormSubmit} />
      )}

      {loading ? (
        <div className="text-center mt-8 text-gray-600">Loading books...</div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {books.length > 0 ? (
            books.map((book) => (
              <BookCard
                key={book.id}
                book={book}
                onBorrow={handleBorrow}
                onEdit={handleEdit}
                onDelete={handleDelete}
              />
            ))
          ) : (
            <div className="col-span-full text-center text-gray-500">No books found.</div>
          )}
        </div>
      )}
    </div>
  );
};

const BookForm = ({ book, onClose, onSubmit }) => {
  const { token } = useContext(AuthContext);
  const [formData, setFormData] = useState(book || {
    title: '',
    author: '',
    genre: '',
    isbn: '',
    total_copies: 1,
  });
  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({ ...prevData, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    let res;
    if (book) {
      res = await api.updateBook(book.id, formData, token);
    } else {
      res = await api.createBook(formData, token);
    }

    if (res.id) {
      onSubmit(true);
    } else {
      setErrors(res.errors || {});
      onSubmit(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-xl shadow-lg p-6 w-full max-w-lg">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-2xl font-bold text-gray-800">{book ? 'Edit Book' : 'Add New Book'}</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <XCircle className="h-6 w-6" />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Title</label>
            <input
              type="text"
              name="title"
              value={formData.title}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
            {errors.title && <p className="text-red-500 text-sm mt-1">{errors.title}</p>}
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Author</label>
            <input
              type="text"
              name="author"
              value={formData.author}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
            {errors.author && <p className="text-red-500 text-sm mt-1">{errors.author}</p>}
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Genre</label>
            <input
              type="text"
              name="genre"
              value={formData.genre}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
            {errors.genre && <p className="text-red-500 text-sm mt-1">{errors.genre}</p>}
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">ISBN</label>
            <input
              type="text"
              name="isbn"
              value={formData.isbn}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
            {errors.isbn && <p className="text-red-500 text-sm mt-1">{errors.isbn}</p>}
          </div>
          <div>
            <label className="block text-gray-700 font-semibold mb-2">Total Copies</label>
            <input
              type="number"
              name="total_copies"
              value={formData.total_copies}
              onChange={handleChange}
              min="1"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
            {errors.total_copies && <p className="text-red-500 text-sm mt-1">{errors.total_copies}</p>}
          </div>
          <div className="flex justify-end space-x-2">
            <button
              type="button"
              onClick={onClose}
              className="bg-gray-300 text-gray-800 py-2 px-4 rounded-lg font-semibold hover:bg-gray-400 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="bg-indigo-600 text-white py-2 px-4 rounded-lg font-semibold hover:bg-indigo-700 transition-colors"
            >
              {book ? 'Update' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Router setup
const router = createHashRouter([
  {
    path: '/',
    element: <Root />,
    children: [
      {
        index: true,
        element: <Login />,
      },
      {
        path: '/login',
        element: <Login />,
      },
      {
        path: '/register',
        element: <Register />,
      },
      {
        path: '/books',
        element: <BookList />,
      },
      {
        path: '/librarian/dashboard',
        element: <LibrarianDashboard />,
      },
      {
        path: '/member/dashboard',
        element: <MemberDashboard />,
      },
    ],
  },
]);

export default App;