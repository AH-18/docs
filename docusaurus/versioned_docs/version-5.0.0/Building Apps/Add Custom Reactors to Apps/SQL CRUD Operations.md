---
sidebar_label: 'SQL CRUD Operations'
sidebar_position: 6
slug: "custom-reactor/crud-ops"
description: "How to create SQL CRUD operations in a reactor"
---

import AppName, {WrapVariable, DynamicCodeBlock} from "@site/src/components/CustomFields";

# CRUD Operations In A Custom Reactor

## Guide to Creating a Custom Reactor

The following guide demonstrates how to implement CRUD (Create, Read, Update, Delete) operations within a custom reactor in SEMOSSName. Leveraging SEMOSSName flexible architecture, developers can seamlessly interact with databases, enforce data integrity, and extend application capabilities. This step-by-step tutorial offers clear instructions for integrating CRUD logic into your custom reactors, supporting the development of robust and maintainable data management solutions.

### SEMOSSName Database CRUD (Create, Read, Update, Delete) Operations Tutorial

SEMOSSName enables rapid customization for performing CRUD operations on databases. In this tutorial, you will learn how to implement create, read, update, and delete actions using a Movie dataset as an example.

The database metamodel is illustrated below:

![Movie Metamodel](/img/Creating%20a%20custom%20reactor/movie-metamodel.PNG)
> _Database Construct_

**To follow along, reference the [Movie Management Project](/assets/Backend%20Files/Project).**

*The project folder includes insights for performing CRUD operations and Java classes for each operation in the `assets/java` directory. For brevity, pixel input/output definitions are omitted here. For details on handling inputs, see the relevant documentation in other tutorials.*


#### SEMOSSName Database Connection

To perform operations on a database in SEMOSSName, you can retrieve the database by its ID. In this example, our database is an `RDBMSNativeEngine`. The `RDBMSNativeEngine` provides a method `getPreparedStatement(String query)` to obtain a `PreparedStatement`.

#### Creating a New Genre
To create a new genre, first define your SQL query for inserting into the table. Next, obtain your database connection and create a `PreparedStatement` from the query. Finally, add your arguments and execute the `PreparedStatement`.

```java
    private static String insertQuery = "INSERT INTO GENRE (GENRE, TITLE_FK) VALUES (?, ?)";
    
    RDBMSNativeEngine database = (RDBMSNativeEngine) Utility.getEngine(databaseId);
    PreparedStatement ps = null;
    try {
        int i = 1;
        ps = database.getPreparedStatement(AddGenreReactor.insertQuery);
        ps.setString(i++, genre);
        ps.setString(i++, title);
        ps.execute();
        database.commit();
    } catch (SQLException e) {
        logger.error(Constants.STACKTRACE, e);
        return NounMetadata.getErrorNounMessage("SQL ERROR: " + e.getMessage());
    } finally {
        ConnectionUtils.closePreparedStatement(ps);
    }

```

**This reactor can be tested in the pixel console in SEMOSSName by running:**
```
AddGenre(database=["2555ec1b-e1a2-4905-91e0-022dc57fc564"], title=["Semoss"], genre=["Tech Documentary"]);
```

#### Updating a Movie Title
In our Movie Database a Movie Title is the primary key. If we update a Movie Title in one table, we also need to do it in the others. First, we create our sql queries to perform the updates across multiple tables. Then, we get our database connection and create PreparedStatements from the queries. Finally, we add our arguments and execute the PreparedStatements.

```java
    private static final String titleUpdate = "UPDATE TITLE SET TITLE = ? WHERE TITLE = ?";
    private static final String nominatedUpdate = "UPDATE NOMINATED SET TITLE_FK = ? WHERE TITLE_FK = ?";
    private static final String genreUpdate = "UPDATE GENRE SET TITLE_FK = ? WHERE TITLE_FK = ?";
    
    RDBMSNativeEngine database = (RDBMSNativeEngine) Utility.getEngine(databaseId);
    database.setAutoCommit(false);
    PreparedStatement titlePS = null;
    PreparedStatement genrePS = null;
    PreparedStatement nomintationPS = null;
    try {
        // update title table
        titlePS = database.getPreparedStatement(UpdateMovieReactor.titleUpdate);
        titlePS.setString(1, newTitle);
        titlePS.setString(2, title);
        // update genre table
        genrePS = database.getPreparedStatement(UpdateMovieReactor.genreUpdate);
        genrePS.setString(1, newTitle);
        genrePS.setString(2, title);
        // update nomination table
        nomintationPS = database.getPreparedStatement(UpdateMovieReactor.nominatedUpdate);
        nomintationPS.setString(1, newTitle);
        nomintationPS.setString(2, title);
        titlePS.execute();
        genrePS.execute();
        nomintationPS.execute();
        database.commit();
    } catch (SQLException e) {
        return NounMetadata.getErrorNounMessage("SQL ERROR: " + e.getMessage());
    }
    finally {
        ConnectionUtils.closePreparedStatement(titlePS);
        ConnectionUtils.closePreparedStatement(genrePS);
        ConnectionUtils.closePreparedStatement(nomintationPS);
    }

```

**This reactor can be tested in the pixel console in SEMOSSName by running:**
<DynamicCodeBlock noQuotes>
```
UpdateMovie(database=["2555ec1b-e1a2-4905-91e0-022dc57fc564"], title=["{SEMOSSName}"],  newTitle=["{SEMOSSName}"]);
```
</DynamicCodeBlock>

#### Deleting a Genre
To perform a deletion on the database, first we write our deletion query. Then, we get our database connection and generate a PreparedStatement. Finally, we add our arguments and execute the PreparedStatement.

```java
    private static String deleteQuery = "DELETE FROM GENRE WHERE GENRE = ?";
    // delete genre from the database
    RDBMSNativeEngine database = (RDBMSNativeEngine) Utility.getEngine(databaseId);
    PreparedStatement ps = null;
    try {
        int i = 1;
        ps = database.getPreparedStatement(DeleteGenreReactor.deleteQuery);
        ps.setString(i++, genre);
        ps.execute();
    } catch (SQLException e) {
        return NounMetadata.getErrorNounMessage("SQL ERROR: " + e.getMessage());
    } finally {
        ConnectionUtils.closePreparedStatement(ps);
    }
```
**This reactor can be tested in the pixel console in SEMOSSName by running:**
```
DeleteGenre(database=["2555ec1b-e1a2-4905-91e0-022dc57fc564"], genre=["Tech Documentary"]);
```

## Case Statement Query Reactor
In this tutorial, we will create a query that dynamically generates a "Movie Recommendation" column for each movie entry, based on specific audience rating thresholds. By leveraging conditional logic within SQL-like queries, you will learn how to classify movies into categories such as "High," "Medium," or "Low" recommendation, providing actionable insights directly within your dataset. This approach demonstrates how to enrich your data with derived columns using case statements, enhancing the analytical capabilities of your custom reactors.

**Add the [Movies Database](/assets/Backend%20Files/Database/Movies__2555ec1b-e1a2-4905-91e0-022dc57fc564) and [CaseStatementQueryReactor.java](/assets/Backend%20Files/SRC/reactors/query/CaseStatementQueryReactor.java)**



#### QueryIfSelector
We will use the `QueryIfSelector.makeQueryIfSelector()` for simplicity, this method takes in the condition, prescedent, antecedent and alias. Our Movie Recommendation column will be based on RottenTomatoes_Audience

```
CASE
when RottenTomatoes_Audience >= .8 then High 
when RottenTomatoes_Audience >= .7 then Medium 
when RottenTomatoes_Audience >= .5 then Low 
ELSE ""
as "Movie Recommendation"
```

```
qs.addSelector(
    QueryIfSelector.makeQueryIfSelector(
        SimpleQueryFilter.makeColToValFilter("Title__RottenTomatoes_Audience", ">=", 0.8),
        new QueryConstantSelector("High"),
    QueryIfSelector.makeQueryIfSelector(
        SimpleQueryFilter.makeColToValFilter("Title__RottenTomatoes_Audience", ">=", .7),
        new QueryConstantSelector("Medium"),
    QueryIfSelector.makeQueryIfSelector(
        SimpleQueryFilter.makeColToValFilter("Title__RottenTomatoes_Audience", ">=", .5),
        new QueryConstantSelector("Low"), 
        new QueryConstantSelector(""), // Else no recommendation
        "Movie Recommendation"),
        "Movie Recommendation"),
        "Movie Recommendation")
);
```

Reference [Tutorials](/assets/Backend%20Files/Tutorials) for more examples and [src/reactors](/assets/Backend%20Files/SRC/reactors) for reactors code.