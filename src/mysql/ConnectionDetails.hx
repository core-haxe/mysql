package mysql;

typedef ConnectionDetails = {
    var ?database:String;
    var host:String;
    var ?port:Int;
    var ?user:String;
    var ?pass:String;
}