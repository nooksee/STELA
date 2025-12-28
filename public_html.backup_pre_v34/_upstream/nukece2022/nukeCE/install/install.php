<?php
// Simple web installation script for NukeCE.
// This installer will create a configuration file and database
// tables required for the News module. After installation,
// you should remove or secure this file.

function renderForm(string $error = ''): void
{
    echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">';
    echo '<title>NukeCE Installation</title>';
    echo '<style>body{font-family:sans-serif;padding:2rem;}label{display:block;margin-top:1rem;}input{padding:0.5rem;width:100%;max-width:300px;}button{margin-top:1rem;padding:0.5rem 1rem;} .error{color:red;}</style>';
    echo '</head><body>';
    echo '<h1>NukeCE Installation</h1>';
    if ($error) {
        echo '<p class="error">' . htmlspecialchars($error) . '</p>';
    }
    echo '<form method="post">';
    echo '<label>Database host<input type="text" name="db_host" value="localhost"></label>';
    echo '<label>Database name<input type="text" name="db_name" required></label>';
    echo '<label>Database user<input type="text" name="db_user" required></label>';
    echo '<label>Database password<input type="password" name="db_pass"></label>';
    echo '<button type="submit">Install</button>';
    echo '</form>';
    echo '</body></html>';
}

// If request method is POST, attempt installation
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $dbHost = $_POST['db_host'] ?? '';
    $dbName = $_POST['db_name'] ?? '';
    $dbUser = $_POST['db_user'] ?? '';
    $dbPass = $_POST['db_pass'] ?? '';

    if (!$dbHost || !$dbName || !$dbUser) {
        renderForm('Please fill out all required fields.');
        exit;
    }
    // Create config file
    $configContent = "<?php\nreturn [\n    'db_host' => '" . addslashes($dbHost) . "',\n    'db_name' => '" . addslashes($dbName) . "',\n    'db_user' => '" . addslashes($dbUser) . "',\n    'db_pass' => '" . addslashes($dbPass) . "',\n];\n";
    $configPath = __DIR__ . '/../config/config.php';
    if (file_exists($configPath)) {
        renderForm('Configuration file already exists. Remove it before reinstalling.');
        exit;
    }
    if (file_put_contents($configPath, $configContent) === false) {
        renderForm('Failed to write configuration file. Check permissions.');
        exit;
    }
    // Create tables
    try {
        $pdo = new PDO('mysql:host=' . $dbHost . ';dbname=' . $dbName . ';charset=utf8mb4', $dbUser, $dbPass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $sql = "CREATE TABLE IF NOT EXISTS news (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            title VARCHAR(255) NOT NULL,\n            content TEXT NOT NULL,\n            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        $pdo->exec($sql);
        // Insert a sample article
        $stmt = $pdo->prepare('INSERT INTO news (title, content) VALUES (:title, :content)');
        $stmt->execute([
            'title' => 'Welcome to NukeCE',
            'content' => 'Your installation was successful! Edit or delete this article from your database.',
        ]);
    } catch (PDOException $e) {
        unlink($configPath);
        renderForm('Database error: ' . $e->getMessage());
        exit;
    }
    echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">';
    echo '<title>Installation Complete</title></head><body>';
    echo '<h1>Installation Complete</h1>';
    echo '<p>Your configuration file has been created and the database has been initialised.</p>';
    echo '<p><a href="../index.php">Go to your site</a></p>';
    echo '</body></html>';
    exit;
}
renderForm();