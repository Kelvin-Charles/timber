<?php
header("Content-Type: application/json");
echo json_encode([
    "name" => "NgaraTimber API",
    "version" => "1.0.0",
    "status" => "active",
    "endpoints" => [
        "/api/login.php",
        "/api/register.php",
        "/api/logs.php",
        "/api/inventory.php",
        "/api/productions.php",
        "/api/customers.php",
        "/api/orders.php"
    ]
]);
?> 