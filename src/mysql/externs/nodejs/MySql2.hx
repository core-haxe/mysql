package mysql.externs.nodejs;

@:jsRequire("mysql2")
extern class MySql2 {
    public static function createConnection(detais:Dynamic):Connection;
}