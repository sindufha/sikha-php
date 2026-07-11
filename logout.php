<?php
require_once 'config/database.php';
require_once 'includes/functions.php';

if (isLoggedIn()) {
    logAudit($pdo, 'LOGOUT', 'User logout');
}

session_destroy();
redirect('/sikha-new/login.php');
