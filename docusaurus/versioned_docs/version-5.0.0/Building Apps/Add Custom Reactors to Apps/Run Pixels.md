---
sidebar_label: 'Run Pixels'
sidebar_position: 5
slug: "java/run-pixel"
description: "How to run pixels"
---

import AppName from "@site/src/components/CustomFields";

## Validating and Testing a Reactor

1. Now that a custom reactor has been coded/developed, the next step is to add the reactor to your java folder and test it using the **Editor**.

   For that, open the SEMOSSName server and and click on **BI** in App Library as shown below.
   ![BI](/img/Creating%20a%20custom%20reactor/InsideBI.PNG)

   > _BI in App Library_

2. Next, under My Insights - click Create + New Project.
   ![ProjectButton](/img/Creating%20a%20custom%20reactor/AddNewProjectButton.PNG)

3. Mark your project as private and provide it with any name (Note: This is for your personal use). Select your project under the insight tab and copy the ID from the URL.
   ![ProjectPanel](/img/Creating%20a%20custom%20reactor/CreateNewProjectPanel.PNG)

4. Now on the left nav bar, click on **Add New Insight**. Then, go to the **  Terminal** (next to the Save button) and click **Editor** as Mode and then **Project** as your workspace. Please select your project that you created in step 3 from the dropdown. Enter your **version** -> **assets** folder. Create a java folder, a py folder, and a portals folder. Upload your reactors in the java folder. Upload any python files that your reactors use in the py file. Whenever you change your reactor or python file delete it from this directory and re-upload.
   ![CreateJavaFolder](/img/Creating%20a%20custom%20reactor/CreatingJavaFolder.PNG)

5. Run the following commands to test your reactors:

- `ReconnectServer(true)` - Run this if you ever get an analytic engine not available or if you made changes to your py file. Otherwise, you can ignore this step.
- `SetContext("Insert ID obtained from step 3")`
- `Compile("Insert ID obtained from step 3")`
  ![ConsoleCommandsSetProject](/img/Creating%20a%20custom%20reactor/ConsoleCommandstoSetProjectContextandTestReactor.PNG)

6. Now, run your reactor. If the name of your Java file is "TestReactor.java", then to validate your reactor in the terminal, you can now run Test().

- Note: Any changes to any file need to be recompiled using the Compile command.

7. In your front-end code. Whenever your load your app, make sure to run these pixel calls before any other reactors:

- `ReconnectServer(true)` - Run this if you ever get an analytic engine not available or if you made changes to your py file. Otherwise, you can ignore this step.
- `SetContext("Insert ID obtained from step 3")`
- `Compile("Insert ID obtained from step 3")`
- Note: Remove those three commands when you deploy your app. These commands are setting the context to your temporary project. However, when you deploy an app it's context is set to itself so there is no need to use another source. Remember that any changes to your reactors or Py file need to be uploaded to the project through step 4.

## Calling a Reactor using Pixel

Now after creating a reactor the next step is to Test whether reactor is working as required. For that, open the SEMOSSName server and and click on **Terminal** in App Library as shown below.

![Terminal](/img/Creating%20a%20custom%20reactor/Terminal.PNG)

> _Terminal in App Library_

It will take you into the SEMOSSName terminal where we can use pixel calls to run the reactor. Below you can see how the terminal looks.

![SEMOSSName Terminal](/img/Creating%20a%20custom%20reactor/Inside%20Terminal.PNG)

> SEMOSSName Terminal_

Enter the reactor you want to run and Add user inputs of that reactor within the bracket(). See the illustration below.

![Pixel Call](/img/Creating%20a%20custom%20reactor/Enter%20pixel%20call.PNG)

> _Calling a Reactor using Pixel Call_

Now enter and run the reactor and if it does not return any error, reactor is successfully tested.

## Using a reactor in Front-end code

For using reactor in App code, install the SDK using a package manager:
`npm install @semoss/sdk`

Now, to import the `Insight` from the SDK and create a new instance of it, add below line in App code.

```
import {Insight} from '@semoss/sdk';
const insight = new Insight();
```

Insights are temporal workspaces that allow end users to script and interact with a model, storage engine, or database.

Once the application is mounted, initialize the insight and load your data App into the insight by putting below line in App code;

```
await insight.initialize();
```

After initialization, add below line to run the pixel call.

```
await insight.actions.pixel call
```

Pixel call could be **login-logout, askModel, queryDatabase,run, upload, download etc.**

With this line in the App code, pixel call will run the reactor in the App.

Examples are shown below:

### Query a LLM and return a result

```
const ask = (question) => {
    const { output } = await insight.actions.askModel(MODEL_ID, question);

    // log the output
    console.log(output);
};
```

### Run a database query

```
const getMovies = () => {
    const { output } = await insight.actions.queryDatabase(
        DATABASE_ID,
        'select * from movie',
    );

    // log the output
    console.log(output);
};
```
