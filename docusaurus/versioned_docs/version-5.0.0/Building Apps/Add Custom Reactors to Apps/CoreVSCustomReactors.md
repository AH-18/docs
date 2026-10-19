---
sidebar_label: "Core Reactors vs Custom Reactors"
sidebar_position: 3
slug: "java/core-vs-custom-reactors"
description: "Understand the differences between platform-provided core reactors and app-specific custom reactors."
---

import AppName from "@site/src/components/CustomFields";

# Difference between Core Reactors vs Custom Reactors

Reactors are Java classes that implement business logic for a [Pixel](../../Building%20Apps/Add%20Custom%20Reactors%20to%20Apps/Pixels.md) command. <AppName /> provides a large set of platform reactors, and you can also create reactors for logic that is specific to your application.

## Core reactors

Core reactors are built into <AppName /> and maintained as part of the platform. They provide the standard commands used for common operations such as working with databases, querying data, managing insights, and interacting with platform services.

Core reactors:

- Are available to apps without adding Java source code to the app.
- Follow the platform's established input, output, security, and error-handling behavior.
- Are updated and distributed through <AppName /> releases.
- Can be discovered through `Help()` in the Pixel terminal and inspected with the command's `--help` option.
- Are the preferred choice when an existing command already meets your requirements.

For an introduction to Pixel commands and their syntax, see [Pixels](../../Building%20Apps/Add%20Custom%20Reactors%20to%20Apps/Pixels.md).

See [list of core reactors](../../../developer/Reactors)

## Custom reactors

Custom reactors are Java classes that you add to an app when the platform reactors do not provide the required behavior. They let you implement application-specific logic or use Java libraries that are not part of the standard reactor set.

Custom reactors:

- Are owned and maintained by the app development team.
- Live in the app's Java folder and are compiled for that app.
- Can define their own inputs, validation, business logic, and return values.
- Can reuse <AppName /> classes by declaring the required Maven dependencies.
- Must be tested and recompiled whenever their source code changes.

See [Create Your Own Pixel](Custom%20Reactors.md) for the process of creating a custom reactor.

## Comparison

| Area | Core reactor | Custom reactor |
| --- | --- | --- |
| Ownership | Maintained by <AppName /> | Maintained by the app team |
| Availability | Included with the platform | Added to a specific app |
| Setup | No Java source or compilation required | Requires Java source, dependencies, and compilation |
| Behavior | Standardized across the platform version | Defined by the custom implementation |
| Updates | Delivered with platform releases | Updated when the app team changes and recompiles the code |
| Reuse | Available to apps that use the platform | Available wherever the custom reactor is deployed |
| Best for | Common platform operations | Application-specific or integration-specific logic |

## Which should you use?

Use a core reactor when:

- The required operation is already available in the platform.
- You want standard platform behavior and support.
- You want to avoid maintaining additional Java code.

Use a custom reactor when:

- No core reactor provides the required operation.
- The operation contains business rules unique to your app.
- You need to integrate with a library, service, or system that is not supported by a core reactor.
- You need to combine several operations behind one app-specific Pixel command.

Before creating a custom reactor, search the available commands with `Help()` and review the relevant command's `--help` output. Extending an existing core reactor or composing existing Pixel commands may be simpler than maintaining new Java code.

## Important considerations

Custom reactors have more flexibility, but they also introduce an application maintenance responsibility. Keep dependencies explicit, validate inputs, handle errors consistently, and test the reactor with representative Pixel calls. After changing the source code, recompile the custom reactors so the updated implementation is deployed to the app.

## Best Practices

### Document the custom reactor

Implement/Override these methods

```java

@Override
	protected String getDescriptionForKey(String key) {
		if(key.equals(ReactorKeysEnum.VALUE.getKey())) {
			return "The value to echo back";
		}
		return super.getDescriptionForKey(key);
	}
	
	@Override
	public String getReactorDescription() {
		return "This reactor returns back the input the user enters";
	}
```

 Check for required keys

```java
	public AdminSqlQueryReactor() {
		this.keysToGet = new String[] { ReactorKeysEnum.QUERY_KEY.getKey(), ReactorKeysEnum.DATABASE.getKey(),
				ReactorKeysEnum.LIMIT.getKey(), "commit" };
		this.keyRequired = new int[] { 1, 1, 0, 0, 0 };
	}
```