# SafeRoute - A Crime-Aware Navigation App

A Flutter application that provides safe navigation routing by avoiding high-crime areas using machine learning and historical crime data.

## Getting Started

### Prerequisites

- **Flutter SDK**: Ensure you have Flutter installed and configured.
- **Python 3.8+**: Ensure you have Python installed.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/SafeRoute-A-Crime-Aware-Navigation-App.git
    cd SafeRoute-A-Crime-Aware-Navigation-App/saferoute
    ```

2.  **Install Backend Dependencies:**
    ```bash
    cd backend
    pip install -r requirements.txt
    ```

3.  **Install Frontend Dependencies:**
    ```bash
    # Open a new terminal in the 'saferoute' directory (root of the flutter project)
    flutter pub get
    ```

### Running the Application

You need to run both the backend server and the frontend application.

#### 1. Start the Backend Server

Open a terminal and run:

```bash
cd backend
python run_server.py
```
The server will start at `http://0.0.0.0:8000`.

#### 2. Run the Flutter App

Open a new terminal in the project root (`saferoute`) and run:

```bash
flutter run
```

If you are running on an emulator, the app will automatically connect to `10.0.2.2:8000` (Android) or `localhost:8000` (iOS/Web).

## Git Commands Cheat Sheet

Here are some common Git commands to help you manage your project:

### Basic Workflow
1.  **Check Status**: See which files have changed.
    ```bash
    git status
    ```
2.  **Add Changes**: Stage files for commit.
    ```bash
    git add .
    ```
3.  **Commit Changes**: Save your changes with a message.
    ```bash
    git commit -m "Your commit message here"
    ```
4.  **Push Changes**: Upload your commits to the remote repository (e.g., GitHub).
    ```bash
    git push origin main
    ```

### Other Useful Commands
- **Pull Latest Changes**: Update your local repository with changes from remote.
    ```bash
    git pull origin main
    ```
- **View History**: See the list of commits.
    ```bash
    git log --oneline
    ```

## Project Structure

- `backend/`: Python FastAPI backend for routing and risk calculation.
- `lib/`: Flutter frontend code.
- `assets/`: Images and data files.

## Troubleshooting

- **Backend Connection Error**: Ensure the backend server is running before starting the app.
- **Map Not Loading**: Check your internet connection as map tiles require network access.
