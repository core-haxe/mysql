package mysql;

class MySqlResult<T> {
    public var connection:DatabaseConnection;
    public var data:T;
    public var lastInsertId:Null<Int> = null;
    public var affectedRows:Null<Int> = null;

    public function new(connection:DatabaseConnection, data:T) {
        this.connection = connection;
        this.data = data;
    }
}