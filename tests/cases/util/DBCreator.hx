package cases.util;

import sys.io.FileSeek;
import sys.io.File;
import sys.FileSystem;
import mysql.MySqlError;
import promises.PromiseUtils;
import mysql.DatabaseConnection;
import promises.Promise;

class DBCreator {
    private static var connection:DatabaseConnection;

    public static function createConnection(db:String = null):Promise<DatabaseConnection> {
        return new Promise((resolve, reject) -> {
            var host = Sys.getEnv("MYSQL_HOST");
            var user = Sys.getEnv("MYSQL_USER");
            var pass = Sys.getEnv("MYSQL_PASS");
            var port = 3308;

            var c = new DatabaseConnection({
                host: host,
                user: user,
                pass: pass,
                port: port,
                database: db
            });

            c.open().then(result -> {
                resolve(result.connection);
            }, error -> {
                trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ", error);
                reject(error);
            });
        });
    }

    public static function create():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            createConnection().then(c -> {
                connection = c;
                var promises = [];

                promises.push(delete.bind(false));

                promises.push(query.bind(connection, "CREATE DATABASE IF NOT EXISTS persons2;"));

                promises.push(query.bind(connection, "USE persons2"));

                promises.push(query.bind(connection, "CREATE TABLE IF NOT EXISTS Person (
                    personId int AUTO_INCREMENT,
                    lastName varchar(50),
                    firstName varchar(50),
                    iconId int,
                    contractDocument blob,
                    amount DECIMAL(20,6),
                    settings json,
                    PRIMARY KEY (personId)
                );"));
    
                promises.push(query.bind(connection, "CREATE TABLE IF NOT EXISTS Icon (
                    iconId int,
                    path varchar(50)
                );"));
    
                promises.push(query.bind(connection, "CREATE TABLE IF NOT EXISTS Organization (
                    organizationId int,
                    name varchar(50),
                    iconId int
                );"));
    
                promises.push(query.bind(connection, "CREATE TABLE IF NOT EXISTS Person_Organization (
                    Person_personId int,
                    Organization_organizationId int
                );"));
    
                promises.push(query.bind(connection, "TRUNCATE TABLE Person;"));
                promises.push(query.bind(connection, "TRUNCATE TABLE Icon;"));
                promises.push(query.bind(connection, "TRUNCATE TABLE Organization;"));
                promises.push(query.bind(connection, "TRUNCATE TABLE Person_Organization;"));

                return PromiseUtils.runSequentially(promises);
            }).then(_ -> {
                return addDummyData(connection);
            }).then(_ -> {
                resolve(true);
            }, error -> {
                if (connection != null) {
                    connection.close();
                }
                trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ", error);
                reject(error);
            });
        });
    }

    public static function addDummyData(connection:DatabaseConnection):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [];

            promises.push(query.bind(connection, "INSERT INTO Icon (iconId, path) VALUES (1, '/somepath/icon1.png');"));
            promises.push(query.bind(connection, "INSERT INTO Icon (iconId, path) VALUES (2, '/somepath/icon2.png');"));
            promises.push(query.bind(connection, "INSERT INTO Icon (iconId, path) VALUES (3, '/somepath/icon3.png');"));

            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, contractDocument, amount, settings) VALUES (1, 'Ian', 'Harrigan', 1, X'746869732069732069616e7320636f6e747261637420646f63756d656e74', 123.456, '{\"intSetting\": 11}');"));
            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, amount, settings) VALUES (2, 'Bob', 'Barker', 3, 111.222, '{\"intSetting\": 22}');"));
            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, amount, settings) VALUES (3, 'Tim', 'Mallot', 2, 222.333, '{\"intSetting\": 33}');"));
            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, amount, settings) VALUES (4, 'Jim', 'Parker', 1, 333.444, '{\"intSetting\": 44}');"));

            /*
            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, contractDocument, amount) VALUES (1, 'Ian', 'Harrigan', 1, X'746869732069732069616e7320636f6e747261637420646f63756d656e74', 123.456);"));
            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, amount) VALUES (2, 'Bob', 'Barker', 3, 111.222);"));
            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, amount) VALUES (3, 'Tim', 'Mallot', 2, 222.333);"));
            promises.push(query.bind(connection, "INSERT INTO Person (personId, firstName, lastName, iconId, amount) VALUES (4, 'Jim', 'Parker', 1, 333.444);"));
            */

            promises.push(query.bind(connection, "INSERT INTO Organization (organizationId, name, iconId) VALUES (1, 'ACME Inc', 2);"));
            promises.push(query.bind(connection, "INSERT INTO Organization (organizationId, name, iconId) VALUES (2, 'Haxe LLC', 1);"));
            promises.push(query.bind(connection, "INSERT INTO Organization (organizationId, name, iconId) VALUES (3, 'PASX Ltd', 3);"));

            promises.push(query.bind(connection, "INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (1, 1);"));
            promises.push(query.bind(connection, "INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (2, 1);"));
            promises.push(query.bind(connection, "INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (3, 1);"));
            promises.push(query.bind(connection, "INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (2, 2);"));
            promises.push(query.bind(connection, "INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (4, 2);"));
            promises.push(query.bind(connection, "INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (1, 3);"));
            promises.push(query.bind(connection, "INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (4, 3);"));

            PromiseUtils.runSequentially(promises).then(_ -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    private static function query(connection:DatabaseConnection, sql:String):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            connection.query(sql).then(_ -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    public static function delete(closeConnection:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            query(connection, "DROP DATABASE IF EXISTS persons2;").then(_ -> {
                if (closeConnection) {
                    connection.close();
                }
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

}