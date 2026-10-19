---
sidebar_label: 'Python Reactors'
sidebar_position: 7
slug: "custom-reactor/python-inline"
description: "A guide to using python in reactors"
---

# Running Python Scripts from a Custom Reactor

## Overview
To run python within a custom reactor use a PyTranslator object. Every reactor has an insight associated with it that can be used to create a pyTranslator object:

```java
PyTranslator pyt = this.insight.getPyTranslator();
```

To execute a python script using the PythonTransator send a string holding a python script to the runScript function. 

```java
Object output = pyt.runScript(pythonScript);
```

This function will return the output from the script as an object. If you want the output to be returned as a string you can use the function below:

```java
String output = pyt.runPyAndReturnOutput(pythonScript);
```

To run to script without returning any output you can use:

```java
pyt.runEmptyPy(pythonScript);
```

## Example using the PyTranslator

This example executes a python script created inline that returns "Hello World!"

```java
// Get PyTranslator from insight in the custom reactor
PyTranslator pyt = this.insight.getPyTranslator();

// Creating a string representing a python script
StringBuilder callMaker = new StringBuilder("var1 = Hello\n");	
callMaker.append("var2 = World!\n");
callMaker.append("var1 + var2");

// Execute python script from string
Object output = pyt.runScript(callMaker.toString());

return output;
```

# Running Python Scripts from a File in a Reactor

Custom reactors allow you to run a python file directly from the java code. To use a custom python class utilize the LoadPyFromFileReactor. The LoadPyFromFileReactor takes in three parameters filePath (the path to the python file), space (project id), and alias (the name used to refer to the class once loaded).

## Example of using LoadPyFromFileReactor to load a python class

```java
// Get the current project id
String projectId = this.insight.getProjectId();
if (projectId == null) projectId = this.insight.getContextProjectId();

// Create a noun store and set the parameters required for the LoadPyFromFileReactor
NounStore ns = new NounStore(ReactorKeysEnum.ALL.getKey());
ns.makeNoun("filePath").addLiteral("version/assets/py/python_class.py");
ns.makeNoun(ReactorKeysEnum.SPACE.getKey()).addLiteral(projectId);
ns.makeNoun("alias").addLiteral("class_alias");

// Create and initialize new reactor object
LoadPyFromFileReactor loadPy = new LoadPyFromFileReactor();
loadPy.setPixelPlanner(this.getPixelPlanner());
loadPy.setInsight(this.insight);
loadPy.setNounStore(ns);
loadPy.In();

// Execute reactor
NounMetadata loadPyResponse = loadPy.execute();
if (loadPyResponse.getNounType().equals(PixelDataType.ERROR)) {
    throw new IllegalArgumentException("ERROR: " + loadPyResponse.getExplanation());
}
```

Once the python class is loaded you can call it via the PyReactor or a PyTranslator as show above.

## Example of running python script from a file

We have the following python script we want to run within a custom reactor:

```python
from datetime import datetime

def custom_python_function():
    dateTime = datetime.now()
    return str(dateTime)

print("Current Date and Time: " + custom_python_function())
```

To execute this script we read from the file into a string and then send that to the PyTranslator from the insight:

```java
String filePath = "path/to/example.py";

try {
    String pyScript = new String(Files.readAllBytes(Paths.get(filePath)));
} catch (IOException e) {
    e.printStackTrace();
}

PyTranslator pyt = this.insight.getPyTranslator();
Object output = pyt.runScript(pyScript);

return output;
```

The PyTranslator runScript function returns the output of the python script as an Object.