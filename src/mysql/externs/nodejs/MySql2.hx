package mysql.externs.nodejs;

@:jsRequire("mysql2")
extern class MySql2 {
    public static function createConnection(details:Dynamic):Connection;
    public static function createPool(details:Dynamic):Pool;
}