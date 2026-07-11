<?php
require_once 'config/database.php';
require_once 'includes/functions.php';

if (isLoggedIn()) {
    if (hasRole('ADMIN')) redirect('/sikha-new/admin/dashboard.php');
    if (hasRole('GURU')) redirect('/sikha-new/guru/dashboard.php');
}
redirect('/sikha-new/login.php');
