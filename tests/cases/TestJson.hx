package cases;

import mysql.DatabaseConnection;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestJson extends Test {
    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        DBCreator.create().then(_ -> {
            async.done();
        });
    }

    function teardown(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        async.done();
        /*
        DBCreator.delete().then(_ -> {
            async.done();
        });
        */
    }
    
    function testBasicSelect(async:Async) {
        var connection:DatabaseConnection = null;
        DBCreator.createConnection("persons2").then(c -> {
            connection = c;
            return connection.query("SELECT * FROM Person");
        }).then(result -> {
            Assert.equals(4, result.data.length);

            Assert.equals(result.data[0].personId, 1);
            switch (Type.typeof(result.data[0].personId)) { // utest not taking types into account, manually wire
                case TInt:
                    // pass    
                case _:    
                    Assert.fail("should be a int");
            }

            Assert.equals(result.data[0].firstName, "Ian");
            Assert.equals(result.data[0].lastName, "Harrigan");
            Assert.equals(result.data[0].iconId, 1);
            Assert.equals(result.data[0].amount, 123.456);
            Assert.equals(result.data[0].settings.intSetting, 11);
            switch (Type.typeof(result.data[0].amount)) { // utest not taking types into account, manually wire
                case TFloat:
                    // pass    
                case _:    
                    Assert.fail("should be a float");
            }

            Assert.equals(result.data[2].personId, 3);
            Assert.equals(result.data[2].firstName, "Tim");
            Assert.equals(result.data[2].lastName, "Mallot");
            Assert.equals(result.data[2].iconId, 2);
            Assert.equals(result.data[2].amount, 222.333);
            Assert.equals(result.data[2].settings.intSetting, 33);

            connection.close();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }

    function testBasicSelectJsonInt(async:Async) {
        var connection:DatabaseConnection = null;
        DBCreator.createConnection("persons2").then(c -> {
            connection = c;
            return connection.query("SELECT * FROM Person");
        }).then(result -> {
            Assert.equals(4, result.data.length);

            Assert.equals(result.data[0].personId, 1);
            switch (Type.typeof(result.data[0].personId)) { // utest not taking types into account, manually wire
                case TInt:
                    // pass    
                case _:    
                    Assert.fail("should be a int");
            }

            Assert.equals(result.data[0].firstName, "Ian");
            Assert.equals(result.data[0].lastName, "Harrigan");
            Assert.equals(result.data[0].iconId, 1);
            Assert.equals(result.data[0].amount, 123.456);
            Assert.equals(result.data[0].settings.intSetting, 11);
            switch (Type.typeof(result.data[0].amount)) { // utest not taking types into account, manually wire
                case TFloat:
                    // pass    
                case _:    
                    Assert.fail("should be a float");
            }

            Assert.equals(result.data[2].personId, 3);
            Assert.equals(result.data[2].firstName, "Tim");
            Assert.equals(result.data[2].lastName, "Mallot");
            Assert.equals(result.data[2].iconId, 2);
            Assert.equals(result.data[2].amount, 222.333);

            return connection.query("SELECT * FROM Person WHERE (settings->'$.intSetting' = 22)");
        }).then(result -> {
            Assert.equals(1, result.data.length);

            Assert.equals(result.data[0].firstName, "Bob");
            Assert.equals(result.data[0].lastName, "Barker");
            Assert.equals(result.data[0].iconId, 3);
            Assert.equals(result.data[0].amount, 111.222);
            Assert.equals(result.data[0].settings.intSetting, 22);

            connection.close();
            async.done();
        }, error -> {
            trace(error);
            throw error;
            async.done();
        });
    }
}