# mysql
mysql for all relevant haxe targets

# basic usage

```haxe
var db = new DatabaseConnection({
    database: "somedb",
    host: "localhost",
    user: "someuser",
    pass: "somepassword"
});
db.open().then(result -> {
    return db.exec("CREATE TABLE Persons (PersonID int, LastName varchar(50), FirstName varchar(50);");
}).then(result -> {
    return db.exec("INSERT INTO Persons (PersonID, LastName, FirstName) VALUES (1, 'Ian', 'Harrigan');");
}).then(result -> {
    return db.all("SELECT * FROM Persons;");
}).then(result -> {
    for (person in result.data) {
        trace(person.FirstName, person.LastName);
    }
    return db.get("SELECT * FROM Persons WHERE PersonID = ?", [1]); // use prepared statement
}).then(result -> {
    trace(result.data.FirstName, result.data.LastName);
}, (error:MySqlError) -> {
    // error
});
```

# dependencies 

* nodejs - [__mysql2__](https://www.npmjs.com/package/mysql2) (`npm install mysql2`)
* sys - haxe's internal mysql
