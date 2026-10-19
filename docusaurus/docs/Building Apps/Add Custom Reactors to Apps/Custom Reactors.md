---
sidebar_label: 'Create Custom Pixel Reactor'
sidebar_position: 4
slug: "java/custom-reactor"
description: "How to create custom pixels (reactors)"
---

import AppName from "@site/src/components/CustomFields";

# Create Your Own Pixel/Reactor
### Overview
A reactor is a business logic unit of **[Pixel](../../Building%20Apps/Add%20Custom%20Reactors%20to%20Apps/Pixels.md)** which performs the desired operation for the user. At its core, a reactor is just a Java class file. Custom reactors are located inside a java folder within an App folder
<!-- TODO link to pro code file structure -->

## Steps
### Pixel/Reactor Name
Choose the name of your reactor keep in mind the following naming conventions:

 - The first letter of the name is capitalized.
 - The name of the class ends in `Reactor`. For example, `LLMReactor`, `MyFavoriteReactor`.
 - The pixel call that initiates the reactor is case-sensitive and is determined by what comes before "Reactor" in the name. For example, if you create a reactor called `TalkReactor`, then the corresponding pixel call is `Talk()`

In this example we will create a custom backend reactor to generate a greeting.

### Create Java File
Let's name our java file `CustomGreetingReactor.java`

Most IDE's help by providing the following code snippet
```
package yourgroupid.yourartifactid;

public class CustomGreetingReactor {

}
```

Anyone wanting to call our reactor will have to run the pixel 
```
CustomGreeting();
```

### Extend AbstractReactor
Every custom reactor has to extend AbstractReactor.

#### Override execute() method
By extending `AbstractReactor`, we must override the `exectute` method. The execute method is the logic that will happen when the pixel is called.

Here's the update to our code so far
```
package yourgroupid.yourartifactid;

import prerna.sablecc2.om.nounmeta.NounMetadata;
import prerna.sablecc2.reactor.AbstractReactor;

public class CustomGreetingReactor extends AbstractReactor {

	@Override
	public NounMetadata execute() {
		// TODO Auto-generated method stub
		return null;
	}

}
```

### Create Inputs
AbstractReactor handles the logic to process our custom the inputs. To do this, we need to define `this.keysToGet` in our constructor.

```
	public CustomGreetingReactor() {
	       this.keysToGet = new String[] {"firstName", "lastName", "age"};
	       this.keyRequired = new int[] {1,1,0};
	}
```

As shown in the above example, there are 3 input arguments indicating that the reactor expects to receive a "firstName", "lastName", and "age".

You can put any number of input arguments, and you can also specify whether these arguments should be **required** or **optional**.

To specify if an input is optional you need to define `this.keysRequired`.

### Implement custom logic
To implement our custom logic we have full control in the `execute` method

#### Process Inputs
We have defined input keys, now let's process the actual values

##### organizeKeys()
AbstractReactor provides `organizeKeys()` to help process inputs, this allows us to use `this.keyValue` and facilitates grabbing the inputs


### Return Output
The execute method requires a return value of NounMetadata. The NounMetadata object is used to encapsulate the return value and metadata of the value such as the dataType.

For our CustomGreetingReactor, we want to process inputs and return a formatted custom greeting as a String.

Here is our final java class
```java
package yourgroupid.yourartifactid;

import prerna.sablecc2.om.PixelDataType;
import prerna.sablecc2.om.nounmeta.NounMetadata;
import prerna.sablecc2.reactor.AbstractReactor;

public class CustomGreetingReactor extends AbstractReactor {
	
	public CustomGreetingReactor() {
	       this.keysToGet = new String[] {"firstName", "lastName", "age"};
	       this.keyRequired = new int[] {1,1,0};
	}

    @Override
    public NounMetadata execute() {
        // process inputs
        organizeKeys();
        String firstName = this.keyValue.get("firstName");
        String lastName = this.keyValue.get("lastName");
        String age = this.keyValue.get("age");

        // format greeting
        String greeting = "Hello, " + firstName + " " + lastName + "! You are " + age + " years old.";

        // return greeting
        return new NounMetadata(greeting, PixelDataType.CONST_STRING);
    }
}
```

### Extending What Your Reactor Can Do

In the above example, notice that the top of the reactor file has some import statements, like:

```
import prerna.sablecc2.om.PixelDataType;
import prerna.sablecc2.om.nounmeta.NounMetadata;
import prerna.sablecc2.reactor.AbstractReactor;
```

These import statements refer to classes that SEMOSSName provides through its [Maven Repository](https://mvnrepository.com/artifact/org.semoss/semoss). There are many more SEMOSSName classes, including (at least 987) reactors, that you can "borrow" by importing into your own code as shown above. Utilizing SEMOSSName's classes can supercharge the range of different functions that your reactor can perform.


### Final Recap
We created a reactor to generate a custom greeting.

To execute our pixel we can now run the following pixel command:
```
CustomGreetingReactor(firstName=["John"], lastName=["Doe"], age=["30"]);
```

The pixel return value should be:
```
"Hello, John Doe! You are 30 years old."
```

Put the Reactor file in inside Java folder within the App folder for App to be used.


## Deep Dive: How data is passed into a reactor

Each reactor has a NounStore Object, under the variable name store.

### What is a NounStore?  
It is a collection of keys pointing to another object, called a **GenRowStruct**.

### What is a GenRowStruct?  
It is a vector which stores inputs as **NounMetadata** objects.

### What is a NounMetadata?  
It is a wrapper around any Object value, PixelDataType nounType.

The store will hold all the information that is passed into the reactor, but based on how the information is sent, it will store it in different locations. Upon reactor initialization, an empty GenRowStruct is created.