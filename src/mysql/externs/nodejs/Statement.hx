package mysql.externs.nodejs;

@:jsRequire("mysql2", "Statement")
extern class Statement {
    public function execute(?params:Dynamic, ?cb:MySql2Error->Array<Dynamic>->Dynamic->Void):Void;
    public function close():Void;
}