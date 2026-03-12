package mysql.externs.nodejs;

@:jsRequire("mysql2", "Pool")
extern class Pool {
    public function execute(sql:String, ?params:Dynamic, ?cb:MySql2Error->Array<Dynamic>->Dynamic->Void):Void;
    public function query(sql:String, ?params:Dynamic, ?cb:MySql2Error->Array<Dynamic>->Dynamic->Void):Void;
    public function end(?cb:MySql2Error->Void):Void;
}