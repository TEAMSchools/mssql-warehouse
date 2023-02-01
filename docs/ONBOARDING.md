# Getting Started

## MacOS

### Install VS Code

1. Download and install VS Code
   - If you have Apple Silicon, install that specific version ONLY--the universal installer causes battery drain
2. Install these extensions:
   - [SQL Server (mssql)](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql)
   - [Trunk](https://marketplace.visualstudio.com/items?itemName=Trunk.io)

### Clone this repo

1. Create a [GitHub](https://github.com/) account
2. Share your username with me, and I will invite you to our org
3. Install [gh](https://cli.github.com/)
4. Open VS Code
5. Run `gh auth login` to authenticate with GitHub
6. Create a `projects` folder in your home directory
7. Clone this repo into your `projects` directory:
   ```sh
   gh repo clone TEAMSchools/mssql-warehouse ~/projects
   ```

### Connect to SQL Server

1. Use a password manager (like [1Password](https://1password.com)) to create a secure password for your username
2. Share your login with me. Use a secure service like [Password Pusher](https://pwpush.com/) if sending plain text
3. Go to the mssql extension tab and create a new Connection (`+` button):
   - Server: `winsql05`
   - Database: <kbd>⏎ Enter</kbd>
   - Authentication Type: <kbd>SQL Login</kbd>
   - Username: `yourusername`
   - Password: `yourpassword`
   - Save Password?: <kbd>Yes</kbd>
   - Profile Name: <kbd>⏎ Enter</kbd>
