[<p align="center"><img src="./main_icon.png" width="120"/></p>](image.png)

# PLS-SEM Mobile Application POC

A Proof-of-Concept mobile application for running Partial Least Squared Structural Equation Modelling on mobile, using Flutter and tobe deployed on Android and iOS.

The app is designated to work best on tablet devices, while it's also optimised to adapt phone screen but not with the best UX.

## Authors

We are a group of student from Vietnamese-German University in Ho Chi Minh City, Vietnam, in a joint Master study programme with Heilbronn University, Germany:
 - Van Hung NGUYEN, email: 20223013@student.vgu.vn
 - Hai Duong NGUYEN, email: 20223008@student.vgu.vn

This project is a module of the subject Management Science which is 
taught by Dr. Hai Dung DINH, Lecturer cum Academic Coordinator in Vietnamese-German University.

## Want to test?

We appredicate all comments and contributions to our young software to be better. If you want to test our build(s), please do not hesitate to contact us via the above-mentioned emails with any of your emails which are used to access to Google Play Store and iCloud. 

You will receive invitation to test our app via Google Play closed test track and TestFlight internal testing.


## Brief Description

The entire project practically follows the tasks of PLS-SEM that can be found here in this document:

This app serves as a front-end to implement a bundle of backend APIs which are made from R code. The Back-end provides the neccessary functions to for calulation and return the results to the app.  The source code of backend can be acccess here:

The main user flow on the mobile app is: user input a dataset (in CSV format from device's memory), measurement model and structural model. Then the trinity of these data will be used in all other tasks of the PLS SEM analysis technique. The tasks that can be conducted in the app are listed in the next section.

Most of the tasks of PLS-SEM will be automatically calculated based on the inputed dataset and measurement and structual model. Some other tasks require users to have more input, for example: convergent validity analysis for formative model, moderation analysis, mediation analysis and predictive model comparison.



## Status 

Based on the document mentioned above, the PLS-SEM processes that are supported in the app:


### Chapter 3: Model set up

- Create a measurement model ([link](https://sem-in-r.github.io/seminr/#232_Create_a_measurement_model))
- Create a structural model ([link](https://sem-in-r.github.io/seminr/#233_Create_a_structural_model))
- Estimating the model (link)
- Summarizing the model
- Bootstrapping the model

### Chapter 4: Evaluation of reflective measurement models

- Indicator reliability 
- Internal consistency reliability
- Convergent validity
- Discriminant validity

### Chapter 5: Evaluation of formative measurement models
- Model setup and measurement details
- Estimating and bootstrapping the model
- Reflective Measurement Model Evaluation
- Convergent validity with redundancy models 
- Indicator collinearity
- Significance and relevance of the indicator weights

### Chapter 6: Evaluation of the structural model
- Collinearity issues
- Significance and relevance of the structural model relationships
- Explanatory power 
- Prediction power: Generate predictions
- Prediction power: Predictive model comparisons

### Chapter 7: Mediation analysis

### Chapter 8: Moderation analysis

## Indicators that can be presented by the app: 

- `iterations` 
- `paths`
- `total_effects`  
- `total_indirect_effects`  
- `loadings`  
- `weights` 	 
- `validity` 	 
- `reliability` 	 
- `composite_scores` 	 
- `vif_antecedents` 	 
- `fSquare` 	 
- `descriptives` 	 
- `it_criteria`
- `nboot`
- `bootstrapped_paths` 	 
- `bootstrapped_weights` 	 
- `bootstrapped_loadings` 	 
- `bootstrapped_HTMT` 	 
- `bootstrapped_total_paths` 	

## Instructions

### Dataset upload
 
1. After opening the app, press on the button "Add Dataset" on home screen. 
2. You need to define whether your dataset (CSV) has delimiter as comma (,) or semicolon (;)
3. Press on button Upload File to select a file from your storage to feed into the app.

The app will notify you on how many rows and columns retrieved from your dataset. You can also preview the first ten rows of the dataset.

### Prepare Measurement and Structural models

If you are using the dataset "Corporate reputation data.csv" from the document, the app was automated to add Measurement and Structural models for your convenience.

1. Scroll down on the Data Import screen until you see Measurement model section.
2. Press on + button to start adding a new composite.
3. A right drawer appears and allows you to edit the composite. (Please strongly rely on this document know how to make and understand a 'composite').
4. Press on Save button to save the composite. It should also appear in the list under Measurement model section
5. If you want to delete a composite, press on it again and you will find Delete button at the bottom of the drawer

Do the same set up steps for Structural model.

You can decide to use 'path weighting' to estimate the PLS model. For more details, see here.

### Save the Measurement and Structural models

1. Still in the Data Import screen, press on Done button at the top-right corner.
2. The app will ask you to save the setup by pressing on Save button. Otherwise you can cancel or discard the model setup if you want.

### Explore other PLS-SEM tasks 

Once you have had set up the dataset, measurement and structural models, you are unlocked to explore other tasks of PLS-SEM evaluation.

As mentioned, these tasks are automated as interacting with backend system to generate the results and show them on the app for you.

Some tasks can take longer time compared to others due to the complexity in the calculation and its data structure.

### Some special tasks needing additional user inputs

#### Convergent Validity of Formative Models

You are recommended to reference to this chapter in the document that can be found here.

You can load the predefined list of redundancy models as in the document by pressing on "Load Predefined".

1. Press on "+ Add" button to add a Redundancy model.
2. A Drawer appears and allows you to edit specifications for the new Redundancy model
3. After you press on Save, the app will call backend API and calculate the results for you.

#### Make and compare Predictive models

1. Press on "Predictive model comparisons" under "Evaluation of structural model" section.
2. You will see the same UI as in the model setup screen as mentioned in Data Import screen. But the difference is to make multiple Structural Models.
3. Press on "+ Add more Structural Model" to add a new structural model.
4. Compose and add more paths for each structural model as you need.
5. Press on "Start Compare" to make comparison between each Structural Model.

#### Mediation Analysis

You are recommended to reference to this chapter in the document that can be found here.

1. Press on "Mediation Analysis" under "Mediation Analysis" section.
2. Press on "+ Add" button to add a specified effect significance to analyze.
3. Fulfill all infos for "From", "To" and "Through" combo boxes.
4. After that, press on Calculate. The app should analyze the specified effect significance and show data on the screen after processing.

