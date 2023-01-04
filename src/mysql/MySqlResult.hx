package mysql;

class MySqlResult<T> {
    public var connection:DatabaseConnection;
    public var data:T;

    public function new(connection:DatabaseConnection, data:T) {
        this.connection = connection;
        this.data = data;
    }
}