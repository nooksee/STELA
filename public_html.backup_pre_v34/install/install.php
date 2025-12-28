<?php
// Safety lock: prevent installer scripts from running after setup.
$__nukece_lock = __DIR__ . '/LOCK';
if (is_file($__nukece_lock)) {
    header('HTTP/1.1 403 Forbidden');
    exit('Installer is locked. Remove install/LOCK to run installers.');
}

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

// Simple web installation script for nukeCE.
// This installer will create a configuration file and database
// tables required for the News module. After installation,
// you should remove or secure this file.

function renderForm(string $error = ''): void
{
    echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">';
    echo '<title>nukeCE Installation</title>';
    echo '<style>body{font-family:sans-serif;padding:2rem;}label{display:block;margin-top:1rem;}input{padding:0.5rem;width:100%;max-width:300px;}button{margin-top:1rem;padding:0.5rem 1rem;} .error{color:red;}</style>';
    echo '</head><body>';
    echo '<h1>nukeCE Installation</h1>';
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
        // Create all tables required by standard modules
        $schema = [];
        // News articles
        $schema[] = "CREATE TABLE IF NOT EXISTS news (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            title VARCHAR(255) NOT NULL,\n            content TEXT NOT NULL,\n            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Static content pages
        $schema[] = "CREATE TABLE IF NOT EXISTS content (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            title VARCHAR(255) NOT NULL,\n            body TEXT NOT NULL,\n            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Downloads directory
        $schema[] = "CREATE TABLE IF NOT EXISTS downloads (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            title VARCHAR(255) NOT NULL,\n            description TEXT NOT NULL,\n            url VARCHAR(255) NOT NULL\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Encyclopedia entries
        $schema[] = "CREATE TABLE IF NOT EXISTS encyclopedia (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            term VARCHAR(255) NOT NULL,\n            definition TEXT NOT NULL\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // FAQ entries
        $schema[] = "CREATE TABLE IF NOT EXISTS faq (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            question TEXT NOT NULL,\n            answer TEXT NOT NULL\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Journal entries
        $schema[] = "CREATE TABLE IF NOT EXISTS journal (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            title VARCHAR(255) NOT NULL,\n            entry TEXT NOT NULL,\n            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Users table
        $schema[] = "CREATE TABLE IF NOT EXISTS users (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            username VARCHAR(255) NOT NULL,\n            registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // News submissions for review
        $schema[] = "CREATE TABLE IF NOT EXISTS news_submissions (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            title VARCHAR(255) NOT NULL,\n            content TEXT NOT NULL,\n            submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Topics
        $schema[] = "CREATE TABLE IF NOT EXISTS topics (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            name VARCHAR(255) NOT NULL\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Many‑to‑many relation between news and topics
        $schema[] = "CREATE TABLE IF NOT EXISTS news_topics (\n            news_id INT NOT NULL,\n            topic_id INT NOT NULL,\n            PRIMARY KEY(news_id, topic_id),\n            FOREIGN KEY (news_id) REFERENCES news(id) ON DELETE CASCADE,\n            FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Web links directory
        $schema[] = "CREATE TABLE IF NOT EXISTS weblinks (\n            id INT AUTO_INCREMENT PRIMARY KEY,\n            title VARCHAR(255) NOT NULL,\n            url VARCHAR(255) NOT NULL,\n            description TEXT NOT NULL\n        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        // Execute schema
        foreach ($schema as $sql) {
            $pdo->exec($sql);
        }
        // Insert sample data
        $stmt = $pdo->prepare('INSERT INTO news (title, content) VALUES (:title, :content)');
        $stmt->execute([
            'title' => 'Welcome to nukeCE',
            'content' => 'Your installation was successful! Edit or delete this article from your database.',
        ]);
        // Insert sample content page
        $stmt = $pdo->prepare('INSERT INTO content (title, body) VALUES (:title, :body)');
        $stmt->execute([
            'title' => 'About Us',
            'body' => 'This is a sample static page. You can edit or remove it.',
        ]);
        // Insert sample download
        $stmt = $pdo->prepare('INSERT INTO downloads (title, description, url) VALUES (:title, :description, :url)');
        $stmt->execute([
            'title' => 'Sample File',
            'description' => 'This is a sample download entry.',
            'url' => 'https://example.com/file.zip',
        ]);
        // Insert sample encyclopedia entry
        $stmt = $pdo->prepare('INSERT INTO encyclopedia (term, definition) VALUES (:term, :definition)');
        $stmt->execute([
            'term' => 'PHP',
            'definition' => 'PHP is a popular general‑purpose scripting language that is especially suited to web development.',
        ]);
        // Insert sample FAQ
        $stmt = $pdo->prepare('INSERT INTO faq (question, answer) VALUES (:question, :answer)');
        $stmt->execute([
            'question' => 'What is nukeCE?',
            'answer' => 'nukeCE is a modern reinterpretation of the classic PHP‑Nuke content management system.',
        ]);
        // Insert sample journal entry
        $stmt = $pdo->prepare('INSERT INTO journal (title, entry) VALUES (:title, :entry)');
        $stmt->execute([
            'title' => 'My First Entry',
            'entry' => 'This is a sample journal entry.',
        ]);
        // Insert sample user
        $stmt = $pdo->prepare('INSERT INTO users (username) VALUES (:username)');
        $stmt->execute(['username' => 'admin']);
        // Insert sample topic
        $stmt = $pdo->prepare('INSERT INTO topics (name) VALUES (:name)');
        $stmt->execute(['name' => 'General']);
        // Insert sample news_topics relation
        $stmt = $pdo->prepare('INSERT INTO news_topics (news_id, topic_id) VALUES (:news_id, :topic_id)');
        $stmt->execute(['news_id' => 1, 'topic_id' => 1]);
        // Insert sample weblink
        $stmt = $pdo->prepare('INSERT INTO weblinks (title, url, description) VALUES (:title, :url, :description)');
        $stmt->execute([
            'title' => 'PHP Official Site',
            'url' => 'https://www.php.net',
            'description' => 'The official website for the PHP programming language.',
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